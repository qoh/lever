%left '[' '{'
%right '%=' '&=' '^=' '+=' '-=' '*=' '/=' '|=' '<<=' '>>=' '='
%right '=>'
%left '?' ':'
%left '||'
%left '&&'
%left '|'
%left '^'
%left '&'
%left '==' '!=' '$=' '!$='
%left '<' '<=' '>' '>='
%left '..' '...' '@' 'SPC' 'TAB' 'NL'
%left '<<' '>>'
%left '+' '-'
%left '*' '/' '%'
%right '!' '~' '++' '--' UNARY
%left '.'

%%

start
    : decl_list EOF
        { return $1; }
    ;

decl_list
    : decl
        { $$ = [$1]; }
    | decl_list decl
        { $$ = $1; $1.push($2); }
    ;

decl
    : stmt
        { $$ = $1; }
    | fn_decl
        { $$ = $1; }
    | class_decl
        { $$ = $1; }
    | datablock_decl
        { $$ = $1; }
    | match_decl
        { $$ = $1; }
    | 'package' var_local block_fn_class_only
        { $$ = {type: "package-decl", name: $2, body: $3, active: false}; }
    | 'active' 'package' var_local block_fn_class_only
        { $$ = {type: "package-decl", name: $3, body: $4, active: true}; }
    ;

fn_decl
    : 'fn' var_local '(' ident_list ')' block
        { $$ = {type: "fn-stmt", name: $2, args: $4, body: $6}; }
    | 'fn' var_local '(' ')' block
        { $$ = {type: "fn-stmt", name: $2, args: [], body: $5}; }
    | 'scoped' 'fn' var_local '(' ident_list ')' block
        { $$ = {type: "fn-stmt", name: $3, args: $5, body: $7, scoped: true}; }
    | 'fn' var_local block
        { $$ = {type: "fn-stmt", name: $2, args: [], body: $3}; }
    | 'fn' var_local '::' var_local '(' ident_list ')' block
        { $$ = {type: "fn-stmt", name: $2 + $3 + $4, args: $6, body: $8}; }
    | 'fn' var_local '::' var_local '(' ')' block
        { $$ = {type: "fn-stmt", name: $2 + $3 + $4, args: [], body: $7}; }
    | 'fn' var_local '::' var_local block
        { $$ = {type: "fn-stmt", name: $2 + $3 + $4, args: [], body: $5}; }

    // extreme sugar activate
    | 'fn' '/' var_local '(' ident_list ')' block
        {
            $5.unshift("client");
            $$ = {type: "fn-stmt", name: "serverCmd" + $3, args: $5, body: $7}; }
        }
    | 'fn' '/' var_local '(' ')' block
        { $$ = {type: "fn-stmt", name: "serverCmd" + $3, args: ["client"], body: $6}; }
    | 'fn' '/' var_local block
        { $$ = {type: "fn-stmt", name: "serverCmd" + $3, args: ["client"], body: $4}; }
    ;

fn_decl_list
    : fn_decl
        { $$ = [$1]; }
    | fn_decl_list fn_decl
        { $$ = $1; $1.push($2); }
    ;

fn_class_decl_list
    : fn_decl
        { $$ = [$1]; }
    | class_decl
        { $$ = [$1]; }
    | fn_class_decl_list fn_decl
        { $$ = $1; $1.push($2); }
    | fn_class_decl_list class_decl
        { $$ = $1; $1.push($2); }
    ;

class_decl
    : 'class' var_local block_fn_only
        { $$ = {type: "class-decl", name: $2, body: $3}; }
    ;

match_decl
    : 'match' expr '{' match_pair_list '}'
        { $$ = {type: "match-decl", variate: $2, body: $4}; }
    ;

match_pair_list
    : match_pair
        { $$ = [$1]; }
    | match_pair_list ',' match_pair
        { $$ = $1; $1.push($3); }
    ;

