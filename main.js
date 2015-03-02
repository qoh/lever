var parser = require("./syntax").parser;

var generate = function(node, opt, ctx, join) {
    if (Array.isArray(node)) {
        var joined = "";

        for (var i = 0; i < node.length; i++) {
            if (join !== undefined && i > 0) {
                joined += join;
            }

            joined += generate(node[i], opt, ctx);
        }

        return joined;
    }

    switch (node.type) {
        case "fn-stmt":
            var args = "";

            for (var i = 0; i < node.args.length; i++) {
                args += (i > 0 ? "," : "") + "%" + node.args[i];
            }

            return "function " + node.name +
                "(" + args + ")" +
                "{" + generate(node.body, opt, ctx) + "}";
        case "return-stmt":
            if (node.expr !== null) {
                return "return " + generate(node.expr, opt, ctx) + ";"
            } else {
                return "return;";
            }
        case "foreach-stmt":
            return "%___jeopardy=" + generate(node.iter, opt, ctx) + ";" +
                "while(iter_next(%___jeopardy)){" + generate(node.bind, opt, ctx) +
                "=$iter_value[%___jeopardy];" + generate(node.body, opt, ctx) + "}";
        case "loop-stmt":
            return "while(1){" + generate(node.body, opt, ctx) + "}";
        case "expr-stmt":
            return generate(node.expr, opt, ctx) + ";";
        case "call":
            return node.name + "(" + generate(node.args, opt, ctx, ",") + ")";
        case "variable":
            return (node.global ? "$" : "%") + node.name;
    }

    return "<< " + node.type + " >>";
};

var convert = function(source) {
    var ast = parser.parse(source);
    console.log(JSON.stringify(ast, null, 4));

    return generate(ast, null, null);
};

//

var fs = require("fs");
var path = require("path");

var source = fs.readFileSync(path.normalize(process.argv[2]), "utf8");
console.log(convert(source));
