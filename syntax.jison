%left '['
%right '%=' '&=' '^=' '+=' '-=' '*=' '/=' '|=' '<<=' '>>=' '='
%right '=>'
%left '?' ':'
%left '||'
%left '&&'
%left '|'
%left '^'
%left '&'
%left '==' '!='
%left '<' '<=' '>' '>='
%left '..' '...' '@'
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
    | 'package' var_local block_fn_only
        { $$ = {"type": "package-decl", "name": $2, "body": $3, "active": false}; }
    | 'active' 'package' var_local block_fn_only
        { $$ = {"type": "package-decl", "name": $3, "body": $4, "active": true}; }
    ;

fn_decl
    : 'fn' var_local '(' ident_list ')' block
        { $$ = {"type": "fn-stmt", "name": $2, "args": $4, "body": $6}; }
    | 'fn' var_local '(' ')' block
        { $$ = {"type": "fn-stmt", "name": $2, "args": [], "body": $5}; }
    | 'fn' var_local block
        { $$ = {"type": "fn-stmt", "name": $2, "args": [], "body": $3}; }

    // extreme sugar activate
    | 'fn' '/' var_local '(' ident_list ')' block
        {
            $5.unshift("client");
            $$ = {"type": "fn-stmt", "name": "serverCmd" + $3, "args": $5, "body": $7}; }
        }
    | 'fn' '/' var_local '(' ')' block
        { $$ = {"type": "fn-stmt", "name": "serverCmd" + $3, "args": ["client"], "body": $6}; }
    | 'fn' '/' var_local block
        { $$ = {"type": "fn-stmt", "name": "serverCmd" + $3, "args": ["client"], "body": $4}; }
    ;

fn_decl_list
    : fn_decl
        { $$ = [$1]; }
    | fn_decl_list fn_decl
        { $$ = $1; $1.push($2); }
    ;

block
    : '{' '}'
        { $$ = []; }
    | '{' stmt_list '}'
        { $$ = $2; }
    ;

block_fn_only
    : '{' '}'
        { $$ = []; }
    | '{' fn_decl_list '}'
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
        { $$ = {"type": "expr-stmt", "expr": $1}; }
    | 'return' ';'
        { $$ = {"type": "return-stmt", "expr": null}; }
    | 'return' expr ';'
        { $$ = {"type": "return-stmt", "expr": $2}; }
    | 'break' ';'
        { $$ = {"type": "break-stmt"}; }
    | 'continue' ';'
        { $$ = {"type": "continue-stmt"}; }
    | if_stmt
        { $$ = $1; }
    | 'for' var 'in' expr block
        { $$ = {"type": "foreach-stmt", "bind": $2, "iter": $4, "body": $5}; }
    | 'for' '(' var 'in' ')' expr block
        { $$ = {"type": "foreach-stmt", "bind": $2, "iter": $4, "body": $5}; }
    | 'while' expr block
        { $$ = {"type": "while-stmt", "cond": $2, "body": $3}; }
    | 'loop' block
        { $$ = {"type": "loop-stmt", "body": $2}; }
    ;

if_stmt
    : 'if' expr block 'else' if_stmt
        { $$ = {"type": "if-stmt", "cond": $2, "body": $3, "else": $5}; }
    | 'if' expr block 'else' block
        { $$ = {"type": "if-stmt", "cond": $2, "body": $3, "else": $5}; }
    | 'if' expr block
        { $$ = {"type": "if-stmt", "cond": $2, "body": $3, "else": null}; }
    ;

ident_list
    : var_local
        { $$ = [$1]; }
    | ident_list ',' var_local
        { $$ = $1; $1.push($3); }
    ;

expr_list_opt
    :
        { $$ = []; }
    | expr_list
        { $$ = $1; }
    ;

expr_list
    : expr
        { $$ = [$1]; }
    | expr_list ',' expr
        { $$ = $1; $1.push($3); }
    ;

