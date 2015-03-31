var fs = require("fs"),
    path = require("path"),
    crypto = require("crypto"),
    parser = require("./syntax.js").parser;

function find_predicate(ctx, pred) {
    while (ctx !== undefined) {
        if (ctx.node !== undefined && pred(ctx.node)) {
            return ctx;
        } else {
            ctx = ctx.from;
        }
    }

    return null;
};

function find_root(ctx, type, anyway) {
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

function generate(node, opt, ctx, join) {
    var nxt = {node: node, from: ctx},
        wsn = "", wst = "";

    if(!opt.compact)
    {
        wsn = "\n";
        wst = "\t";
    }

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
            var ts = "package " + node.name + " {" + wsn + generate(node.body, opt, nxt, wsn) + wsn + "};" + wsn;

            if (node.active) {
                ts += wsn + "activatePackage(" + node.name + ");" + wsn;
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
                " {" + wsn + addl + generate(node.body, opt, nxt, wsn) + addr + wsn + "}" + wsn;
        case "class-decl":
            var ctor = "function " + node.name + "(" +
                "%a,%b,%c,%d,%e,%f,%g,%h,%i,%j,%k,%l,%m,%n,%o,%p,%q,%r,%s) {" + wsn +
                "%z = new ScriptObject() {" + wsn + "class = \"" + node.name + "\";" + wsn +
                "superClass = \"Class\";" + wsn + "____inst=1;" + wsn + "};" + wsn +
                "if(isFunction(\"" + node.name + "\", \"onNew\"))" + wsn + "%z.onNew(" +
                "%a,%b,%c,%d,%e,%f,%g,%h,%i,%j,%k,%l,%m,%n,%o,%p,%q,%r,%s);" + wsn +
                "return %z;" + wsn + "}" + wsn + wsn;
            return wsn + "if(!isObject(" + node.name + "))" + wsn + "new ScriptObject(" +
                node.name + ") {" + wsn + "class = \"Class\";" + wsn + "____inst = 0;" + wsn +
                "};" + wsn + wsn + ctor + generate(node.body, opt, nxt, wsn);
        case "return-stmt":
            var root = find_root(ctx, "foreach-stmt");
            var clean;

            if (root !== null) {
                clean = "iter_drop(" + root.ref + ");" + wsn;
            } else {
                clean = "";
            }

            if (node.expr !== null) {
                return clean + "return " + generate(node.expr, opt, nxt) + ";";
            } else {
                return clean + "return;";
            }
            break;
        case "break-stmt":
            return "break;";
        case "if-stmt":
            if (node.else !== null) {
                return "if (" + generate(node.cond, opt, nxt) + ")" +
                    " {" + wsn + generate(node.body, opt, nxt) + wsn + "} " +
                    "else {" + wsn + generate(node.else, opt, nxt, wsn) + wsn + "}";
            } else {
                return "if (" + generate(node.cond, opt, nxt) + ")" +
                    " {" + wsn + generate(node.body, opt, nxt) + wsn + "}";
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

            return ref + "=" + generate(node.iter, opt, nxt) + ";" + wsn +
                "while(iter_next(" + ref +")) {" + wsn + generate(node.bind, opt, nxt) +
                " = $iter_value[" + ref + "];" + wsn + generate(node.body, opt, nxt, wsn) +
                wsn + "}" + wsn + "iter_drop(" + ref + ");" + wsn;
        case "while-stmt":
            return "while(" + generate(node.cond, opt, nxt) + ") {" + wsn +
                generate(node.body, opt, nxt, wsn) + wsn + "}" + wsn;
        case "loop-stmt":
            return "while(1) {" + wsn + generate(node.body, opt, nxt, wsn) + wsn + "}" + wsn;
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
                  if (node.name.toLowerCase() === "parent")
                  {
                    // Parent() sugar
                    var root_pkg = find_root(ctx, "package-decl"),
                        root_fn = find_root(ctx, "fn-stmt");
                    if(root_pkg && root_fn)
                    {
                      if(root_fn.node.name.match(/^servercmd/i))
                      {
                        node.args.unshift({"type": "variable", "global": false, "name": "client"});
                      }
                      return "Parent::" + root_fn.node.name + "(" + generate(node.args, opt, nxt, ", ") + ")";
                    }
                  }
                  return node.name + "(" + generate(node.args, opt, nxt, ", ") + ")";
                }
            }
            break;
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
            break;
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
                " {" + wsn + generate(node.body, opt, nxt, wsn) + wsn + "}" + wsn + wsn;

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

function convert(source, opts) {
    var ast = parser.parse(source);
    //console.log(JSON.stringify(ast, null, 4));

    var opt = {"compact": false};
    for(var k in opts)
    {
        if(opts.hasOwnProperty(k) && opt.hasOwnProperty(k))
        {
            opt[k] = opts[k];
        }
    }
    var ctx = {inject: ""};

    var generated = generate(ast, opt, ctx);
    return ctx.inject + generated;
};

module.exports = convert;