match_pair
    : constant_value ':' block
        { $$ = [{ key: $1, value: $3 }]}
    | constant_value 'or' constant_value ':' block
        { $$ = [{ key: $1, value: $5}, { key: $3, value: $5}]; }
    ;

datablock_decl
    : 'datablock' var_local var_local '{' datablock_pair_list '}'
        { $$ = {type: "datablock-decl", datatype: $2, name: $3, body: $5}; }
    ;

datablock_pair_list
    : datablock_pair
        { $$ = [$1]; }
    | datablock_pair_list ',' datablock_pair
        { $$ = $1; $1.push($3); }
    ;

datablock_pair
    : 'state' var_local '{' map_pair_list '}'
        { $$ = { type: "state-decl", name: $2, data: $4 }; }
    | map_pair
        { $$ = $1; }
    ;

// block
//     : '{' '}'
//         { $$ = []; }
//     | '{' stmt_list '}'
//         { $$ = $2; }
//     ;

block: '{' '}' { $$ = []; } | block_non_empty { $$ = $1; };
block_non_empty: '{' stmt_list '}' { $$ = $2; };

block_fn_only
    : '{' '}'
        { $$ = []; }
    | '{' fn_decl_list '}'
        { $$ = $2; }
    ;

block_fn_class_only
    : '{' '}'
        { $$ = []; }
    | '{' fn_class_decl_list '}'
        { $$ = $2; }
    ;



stmt_list
    : stmt
        { $$ = [$1]; }
    | stmt_list stmt
        { $$ = $1; $1.push($2); }
    ;

stmt
    : stmt_expr ';'
        { $$ = {type: "expr-stmt", expr: $1}; }
    | 'use' expr ';'
        { $$ = {type: "use-stmt", file: $2}; }
    | 'return' ';'
        { $$ = {type: "return-stmt", expr: null}; }
    | 'return' expr ';'
        { $$ = {type: "return-stmt", expr: $2}; }
    | 'break' ';'
        { $$ = {type: "break-stmt"}; }
    | 'continue' ';'
        { $$ = {type: "continue-stmt"}; }
    | if_stmt
        { $$ = $1; }
    | 'for' expr ';' expr ';' expr block
        { $$ = {type: "for-stmt", init: $2, test: $4, step: $6, body: $7}; }
    | 'for' var 'in' expr block
        { $$ = {type: "foreach-stmt", "bind": $2, "iter": $4, body: $5}; }
    | 'for' '(' var 'in' ')' expr block
        { $$ = {type: "foreach-stmt", "bind": $2, "iter": $4, body: $5}; }
    | 'while' expr block
        { $$ = {type: "while-stmt", "cond": $2, body: $3}; }
    | 'loop' block
        { $$ = {type: "loop-stmt", body: $2}; }
    ;

if_stmt
    : 'if' expr block 'else' if_stmt
        { $$ = {type: "if-stmt", "cond": $2, body: $3, "else": $5}; }
    | 'if' expr block 'else' block
        { $$ = {type: "if-stmt", "cond": $2, body: $3, "else": $5}; }
    | 'if' expr block
        { $$ = {type: "if-stmt", "cond": $2, body: $3, "else": null}; }
    ;

ident_list
    : var_local
        { $$ = [$1]; }
    | ident_list ',' var_local
        { $$ = $1; $1.push($3); }
    ;

// expr_list
//     : expr
//         { $$ = [$1]; }
//     | expr_list ',' expr
//         { $$ = $1; $1.push($3); }
//     ;

expr_list
    :
        { $$ = []; }
    | expr
        { $$ = [$1]; }
    | expr_list ',' expr
        { $$ = $1; $1.push($3); }
    ;

