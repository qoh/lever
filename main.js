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
        case "if-stmt":
            if (node.else !== null) {
                return "if(" + generate(node.cond, opt, ctx) + ")" +
                    "{" + generate(node.body, opt, ctx) + "}" +
                    "else " + generate(node.else, opt, ctx);
            } else {
                return "if(" + generate(node.cond, opt, ctx) + ")" +
                    "{" + generate(node.body, opt, ctx) + "}";
            }
        case "foreach-stmt":
            return "%__curr_iter=" + generate(node.iter, opt, ctx) + ";" +
                "while(iter_next(%__curr_iter)){" + generate(node.bind, opt, ctx) +
                "=$iter_value[%__curr_iter];" + generate(node.body, opt, ctx) + "}";
        case "loop-stmt":
            return "while(1){" + generate(node.body, opt, ctx) + "}";
        case "expr-stmt":
            return generate(node.expr, opt, ctx) + ";";
        case "call":
            return node.name + "(" + generate(node.args, opt, ctx, ",") + ")";
        case "variable":
            return (node.global ? "$" : "%") + node.name;
        case "constant":
            switch (node.what) {
                case "integer": return node.value;
                case "float": return node.value;
                case "string": return node.value;
                case "boolean": return node.value == "true" ? "1" : "0";
            }
        case "binary":
            return generate(node.lhs, opt, ctx) + node.op + generate(node.rhs, opt, ctx);
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