expr
    : stmt_expr
        { $$ = $1; }
    | '(' expr ')'
        //{ $$ = $2; }
        { $$ = {"type": "expr-expr", "expr": $2}; }
    | var
        { $$ = $1; }
    | '@' var_local
        { $$ = {"type": "identifier", "name": $2}; }
    | expr '.' var_local
        { $$ = {"type": "field-get", "expr": $1, "name": $3}; }
    | expr '[' expr ']'
        { $$ = {"type": "array-get", "expr": $1, "array": $3}; }
    | 'integer'
        { $$ = {"type": "constant", "what": "integer", "value": $1}; }
    | 'float'
        { $$ = {"type": "constant", "what": "float", "value": $1}; }
    | 'string'
        { $$ = {"type": "constant", "what": "string", "value": $1}; }
    | 'boolean'
        { $$ = {"type": "constant", "what": "boolean", "value": $1}; }
    | expr '==' expr
        { $$ = {"type": "binary", "op": $2, "lhs": $1, "rhs": $3}; }
    | expr '!=' expr
        { $$ = {"type": "binary", "op": $2, "lhs": $1, "rhs": $3}; }
    | expr '<' expr
        { $$ = {"type": "binary", "op": $2, "lhs": $1, "rhs": $3}; }
    | expr '>' expr
        { $$ = {"type": "binary", "op": $2, "lhs": $1, "rhs": $3}; }
    | expr '<=' expr
        { $$ = {"type": "binary", "op": $2, "lhs": $1, "rhs": $3}; }
    | expr '>=' expr
        { $$ = {"type": "binary", "op": $2, "lhs": $1, "rhs": $3}; }
    | expr '+' expr
        { $$ = {"type": "binary", "op": $2, "lhs": $1, "rhs": $3}; }
    | expr '-' expr
        { $$ = {"type": "binary", "op": $2, "lhs": $1, "rhs": $3}; }
    | expr '*' expr
        { $$ = {"type": "binary", "op": $2, "lhs": $1, "rhs": $3}; }
    | expr '/' expr
        { $$ = {"type": "binary", "op": $2, "lhs": $1, "rhs": $3}; }
    | expr '%' expr
        { $$ = {"type": "binary", "op": $2, "lhs": $1, "rhs": $3}; }
    | expr '@' expr
        { $$ = {"type": "binary", "op": $2, "lhs": $1, "rhs": $3}; }
    | expr '..' expr
        {
            $$ = {
                "type": "call",
                "name": "range",
                "args": [$1, $3]
            };
        }
    | expr '...' expr
        {
            $$ = {
                "type": "call",
                "name": "range",
                "args": [
                    $1,
                    {
                        "type": "binary",
                        "op": "+",
                        "lhs": $3,
                        "rhs": {
                            "type": "constant",
                            "what": "integer",
                            "value": "1"
                        }
                    }
                ]
            };
        }
    | '-' expr  %prec UNARY
        { $$ = {"type": "unary", "op": $1, "expr": $2}; }
    | '~' expr  %prec UNARY
        { $$ = {"type": "unary", "op": $1, "expr": $2}; }
    // Sugar constructors
    | var_local '=>' block
        { $$ = {type: "lambda", "args": [$1], "body": $3}; }
    | '(' ')' '=>' block
        { $$ = {type: "lambda", "args": [], "body": $4}; }
    // | '(' ident_list ')' '=>' block
    //     { $$ = {type: "lambda", "args": $2, "body": $5}; }
    | var_local '=>' expr
        { $$ = {type: "lambda", "args": [$1], "body": [{"type": "return-stmt", "expr": $3}]}; }
    | '(' ')' '=>' expr
        { $$ = {type: "lambda", "args": [], "body": [{"type": "return-stmt", "expr": $4}]}; }
    // | '(' ident_list ')' '=>' expr
    //     { $$ = {type: "lambda", "args": $2, "body": [{"type": "return-stmt", "expr": $5}]}; }
    | '[' expr_list_opt ']'
        { $$ = {"type": "create-vec", "values": $2}; }
    ;

stmt_expr
    : var '=' expr
        { $$ = {"type": "assign", "var": $1, "rhs": $3}; }
    | expr '.' var_local '=' expr
        { $$ = {"type": "field-set", "expr": $1, "name": $3, "rhs": $5}; }
    | expr '[' expr ']' '=' expr
        { $$ = {"type": "array-set", "expr": $1, "array": $3, "rhs": $6}; }
    | 'macro_name' '(' ')'
        { $$ = {"type": "macro-call", "name": $1, "args": []}; }
    | 'macro_name' '(' expr_list ')'
        { $$ = {"type": "macro-call", "name": $1, "args": $3}; }
    | var_local '(' ')'
        { $$ = {"type": "call", "name": $1, "args": []}; }
    | var_local '(' expr_list ')'
        { $$ = {"type": "call", "name": $1, "args": $3}; }
    | var_local '::' var_local '(' ')'
        { $$ = {"type": "call", "name": $3, "scope": $1, "args": []}; }
    | var_local '::' var_local '(' expr_list ')'
        { $$ = {"type": "call", "name": $3, "scope": $1, "args": $5}; }
    | expr '.' var_local '(' ')'
        { $$ = {"type": "call", "name": $3, "target": $1, "args": []}; }
    | expr '.' var_local '(' expr_list ')'
        { $$ = {"type": "call", "name": $3, "target": $1, "args": $5}; }
    | ts_fence
        { $$ = {"type": "ts-fence-expr", "code": $1.substring(1, $1.length-1)}; }
    ;

var
    : var_local
        { $$ = {"type": "variable", "global": false, "name": $1}; }
    | var_global
        { $$ = {"type": "variable", "global": true, "name": $1.substr(1)}; }
    ;
