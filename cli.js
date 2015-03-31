var fs = require("fs"),
	path = require("path"),
	lever = require("./main.js"),
	silent = false,

	commands = {};

function log()
{
	if(!silent)
	{
		console.log.apply(console, arguments);
	}
}

commands.new = function(args, opts) {
	console.log("new", args, opts);
};
commands.init = commands.new;

commands.package = function(args, opts) {
	console.log("package", args, opts);
};

commands.compile = function(args, opts) {
	var lever_opts = {
		"compact": opts.compact
	};
	for(var i = 0; i < args.length; i++)
	{
		var file = path.resolve(args[i]),
			ex = fs.existsSync(file),
			cat = "";
		if(path.extname(file) === "" && !ex)
		{
			file = file + ".ls";
			ex = fs.existsSync(file);
		}
		if(ex)
		{
			log("Processing", path.basename(file));
			var ls = fs.readFileSync(file, "utf-8"),
				ts = lever(ls, lever_opts);
			if(opts.out)
				cat += ts;
			else
			{
				log("Writing", path.basename(file + ".cs"));
				fs.writeFileSync(file + ".cs", ts, "utf-8");
			}
		} else
		{
			log(path.basename(file), "not found");
		}
	}
	if(opts.out)
	{
		log("Writing", path.basename(opts.out));
		fs.writeFileSync(opts.out, cat, "utf-8");
	}
};


var cmd = process.argv[2],
	i = 2 + Number(commands.hasOwnProperty(cmd)),

	argv = require("minimist")(
		process.argv.slice(i),
		{
			"string": ["out"],
			"boolean": ["compact", "silent"],
			"alias": {
				"c": "compact",
				"s": "silent",
				"o": "out"
			}
		}
	);

silent = argv.silent;

if(!commands.hasOwnProperty(cmd))
	commands.compile(argv._, argv);
else
	commands[cmd](argv._, argv);