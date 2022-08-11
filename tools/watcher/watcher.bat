@@  REM https://www.cyberforum.ru/cmd-bat/thread2628337.html
@@  IF EXIST "__%~N0.exe" ( "__%~N0.exe" %* ) & (EXIT /B ERRORLEVEL) 
@@  FOR /F %%X IN ('DIR /B /S %WINDIR%\Microsoft.NET\Framework\CSC.EXE') DO @@(SET COMPILER=%%X)
@@  IF NOT DEFINED COMPILER (ECHO No .NET specific compiler presents in your computer !!!) & ( ECHO Goodbye !!! ) & ( EXIT/B -1 )
@@  FINDSTR /B /VC:@@  "%~F0" > "%~N0.cs"
@@  %COMPILER%  /OUT:"__%~N0.exe" /TARGET:exe "%~N0.cs"
@@  IF EXIST "__%~N0.exe" (ECHO Executable file __%~N0.exe created !!! ) & (ECHO Run %~N0 again !!!)  
@@  EXIT/B ERRORLEVEL
 
// ENCODING UTF-8   // ���������������� ��������� UTF-8 ��� BOM
 
using System;
using System.IO;
using System.Reflection;
using System.Diagnostics;
using System.Security.Permissions;
 
public class Watcher
{
    // ��������� ����������
    readonly static FieldInfo charPosField    = typeof(StreamReader).GetField("charPos", BindingFlags.NonPublic    | BindingFlags.Instance | BindingFlags.DeclaredOnly);
    readonly static FieldInfo charLenField    = typeof(StreamReader).GetField("charLen", BindingFlags.NonPublic    | BindingFlags.Instance | BindingFlags.DeclaredOnly);
    readonly static FieldInfo charBufferField = typeof(StreamReader).GetField("charBuffer", BindingFlags.NonPublic | BindingFlags.Instance | BindingFlags.DeclaredOnly);
 
    // ��������� ������������ ��� ��������� ������� ������� ������ � ������� ��`���� StreamReader  
    static long ActualPosition(StreamReader reader)
    {
        var charBuffer = (char[])charBufferField.GetValue(reader);
        var charLen    = (int)charLenField.GetValue(reader);
        var charPos    = (int)charPosField.GetValue(reader);
 
        return reader.BaseStream.Position - reader.CurrentEncoding.GetByteCount(charBuffer, charPos, charLen-charPos);
    }
 
    // position  - ��������� ����������, ������ �������� � ������ �� ������ ����������� ����� ( � ������� �� ��������� �������� ) �� ��� ��������� ������
    // watchdir  - ��� �� ��������� ���������� ���������� ( � ������� �� ��������� ��������� ). ��� ��� ������ ���������� �� ���. ������
    // watchfile - ��� ����������� �����, � ������� �� ��������� ���������. ������� �������������.
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
 
        // ���� � ��� ������ �������� ���������� ���������� �� ������, ������� ����, ������. 
        if (args.Length != 2)
        {
            // Display the proper way to call the program.
            Console.WriteLine("��������� ���: {0} <��� �������� ��� �����������>", args[0] );
            return;
        }
        
        watchdir = Path.GetFullPath(args[1]);
 
        if ( !Directory.Exists(watchdir)) {
            Console.WriteLine("���������� �� ����������");
            return;
        }
 
        // �������� ��`���� FileSystemWatcher ��� ����������� ������� 
        using (var watcher = new FileSystemWatcher())
        {
            watcher.Path = watchdir;
 
            // �����������, ��� ����� ����������� ��������� �������� <LastWrite> � <Size> �����
            watcher.NotifyFilter =  NotifyFilters.LastWrite | NotifyFilters.Size;
 
            // ���� ����� ����������� ( ����� ��� ������ ���-�����, �� ����� ������ ���� ���: *.* )
            watcher.Filter = watchfile;
 
            // ��������! ������ ����� ��������� ����� callback-����������� ( ��� ���������� ��. ����  )
 
            watcher.Changed += new FileSystemEventHandler(OnChanged);   
            
 
            // ������ � ����� ����������� ����������� �����.
            // �� ��������� ��� �������� ������������ StreamReader ��� ����� ���������; �������� ������ - ��������� position � �����
            using (var sr = new StreamReader(Path.Combine(watchdir, watchfile)))
            {
 
                sr.BaseStream.Seek((-1), SeekOrigin.End);
 
                position = ActualPosition( sr );
            }
 
 
            // �������� ����������� !!
            watcher.EnableRaisingEvents = true;
 
            // ����� �� �����, ��� �� �� ������������ ��� ������ �� ���������.
            Console.WriteLine("������� q <ENTER> ��� ������.");
            while (Console.Read() != 'q') ;
        }
    }
 
    // ��� callback ���������� ������� - ��������� � ���-�����  
    public static void OnChanged(object source, FileSystemEventArgs ev)  
    { 
        
        // ������(�) �������� ����� ��������� ���������
        string lastlines;  
 
        // Specify what is done when a file is changed.
        // Console.WriteLine("{0}, with path {1} has been {2}; Last file position in bytes: {3}", ev.Name, ev.FullPath, ev.ChangeType, position);
 
        
        // ���������� ������ ��������� ��������� ����������� ����� � ������� ��`���� StreamReader. �������� �������� �� ��������� !!!!
        // ���� log-file � ����������� ��������� ANSI ( cp1251 ), �� ��������� ���� ��������: System.Text.Encoding.Default.
        // ���� �� log-file � UTF-8 ��� UTF-16, �� ���� �������� ������� �� ������������ ������ ������(!!!), StreamReader ������ ��� ���������.
        //using (var sr = new StreamReader( Path.Combine(watchdir,watchfile),  System.Text.Encoding.Default))
        using (var sr = new StreamReader( Path.Combine(watchdir,watchfile)))
        {
            sr.BaseStream.Seek(position, SeekOrigin.Begin);
            lastlines = sr.ReadToEnd ();
            position = ActualPosition(sr);
            
            // ���������� �����
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