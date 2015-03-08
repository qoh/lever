var fs = require("fs");
var path = require("path");
var crypto = require("crypto");

var parser = require("./syntax").parser;

var find_predicate = function(ctx, pred) {
    while (ctx !== undefined) {
        if (ctx.node !== undefined && pred(ctx.node)) {
            return ctx;
        } else {
            ctx = ctx.from;
        }
    }

    return null;
};

var find_root = function(ctx, type, anyway) {
    if (type === undefined || type === null) {
        while (ctx.from !== undefined) {
            ctx = ctx.from;
        }

        return ctx;
    }

    while (ctx !== undefined) {
        if (!anyway && ctx.node !== undefined && ctx.node.type == "lambda") {
            break;
        }

        if (ctx.node !== undefined && ctx.node.type == type) {
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
            var ts = "package " + node.name + " {\n" + generate(node.body, opt, nxt, "\n") + "\n};\n";

            if (node.active) {
                ts += "\nactivatePackage(" + node.name + ");\n"
            }

            return ts;
        case "fn-stmt":
            var root = find_root(ctx, "class-decl");

            var name = node.name;
            var args = node.args;

            var scoped = false;

            if (root !== null) {
                name = root.node.name + "::" + name;
                args = args.slice(0);
                args.unshift("this");

                if (scoped) {
                    args.unshift("%____scope");
                }
            }

            var str = "";

            for (var i = 0; i < args.length; i++) {
                str += (i > 0 ? ", " : "") + "%" + args[i];
            }

            var addl = "";
            var addr = "";

            if (node.scoped) {
                addl += "%____scope=LeverScope(%____scope);";
                addr += "%____scope.drop();";

                for (var i = 0; i < args.length; i++) {
                    addl += "%____scope." + args[i] + "=%" + args[i] + ";";
                }
            }

            return "function " + name + "(" + str + ")" +
                " {\n" + addl + generate(node.body, opt, nxt, "\n") + addr + "\n}\n";
        case "class-decl":
            var ctor = "function " + node.name + "(" +
                "%a,%b,%c,%d,%e,%f,%g,%h,%i,%j,%k,%l,%m,%n,%o,%p,%q,%r,%s) {\n" +
                "%z = new ScriptObject() {\nclass = \"" + node.name + "\";\nsuperCla" +
                "ss = \"Class\";\n____inst=1;\n};\nif(isFunction(\"" + node.name +
                "\", \"onNew\"))\n%z.onNew(" +
                "%a,%b,%c,%d,%e,%f,%g,%h,%i,%j,%k,%l,%m,%n,%o,%p,%q,%r,%s);\n" +
                "return %z;\n}\n\n";
            return "\nif(!isObject(" + node.name + "))\nnew ScriptObject(" +
                node.name + ") {\nclass = \"Class\";\n____inst = 0;\n};\n\n" + ctor +
                generate(node.body, opt, nxt, "\n");
        case "return-stmt":
            var root = find_root(ctx, "foreach-stmt");
            var clean;

            if (root !== null) {
                clean = "iter_drop(" + root.ref + ");\n"
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
                return "if (" + generate(node.cond, opt, nxt) + ")" +
                    " {\n" + generate(node.body, opt, nxt) + "\n} " +
                    "else {\n" + generate(node.else, opt, nxt, "\n") + "\n}";
            } else {
                return "if (" + generate(node.cond, opt, nxt) + ")" +
                    " {\n" + generate(node.body, opt, nxt) + "\n}";
            }
        case "foreach-stmt":
            var root = find_root(ctx, "foreach-stmt");
            var ref;

            if (root === null) {
                ref = "%__iter";
            } else {
                ref = root.ref + "_";
            }

            nxt.ref = ref;

            return ref + "=" + generate(node.iter, opt, nxt) + ";\n" +
                "while(iter_next(" + ref +")) {\n" + generate(node.bind, opt, nxt) +
                " = $iter_value[" + ref + "];\n" + generate(node.body, opt, nxt, "\n") + "\n}\n" +
                "iter_drop(" + ref + ");\n";
        case "while-stmt":
            return "while(" + generate(node.cond, opt, nxt) + ") {\n" + generate(node.body, opt, nxt, "\n") + "\n}\n";
        case "loop-stmt":
            return "while(1) {\n" + generate(node.body, opt, nxt, "\n") + "\n}\n";
        case "expr-stmt":
            return generate(node.expr, opt, nxt) + ";";
        case "expr-expr":
            return "(" + generate(node.expr, opt, nxt) + ")";
        case "call":
            if (node.target !== undefined) {
                return generate(node.target, opt, nxt) + "." + node.name +
                    "(" + generate(node.args, opt, nxt, ", ") + ")";
            } else if (node.scope !== undefined) {
                return node.scope + "::" + node.name + "(" + generate(node.args, opt, nxt, ", ") + ")";
            } else {
                if (node.name == "call" && node.args.length >= 1) {
                  var name = "__lever_call" + Math.min(18, Math.max(0, node.args.length - 1));
                  return name + "(" + generate(node.args, opt, nxt, ", ") + ")";
                }
                else {
                  return node.name + "(" + generate(node.args, opt, nxt, ", ") + ")";
                }
            }
        case "new-object":
            return "new " + node.class + "(" + generate(node.args, opt, nxt, ", ") + ")";
        case "macro-call":
            return "macro_call()";
        case "assign":
            return generate(node.var, opt, nxt) + " = " + generate(node.rhs, opt, nxt);
        case "field-get":
            return generate(node.expr, opt, nxt) + "." + node.name;
        case "array-get":
            return generate(node.expr, opt, nxt) + "._get_array(" + generate(node.array, opt, nxt) + ")";
        case "field-set":
            return generate(node.expr, opt, nxt) + "." + node.name + " = " + generate(node.rhs, opt, nxt);
        case "array-set":
            return generate(node.expr, opt, nxt) + "._set_array(" + generate(node.array, opt, nxt) + ", " + generate(node.rhs, opt, nxt) + ")";
        case "variable":
            if (node.global == "$") {
                return "$" + node.name;
            }

            var fn = find_root(ctx, "fn-stmt", true);

            if (fn !== null && fn.node.scoped) {
                return "%____scope." + node.name;
            }

            return "%" + node.name;
        case "identifier":
            return node.name;
        case "constant":
            switch (node.what) {
                case "integer": return node.value;
                case "float": return node.value;
                case "string": return "\"" + node.value + "\"";
                case "boolean": return node.value == "true" ? "1" : "0";
            }
        case "binary":
            return generate(node.lhs, opt, nxt) + " " + node.op + " " + generate(node.rhs, opt, nxt);
        case "unary":
            return node.op + generate(node.expr, opt, nxt);
        case "ts-fence-expr":
            return node.code;
        case "lambda":
            // TODO: better hashing
            var sha1 = crypto.createHash("sha1");
            sha1.update(JSON.stringify(node));

            var root = find_root(ctx);
            var name = "___anonymous_" + sha1.digest("hex");
            var args = "";

            var fn = find_root(ctx, "fn-stmt");
            var scoped = fn !== null && fn.node.scoped;

            if (scoped) {
              node.args.unshift("____scope");
            }

            for (var i = 0; i < node.args.length; i++) {
                args += (i > 0 ? ", " : "") + "%" + node.args[i];
            }

            root.inject += "function " + name +
                "(" + args + ")" +
                " {\n" + generate(node.body, opt, nxt, "\n") + "\n}\n\n";

            if (scoped) {
              return "LeverClosure(%____scope, \"" + name + "\")";
            }

            return "\"" + name + "\"";
        case "create-vec":
            var values = "";

            for (var i = 0; i < node.values.length; i++) {
                values += ".____newitem(" + generate(node.values[i], opt, nxt) + ")";
            }

            return "____newvec()" + values;
        case "create-map":
            //console.log(JSON.stringify(node, null, 4));
            var values = "";

            for (var i = 0; i < node.pairs.length; i++) {
                values += ".____newpair(" + generate(node.pairs[i][0], opt, nxt) +
                    ", " + generate(node.pairs[i][1], opt, nxt) + ")";
            }

            return "____newhashmap()" + values;
    }

    return "<< " + node.type + " " + JSON.stringify(node, " ") + " >>";
};

var convert = function(source) {
    var ast = parser.parse(source);
    //console.log(JSON.stringify(ast, null, 4));

    var opt = {};
    var ctx = {inject: ""};

    var generated = generate(ast, opt, ctx);
    return ctx.inject + generated;
};

var file = path.normalize(process.argv[2]);
var source = fs.readFileSync(file, "utf8");
var ts = convert(source);
fs.writeFileSync(file + ".cs", ts, "utf8");
