#!/usr/bin/env node

var fs = require("fs"),
	path = require("path"),
	lever = require("./main.js"),
	mkdirp = require("mkdirp"),
	exec = require("child_process").exec,
	silent = false,

	commands = {};


// 100% not copy and pasted
function dive(dir, action) {
	// Assert that it's a function
	if (typeof action !== "function")
		action = function (error, file) { };

	// Read the directory
	fs.readdir(dir, function (err, list) {
		// Return the error if something went wrong
	    if (err) return action(err);

	    list.forEach(function (file) {
	        var path = dir + "/" + file;

		    fs.stat(path, function (err, stat) {
		        if (stat && stat.isDirectory())
					dive(path, action);
		        else
		            action(null, path);
	        });
	    });
    });
};

function log()
{
	if(!silent)
	{
		console.log.apply(console, arguments);
	}
}

commands.new = function(args, opts) {
	if (args.length == 0) {
		console.error("Usage: lever init|new Addon_Name");
		return;
	}

	var addon = args[0];

	if (addon.split('_').length != 2) {
		console.error("Add-On names must be formatted as: Type_Name");
		return;
	}

	mkdirp.sync(addon);

	if (opts.git) {
		exec("git init " + addon + "/", function (error, stdout, stderr) {
			// bleh
		});

		fs.writeFile(addon + "/.gitignore", "*.ls.cs\n.hashes", function (err) {
			if (err) throw err;
		})
	}

	if ( opts.client && !opts.server ) {
		fs.writeFile(addon + "/client.ls", "// Your Code Here", function (err) {
			if (err) throw err;
		});
	}
	else {
		fs.writeFile(addon + "/server.ls", "// Your Code Here", function (err) {
			if (err) throw err;
		});
	}

	var author = opts.author ? opts.author : "";
	var desc = opts.desc ? opts.desc : "";

	fs.writeFile(addon + "/description.txt", "Author: " + author + "\n" + desc, function (err) {
		if (err) throw err;
	});

	if (opts.namecheck) {
		fs.writeFile(addon + "/namecheck.txt", addon, function (err) {
			if (err) throw err;
		});
	}

	console.log("Successfully created " + addon);
};
commands.init = commands.new;

commands.package = function(args, opts) {
	console.log("package", args, opts);
};

commands.compileall = function(args, opts) {
	var loc = args.length > 0 ? args[0] : ".";

	dive(loc, function (err, file) {
		if (err) throw err;

		if ( file.substring(file.length - 3, file.length) != ".ls" ) {
			return;
		}

		var ls = fs.readFileSync(file, "utf-8"),
			ts = lever(ls, { "compact": opts.compact } );

		log("Writing", path.basename(file + ".cs"));
		fs.writeFileSync(file + ".cs", ts, "utf-8");
	});
};

commands.compile = function(args, opts) {
	var lever_opts = {
		"compact": opts.compact
	};

	for (var i = 0; i < args.length; i++) {
		var file = path.resolve(args[i]),
			ex = fs.existsSync(file),
			cat = "";
		if(path.extname(file) === "" && !ex) {
			file = file + ".ls";
			ex = fs.existsSync(file);
		}
		if(ex) {
			log("Processing", path.basename(file));
			var ls = fs.readFileSync(file, "utf-8"),
				ts = lever(ls, lever_opts);

			if(opts.out)
				cat += ts;
			else {
				log("Writing", path.basename(file + ".cs"));
				fs.writeFileSync(file + ".cs", ts, "utf-8");
			}
		}
		else {
			log(path.basename(file), "not found");
		}
	}

	if(opts.out) {
		log("Writing", path.basename(opts.out));
		fs.writeFileSync(opts.out, cat, "utf-8");
	}
};

commands.help = function (args, opts) {
	console.log("Usage: lever <command> [-c|--compact] [-o|--out] [-a|--author] [-d|--description] [<args>]");
	console.log("Commands:\n");
	console.log("\tcompile\t\t Compile a given set of files.");
	console.log("\tcompileall\t Compile all of the files in the working directory");
	console.log("\tinit|new\t Create a skeleton for a new add-on.");
	console.log("\tbuild|package\t Package the current project into an Add-On (unimplemented)");
};

commands.shorthelp = function (args, opts) {
	console.log("Usage: lever [command] [options]");
	console.log("Use lever help to find out more commands.");
};

var cmd = process.argv[2],
	i = 2 + Number(commands.hasOwnProperty(cmd)),

	argv = require("minimist")(
		process.argv.slice(i),
		{
			"string": ["out", "author", "description"],
			"boolean": ["compact", "silent", "git", "client", "server", "namecheck"],
			"alias": {
				"c": "compact",
				"s": "silent",
				"o": "out",
				"g": "git",
				"n": "namecheck",
				"d": "description",
				"a": "author"
			}
		}
	);

silent = argv.silent;

if(!commands.hasOwnProperty(cmd))
	commands.shorthelp(argv._, argv);
else
	commands[cmd](argv._, argv);