expr
    : stmt_expr
        { $$ = $1; }
    | '(' expr ')'
        //{ $$ = $2; }
        { $$ = {type: "expr-expr", expr: $2}; }
    | var
        { $$ = $1; }
    | '@' var_local
        { $$ = {type: "identifier", name: $2}; }
    | expr '.' var_local
        { $$ = {type: "field-get", expr: $1, name: $3}; }
    | expr '[' expr ']'
        { $$ = {type: "array-get", expr: $1, "array": $3}; }
    | constant_value
        { $$ = $1; }
    | expr '&&' expr
        { $$ = {type: "binary", op: $2, lhs: $1, rhs: $3}; }
    | expr '||' expr
        { $$ = {type: "binary", op: $2, lhs: $1, rhs: $3}; }
    | expr '==' expr
        { $$ = {type: "binary", op: $2, lhs: $1, rhs: $3}; }
    | expr '!=' expr
        { $$ = {type: "binary", op: $2, lhs: $1, rhs: $3}; }
    | expr '$=' expr
        { $$ = {type: "binary", op: $2, lhs: $1, rhs: $3}; }
    | expr '!$=' expr
        { $$ = {type: "binary", op: $2, lhs: $1, rhs: $3}; }
    | expr '<' expr
        { $$ = {type: "binary", op: $2, lhs: $1, rhs: $3}; }
    | expr '>' expr
        { $$ = {type: "binary", op: $2, lhs: $1, rhs: $3}; }
    | expr '<=' expr
        { $$ = {type: "binary", op: $2, lhs: $1, rhs: $3}; }
    | expr '>=' expr
        { $$ = {type: "binary", op: $2, lhs: $1, rhs: $3}; }
    | expr '+' expr
        { $$ = {type: "binary", op: $2, lhs: $1, rhs: $3}; }
    | expr '-' expr
        { $$ = {type: "binary", op: $2, lhs: $1, rhs: $3}; }
    | expr '*' expr
        { $$ = {type: "binary", op: $2, lhs: $1, rhs: $3}; }
    | expr '/' expr
        { $$ = {type: "binary", op: $2, lhs: $1, rhs: $3}; }
    | expr '%' expr
        { $$ = {type: "binary", op: $2, lhs: $1, rhs: $3}; }
    | expr '@' expr
        { $$ = {type: "binary", op: $2, lhs: $1, rhs: $3}; }
    | expr 'SPC' expr
        { $$ = {type: "binary", op: $2, lhs: $1, rhs: $3}; }
    | expr 'TAB' expr
        { $$ = {type: "binary", op: $2, lhs: $1, rhs: $3}; }
    | expr 'NL' expr
        { $$ = {type: "binary", op: $2, lhs: $1, rhs: $3}; }
    | expr '..' expr
        /* {
            $$ = {
                type: "call",
                name: "range",
                args: [$1, $3],
                inclusive: false
            };
        } */
        {
            $$ = {
                type: "range",
                min: $1,
                max: $3,
                inclusive: false
            };
        }
    | expr '...' expr
        {
            $$ = {
                type: "range",
                min: $1,
                max: $3,
                inclusive: true
            };
        }
        /* {
            $$ = {
                type: "call",
                name: "range",
                args: [
                    $1,
                    {
                        type: "binary",
                        op: "+",
                        lhs: $3,
                        rhs: {
                            type: "constant",
                            "what": "integer",
                            "value": "1"
                        }
                    }
                ]
            };
        } */
    | '-' expr  %prec UNARY
        { $$ = {type: "unary", op: $1, expr: $2}; }
    | '!' expr  %prec UNARY
        { $$ = {type: "unary", op: $1, expr: $2}; }
    | '~' expr  %prec UNARY
        { $$ = {type: "unary", op: $1, expr: $2}; }
    ;

