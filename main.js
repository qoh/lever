var parser = require("./syntax").parser;

var find_root = function(ctx, type) {
    if (type === undefined || type === null) {
        while (ctx.from !== undefined) {
            ctx = ctx.from;
        }

        return ctx;
    }

    while (ctx !== undefined) {
        if (ctx.node.type == "lambda") {
            break;
        }

        if (ctx.node.type == type) {
            return ctx;
        } else {
            ctx = ctx.from;
        }
    }

    return null;
};

var generate = function(node, opt, ctx, join) {
    var nxt = {node: node, from: ctx};

    if (Array.isArray(node)) {
        var joined = "";

        for (var i = 0; i < node.length; i++) {
            if (join !== undefined && i > 0) {
                joined += join;
            }

            joined += generate(node[i], opt, nxt);
        }

        return joined;
    }

    switch (node.type) {
        case "package-decl":
            var ts = "package " + node.name + "{" + generate(node.body, opt, nxt) + "};";

            if (node.active) {
                ts += "activatePackage(" + node.name + ");"
            }

            return ts;
        case "fn-stmt":
            var args = "";

            for (var i = 0; i < node.args.length; i++) {
                args += (i > 0 ? "," : "") + "%" + node.args[i];
            }

            return "function " + node.name +
                "(" + args + ")" +
                "{" + generate(node.body, opt, nxt) + "}";
        case "return-stmt":
            var root = find_root(ctx, "foreach-stmt");
            var clean;

            if (root !== null) {
                clean = "iter_drop(" + root.ref + ");"
            } else {
                clean = "";
            }

            if (node.expr !== null) {
                return clean + "return " + generate(node.expr, opt, nxt) + ";"
            } else {
                return clean + "return;";
            }
        case "break-stmt":
            return "break;";
        case "if-stmt":
            if (node.else !== null) {
                return "if(" + generate(node.cond, opt, nxt) + ")" +
                    "{" + generate(node.body, opt, nxt) + "}" +
                    "else " + generate(node.else, opt, nxt);
            } else {
                return "if(" + generate(node.cond, opt, nxt) + ")" +
                    "{" + generate(node.body, opt, nxt) + "}";
            }
        case "foreach-stmt":
            var ref = "%__curr_iter";
            nxt.ref = ref;
            return ref + "=" + generate(node.iter, opt, nxt) + ";" +
                "while(iter_next(" + ref +")){" + generate(node.bind, opt, nxt) +
                "=$iter_value[" + ref + "];" + generate(node.body, opt, nxt) + "}" +
                "iter_drop(" + ref + ");";
        case "loop-stmt":
            return "while(1){" + generate(node.body, opt, nxt) + "}";
        case "expr-stmt":
            return generate(node.expr, opt, nxt) + ";";
        case "expr-expr":
            return "(" + generate(node.expr, opt, nxt) + ")";
        case "call":
            if (node.target !== undefined) {
                return generate(node.target, opt, nxt) + "." + node.name +
                    "(" + generate(node.args, opt, nxt, ",") + ")";
            } else if (node.scope !== undefined) {
                return node.scope + "::" + node.name + "(" + generate(node.args, opt, nxt, ",") + ")";
            } else {
                return node.name + "(" + generate(node.args, opt, nxt, ",") + ")";
            }
        case "macro-call":
            return "macro_call()";
        case "assign":
            return generate(node.var, opt, nxt) + "=" + generate(node.rhs, opt, nxt);
        case "field-get":
            return generate(node.expr, opt, nxt) + "." + node.name;
        case "array-get":
            return generate(node.expr, opt, nxt) + "._get_array(" + generate(node.array, opt, nxt) + ")";
        case "field-set":
            return generate(node.expr, opt, nxt) + "." + node.name + "=" + generate(node.rhs, opt, nxt);
        case "array-set":
            return generate(node.expr, opt, nxt) + "._set_array(" + generate(node.array, opt, nxt) + "," + generate(node.rhs, opt, nxt) + ")";
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
            return generate(node.lhs, opt, nxt) + node.op + generate(node.rhs, opt, nxt);
        case "unary":
            return node.op + generate(node.rhs, opt, nxt);
        case "ts-fence-expr":
            return node.code;
        case "lambda":
            var root = find_root(ctx);
            var name = "___anonymous_" + "hashhere";
            var args = "";

            for (var i = 0; i < node.args.length; i++) {
                args += (i > 0 ? "," : "") + "%" + node.args[i];
            }

            root.inject += "function " + name +
                "(" + args + ")" +
                "{" + generate(node.body, opt, nxt) + "}";

            return "\"" + name + "\"";
        case "create-vec":
            var values = "";

            for (var i = 0; i < node.values.length; i++) {
                values += "value" + i + "=" + generate(node.values[i], opt, nxt) + ";";
            }

            return "new ScriptObject(){class=\"Vec\";length=" +
                node.values.length + ";" + values + "}";
    }

    return "<< " + node.type + " " + JSON.stringify(ctx.node, " ") + " >>";
};

var convert = function(source) {
    var ast = parser.parse(source);
    //console.log(JSON.stringify(ast, null, 4));

    var opt = {};
    var ctx = {inject: ""};

    var generated = generate(ast, opt, ctx);
    return ctx.inject + generated;
};

var fs = require("fs");
var path = require("path");

var file = path.normalize(process.argv[2]);
var source = fs.readFileSync(file, "utf8");
var ts = convert(source);
fs.writeFileSync(file + ".cs", ts, "utf8");
