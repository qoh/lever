%right '='
%right UNARY
%left '..'
%left '==' '!='
%left '<' '<=' '>' '>='
%left '+' '-'
%left '*' '/' '%'
%right '!' '~' UNARY

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
    | 'fn' var_local '(' ident_list ')' block
        { $$ = {"type": "fn-stmt", "name": $2, "args": $4, "body": $6}; }
    | 'fn' var_local '(' ')' block
        { $$ = {"type": "fn-stmt", "name": $2, "args": [], "body": $5}; }
    | 'fn' var_local block
        { $$ = {"type": "fn-stmt", "name": $2, "args": [], "body": $3}; }
    ;

block
    : '{' '}'
        { $$ = []; }
    | '{' stmt_list '}'
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
    | if_stmt
        { $$ = $1; }
    | 'for' var 'in' expr block
        { $$ = {"type": "foreach-stmt", "bind": $2, "iter": $4, "body": $5}; }
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
        { $$ = $2; }
    | var
        { $$ = $1; }
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
    | expr '..' expr
        {
            $$ = {
                "type": "call",
                "name": "range",
                "args": [
                    $1, $3
                ]
            };
        }
    | '-' expr  %prec UNARY
        { $$ = {"type": "unary", "op": $1, "expr": $2}; }
    | '~' expr  %prec UNARY
        { $$ = {"type": "unary", "op": $1, "expr": $2}; }
    ;

stmt_expr
    : var_local '(' ')'
        { $$ = {"type": "call", "name": $1, "args": []}; }
    | var_local '(' expr_list ')'
        { $$ = {"type": "call", "name": $1, "args": $3}; }
    ;

var
    : var_local
        { $$ = {"type": "variable", "global": false, "name": $1}; }
    | var_global
        { $$ = {"type": "variable", "global": true, "name": $1.substr(1)}; }
    ;
