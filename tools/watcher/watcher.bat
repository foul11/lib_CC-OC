@@  REM https://www.cyberforum.ru/cmd-bat/thread2628337.html
@@  IF EXIST "__%~N0.exe" ( "__%~N0.exe" %* ) & (EXIT /B ERRORLEVEL) 
@@  FOR /F %%X IN ('DIR /B /S %WINDIR%\Microsoft.NET\Framework\CSC.EXE') DO @@(SET COMPILER=%%X)
@@  IF NOT DEFINED COMPILER (ECHO No .NET specific compiler presents in your computer !!!) & ( ECHO Goodbye !!! ) & ( EXIT/B -1 )
@@  FINDSTR /B /VC:@@  "%~F0" > "%~N0.cs"
@@  %COMPILER%  /OUT:"__%~N0.exe" /TARGET:exe "%~N0.cs"
@@  IF EXIST "__%~N0.exe" (ECHO Executable file __%~N0.exe created !!! ) & (ECHO Run %~N0 again !!!)  
@@  EXIT/B ERRORLEVEL
 
// ENCODING UTF-8   // Предпочтительная кодировка UTF-8 без BOM
 
using System;
using System.IO;
using System.Reflection;
using System.Diagnostics;
using System.Security.Permissions;
 
public class Watcher
{
    // Служебные переменные
    readonly static FieldInfo charPosField    = typeof(StreamReader).GetField("charPos", BindingFlags.NonPublic    | BindingFlags.Instance | BindingFlags.DeclaredOnly);
    readonly static FieldInfo charLenField    = typeof(StreamReader).GetField("charLen", BindingFlags.NonPublic    | BindingFlags.Instance | BindingFlags.DeclaredOnly);
    readonly static FieldInfo charBufferField = typeof(StreamReader).GetField("charBuffer", BindingFlags.NonPublic | BindingFlags.Instance | BindingFlags.DeclaredOnly);
 
    // Служебная подпрограмма для получения текущей позиции чтения с помощью об`екта StreamReader  
    static long ActualPosition(StreamReader reader)
    {
        var charBuffer = (char[])charBufferField.GetValue(reader);
        var charLen    = (int)charLenField.GetValue(reader);
        var charPos    = (int)charPosField.GetValue(reader);
 
        return reader.BaseStream.Position - reader.CurrentEncoding.GetByteCount(charBuffer, charPos, charLen-charPos);
    }
 
    // position  - служебная переменная, хранит смещение в байтах от начала подопытного файла ( в котором мы мониторим изменеия ) до его последней строки
    // watchdir  - имя по умолчанию подопытной директории ( в которой мы мониторим изменения ). Это имя должно задаваться из ком. строки
    // watchfile - имя подопытного файла, в котором мы мониторим изменения. Задаётся пользователем.
    private static long   position;
    public  static string watchdir  =  Path.GetFullPath("procdir");
    public  static string watchfile =  "logfile.log";                   // CHANGE IT !!!
 
 
    public static void Main()
    {
        Run();
    }
 
    [PermissionSet(SecurityAction.Demand, Name = "FullTrust")]
    private static void Run()
    {
        string[] args = Environment.GetCommandLineArgs();
 
        // Если в ком строке значение подопытной директории не задано, сливаем воду, уходим. 
        if (args.Length != 2)
        {
            // Display the proper way to call the program.
            Console.WriteLine("Запускать так: {0} <имя каталога для мониторинга>", args[0] );
            return;
        }
        
        watchdir = Path.GetFullPath(args[1]);
 
        if ( !Directory.Exists(watchdir)) {
            Console.WriteLine("Директории не существует");
            return;
        }
 
        // Создание об`екта FileSystemWatcher для мониторинга событий 
        using (var watcher = new FileSystemWatcher())
        {
            watcher.Path = watchdir;
 
            // Декларируем, что будем отслеживать изменения атрибута <LastWrite> и <Size> файла
            watcher.NotifyFilter =  NotifyFilters.LastWrite | NotifyFilters.Size;
 
            // Кого будем отслеживать ( здесь имя нашего лог-файла, но можно задать даже так: *.* )
            watcher.Filter = watchfile;
 
            // ВНИМАНИЕ! Именно здесь добавляем адрес callback-обработчика ( сам обработчик см. ниже  )
 
            watcher.Changed += new FileSystemEventHandler(OnChanged);   
            
 
            // Ныряем в конец содержимого подопытного файла.
            // На кодировку при создании конструктора StreamReader нам здесь наплевать; основная задача - запомнить position у конца
            using (var sr = new StreamReader(Path.Combine(watchdir, watchfile)))
            {
 
                sr.BaseStream.Seek((-1), SeekOrigin.End);
 
                position = ActualPosition( sr );
            }
 
 
            // Начинаем отслеживать !!
            watcher.EnableRaisingEvents = true;
 
            // Встаём на паузу, ждём КУ от пользователя для выхода из программы.
            Console.WriteLine("Введите q <ENTER> для выхода.");
            while (Console.Read() != 'q') ;
        }
    }
 
    // Наш callback обработчик события - изменений в лог-файле  
    public static void OnChanged(object source, FileSystemEventArgs ev)  
    { 
        
        // Строка(и) хранения самых последних изменнеий
        string lastlines;  
 
        // Specify what is done when a file is changed.
        // Console.WriteLine("{0}, with path {1} has been {2}; Last file position in bytes: {3}", ev.Name, ev.FullPath, ev.ChangeType, position);
 
        
        // Собственно чтение последних изменений подопытного файла с помощью об`екта StreamReader. Обратите внимание на кодировку !!!!
        // Если log-file в однобайтной кодировке ANSI ( cp1251 ), то оставляем этот параметр: System.Text.Encoding.Default.
        // Если же log-file в UTF-8 или UTF-16, то этот параметр следует из конструктора совсем убрать(!!!), StreamReader дальше сам разберётся.
        //using (var sr = new StreamReader( Path.Combine(watchdir,watchfile),  System.Text.Encoding.Default))
        using (var sr = new StreamReader( Path.Combine(watchdir,watchfile)))
        {
            sr.BaseStream.Seek(position, SeekOrigin.Begin);
            lastlines = sr.ReadToEnd ();
            position = ActualPosition(sr);
            
            // Отладочный вывод
            //Console.WriteLine( lastlines );
        }
 
        try
        {
            using ( var sw = new StreamWriter("__line__"))
            {
                sw.Write(lastlines);
            }
    
            using (var cmd = new Process())
            {
                cmd.StartInfo.FileName = "cmd.exe";
                cmd.StartInfo.Arguments = "/c hook.bat __line__";
                cmd.StartInfo.UseShellExecute = false;
                //cmd.StartInfo.RedirectStandardOutput = true;
                cmd.Start();
 
                //Console.WriteLine(cmd.StandardOutput.ReadToEnd());
 
                //cmd.WaitForExit();
            }
        }
        catch ( Exception e )
        {
               Console.WriteLine( e.Message ); 
        }
 
    }  
}