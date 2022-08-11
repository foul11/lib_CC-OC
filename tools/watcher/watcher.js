require("log-timestamp");

const fs = require("fs");
const path = require('path');
const http = require("http");
const child = require('child_process');
const yargs = require('yargs/yargs');
const { hideBin } = require('yargs/helpers');

const argv = yargs(hideBin(process.argv))
	.command('server', 'make http server', {
		port: {
			describe: 'set port for http server',
			alias: 'p',
			type: 'number',
			default: 9001,
		},
		bind: {
			describe: 'set bind for http server',
			alias: 'b',
			type: 'string',
			default: '0.0.0.0',
		},
	}).option('echo', {
		description: 'internal',
		type: 'string',
		default: '',
	})
	.argv;

const hostDir = path.resolve(argv._[1]);
const lua53PreProcessPath = path.resolve("../lua-preprocessor/__init__.lua");

function getIPAddress(){
	var interfaces = require('os').networkInterfaces();
	
	for (var devName in interfaces) {
		var iface = interfaces[devName];
		
		for (var i = 0; i < iface.length; i++) {
			var alias = iface[i];
			if (alias.family === 'IPv4' && alias.address !== '127.0.0.1' && !alias.internal)
				return alias.address;
		}
	}
	
	return '0.0.0.0';
}

function sanitize(to, dir){
	to = path.normalize(to);
	
	if(to.indexOf('\0') !== -1){
		return false;
	}
	
	if(path.join(dir, to).indexOf(dir) !== 0){
		return false;
	}
	
	return path.join(dir, to);
}

const httpServer = http.createServer(function(req, res){
	res.setHeader('Content-Type', 'text/plain;charset=UTF-8');
	
	const from = sanitize(req.url, hostDir);
	
	console.log(from);
	
	if(from == false){
		res.writeHead(403);
		res.end('access denied');
		
		return;
	}
	
	const file = fs.createReadStream(from);
	
	file.on('error', function(){
		res.writeHead(404);
		res.end('not found');
	});
	
	file.on('open', function(){
		res.writeHead(200);
		
		const luaPreProcessor = child.spawn("lua53", [lua53PreProcessPath, "fromjs=true"], { stdio: [file, 'pipe', 'pipe'], cwd: path.dirname(from) });
		
		luaPreProcessor.stdout.on('data', function(data){
			res.write(data);
		});
		
		luaPreProcessor.stderr.on('data', function(data){
			console.error(data.toString('utf8'));
		});
		
		luaPreProcessor.on('close', function(code){
			res.end();
		});
	});
	
	// fs.promises.readFile(from).then(function(content){
		// child.spawn("lua53", [from, "fromjs=true"], { stdio: [''] })
		
		// res.writeHead(200);
		// res.end(content);
	// }).catch(function(){
		// res.writeHead(404);
		// res.end('not found');
	// });
});

httpServer.listen(argv.port, argv.bind);

console.log(`Server is running on http://${argv.bind}:${argv.port}`);
console.log(argv.echo.replaceAll('{serverAddr}', `http://${getIPAddress()}:${argv.port}`));