constant_value
    // Primitive type
    : 'integer'
        { $$ = {type: "constant", what: "integer", value: $1}; }
    | 'float'
        { $$ = {type: "constant", what: "float", value: $1}; }
    | 'string'
        { $$ = {type: "constant", what: "string", value: $1.substring(1, $1.length-1)}; }
    | 'tagged_string'
        { $$ = {type: "constant", what: "tagged_string", value: $1.substring(1, $1.length-1)}; }
    | 'boolean'
        { $$ = {type: "constant", what: "boolean", value: $1}; }
    // Sugar constructors
    | 'fn' '(' ')' block
        { $$ = {type: "lambda", args: [], body: $4}; }
    | 'fn' '(' ident_list ')' block
        { $$ = {type: "lambda", args: $3, body: $5}; }
    | var_local '=>' expr
        { $$ = {type: "lambda", args: [$1], body: [{type: "return-stmt", expr: $3}]}; }
    | '(' ')' '=>' expr
        { $$ = {type: "lambda", args: [], body: [{type: "return-stmt", expr: $4}]}; }
    // FIXME:
    // replacing '<' '>' with '(' ')' as intended causes reduce/reduce conflict
    // using <> instead is just a temporary hack
    | '<' ident_list '>' '=>' expr
        { $$ = {type: "lambda", args: $2, body: [{type: "return-stmt", expr: $5}]}; }
    | '[' expr_list ']'
        { $$ = {type: "create-vec", values: $2}; }
    | '{' map_pair_list '}'
        { $$ = {type: "create-map", pairs: $2}; }
    ;

map_pair_list
    // // conflict
    :
        { $$ = []; }
    // | map_pair
    //     { $$ = [$1]; }
    | map_pair
        { $$ = [$1]; }
    | map_pair_list ',' map_pair
        { $$ = $1; $1.push($3); }
    ;

map_pair
    // : '[' expr ']' ':' expr
    //     { $$ = [$2, $4]; }
    : var_local ':' expr
        { $$ = [{type: "constant", what: "string", value: $1}, $3]; }
    | 'string' ':' expr
        { $$ = [{type: "constant", what: "string", value: $1.substring(1, $1.length-1)}, $3]; }
    ;

stmt_expr
    : var '=' expr
        { $$ = {type: "assign", "var": $1, rhs: $3}; }
    | var '++'
        { $$ = {type: "unary-assign", "var": $1, op: $2}; }
    | var '--'
        { $$ = {type: "unary-assign", "var": $1, op: $2}; }
    | expr '.' var_local '=' expr
        { $$ = {type: "field-set", expr: $1, name: $3, rhs: $5}; }
    | expr '[' expr ']' '=' expr
        { $$ = {type: "array-set", expr: $1, "array": $3, rhs: $6}; }
    // | 'macro_name' '(' ')'
    //     { $$ = {type: "macro-call", name: $1, args: []}; }
    | 'macro_name' '(' expr_list ')'
        { $$ = {type: "macro-call", name: $1, args: $3}; }
    // | var_local '(' ')'
    //     { $$ = {type: "call", name: $1, args: []}; }
    | var_local '(' expr_list ')'
        { $$ = {type: "call", name: $1, args: $3}; }
    // | var_local '::' var_local '(' ')'
    //     { $$ = {type: "call", name: $3, "scope": $1, args: []}; }
    | var_local '::' var_local '(' expr_list ')'
        { $$ = {type: "call", name: $3, scope: $1, args: $5}; }
    // | expr '.' var_local '(' ')'
    //     { $$ = {type: "call", name: $3, "target": $1, args: []}; }
    | expr '.' var_local '(' expr_list ')'
        { $$ = {type: "call", name: $3, target: $1, args: $5}; }
    | ts_fence
        { $$ = {type: "ts-fence-expr", code: $1.substring(1, $1.length-1)}; }
    | 'new' var_local '(' expr_list ')'
        { $$ = {type: "new-object", class: $2, args: $4}; }
    | 'new' 'class' var_local '(' expr_list ')'
        { $$ = {type: "call", name: $3, args: $5}; }
    ;

var
    : var_local
        { $$ = {type: "variable", global: false, name: $1}; }
    | var_global
        { $$ = {type: "variable", global: true, name: $1.substr(1)}; }
    ;
