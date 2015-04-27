%left '[' '{'
%right '%=' '&=' '^=' '+=' '-=' '*=' '/=' '|=' '<<=' '>>=' '='
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

start: top-list EOF { return $1; };
top-list: top { $$ = [$1]; } | top-list top { $$ = $1; $$.push($2); };
top
    : stmt
    | decl-func
    | decl-datablock
    | decl-package
    | decl-class
    ;

// ----------------------------
// Declarations

// Functions
decl-func
    : decl-func-plain
    | fn name '::' name fn-args fn-type '{' stmt-list '}'
        { $$ = {type: "fn-stmt", name: $2 + $3 + $4, args: $5, ret: $6, body: $8}; }
    ;
decl-func-plain
    : fn name fn-args fn-type '{' stmt-list '}'
        { $$ = {type: "fn-stmt", name: $2, args: $3, ret: $4, body: $6}; }
    | fn '/' name fn-args fn-type '{' stmt-list '}'
        { $$ = {type: "fn-stmt", name: "serverCmd" + $3, args: $4, ret: $5, body: $7}; }
    ;
fn-args: { $$ = []; } | '(' fn-arg-list ')' { $$ = $2; };
fn-type: { $$ = null; } | '->' name { $$ = $2; };
fn-arg
    : name
        { $$ = {name: $1}; }
    | name '=' expr
        { $$ = {name: $1, auto: $3}; }
    | name name
        { $$ = {type: $1, name: $2}; }
    | name name '=' expr
        { $$ = {type: $1, name: $2, auto: $4}; }
    ;
fn-arg-list-r
    : fn-arg
        { $$ = [$1]; }
    | fn-arg-list-r ',' fn-arg
        { $$ = $1; $$.push($3); }
    ;
fn-arg-list: { $$ = []; } | fn-arg-list-r;

// Datablocks
decl-datablock
    : 'datablock' name name '{' decl-datablock-pair-list '}'
        { $$ = {type: "datablock-decl", datatype: $2, name: $3, inherit: undefined, body: $5}; }
    | 'datablock' name name ':' name '{' decl-datablock-pair-list '}'
        { $$ = {type: "datablock-decl", datatype: $2, name: $3, inherit: $5, body: $7}; }
    ;
decl-datablock-pair
    : 'state' name '{' map-pair-list '}'
        { $$ = { type: "state-decl", name: $2, data: $4 }; }
    | map-pair
        { $$ = $1; }
    ;
decl-datablock-pair-list-r
    : decl-datablock-pair
        { $$ = [$1]; }
    | decl-datablock-pair-list-r ',' decl-datablock-pair
        { $$ = $1; $1.push($3); }
    ;
decl-datablock-pair-list: { $$ = []; } | decl-datablock-pair-list-r;

// Packages
decl-package
    : package name '{' package-item-list '}'
        { $$ = {type: "package-decl", name: $2, body: $4, active: false}; }
    | active package name '{' package-item-list '}'
        { $$ = {type: "package-decl", name: $3, body: $5, active: true}; }
    ;
package-item
    : decl-func
    | decl-class // Consider using simplified version
    ;
package-item-list
    :
        { $$ = []; }
    | package-item-list package-item
        { $$ = $1; $$.push($2); }
    ;

// Classes
decl-class
    : class name '{' class-item-list '}'
        { $$ = {type: "class-decl", name: $2, body: $4, static: false}; }
    | class name ':' name '{' class-item-list '}'
        { $$ = {type: "class-decl", name: $2, parent: $4, body: $6, static: false}; }
    | static class name '{' class-item-list '}'
        { $$ = {type: "class-decl", name: $3, body: $5, static: true}; }
    | static class name ':' name '{' class-item-list '}'
        { $$ = {type: "class-decl", name: $3, parent: $5, body: $7, static: true}; }
    ;
class-item
    : decl-func-plain
    | name '=' expr ';'
        { $$ = {type: "assign", var: $1, rhs: $3}; }
    ;
class-item-list
    :
        { $$ = []; }
    | class-item-list class-item
        { $$ = $1; $$.push($2); }
    ;

// ----------------------------
// Statements

stmt
    : expr-stmt ';'
        { $$ = {type: "expr-stmt", expr: $1}; }
    | 'use' expr ';'
        { $$ = {type: "use-stmt", file: $2}; }
    | 'return' ';'
        { $$ = {type: "return-stmt", expr: null}; }
    | 'return' expr ';'
        { $$ = {type: "return-stmt", expr: $2}; }
    | 'return' expr ',' expr-list-r ';'
        { $$ = {type: "return-stmt", expr: $2, rest: $4}; }
    | 'break' ';'
        { $$ = {type: "break-stmt"}; }
    | 'continue' ';'
        { $$ = {type: "continue-stmt"}; }
    // Causes conflict
    // | name ',' name-list-r '=' expr-call
    //     { $$ = {type: "read-multi-return", name: $1, rest: $3, call: $5}; }
    | stmt-if
    | 'match' expr '{' match-pair-list-r '}'
        { $$ = {type: "match-decl", variate: $2, body: $4}; }
    | 'for' expr ';' expr ';' expr '{' stmt-list '}'
        { $$ = {type: "for-stmt", init: $2, test: $4, step: $6, body: $8}; }
    | 'for' var 'in' expr '{' stmt-list '}'
        { $$ = {type: "foreach-stmt", bind: $2, iter: $4, body: $6}; }
    | 'for' var ',' name-list-r 'in' expr '{' stmt-list '}'
        { $$ = {type: "foreach-stmt", bind: $2, rest: $4, iter: $6, body: $8}; }
    | 'while' expr '{' stmt-list '}'
        { $$ = {type: "while-stmt", "cond": $2, body: $4}; }
    | 'loop' '{' stmt-list '}'
        { $$ = {type: "loop-stmt", body: $3}; }
    ;
stmt-list
    :
        { $$ = []; }
    | stmt-list stmt
        { $$ = $1; $$.push($2); }
    ;

stmt-if
    : 'if' expr '{' stmt-list '}' 'else' stmt-if
        { $$ = {type: "if-stmt", "cond": $2, body: $4, "else": $7}; }
    | 'if' expr '{' stmt-list '}' 'else' '{' stmt-list '}'
        { $$ = {type: "if-stmt", "cond": $2, body: $4, "else": $8}; }
    | 'if' expr '{' stmt-list '}'
        { $$ = {type: "if-stmt", "cond": $2, body: $4, "else": null}; }
    ;

match-pair
    : constant ':' '{' stmt-list '}'
        { $$ = [{ key: $1, value: $4 }]}
    | constant 'or' constant ':' '{' stmt-list '}'
        { $$ = [{ key: $1, value: $6}, { key: $3, value: $6}]; }
    ;
match-pair-list-r
    : match_pair
        { $$ = [$1]; }
    | match_pair_list-r ',' match_pair
        { $$ = $1; $1.push($3); }
    ;

// ----------------------------
// Expressions

expr
    : expr-stmt
    | constant
    | var
    | '(' expr ')'
        { $$ = {type: "expr-expr", expr: $2}; }
    | '@' name
        { $$ = {type: "identifier", name: $2}; }
    | expr '.' name
        { $$ = {type: "field-get", expr: $1, name: $3}; }
    | expr '[' expr ']'
        { $$ = {type: "array-get", expr: $1, "array": $3}; }
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
    | expr '^' expr
        { $$ = {type: "binary", op: $2, lhs: $1, rhs: $3}; }
    | expr '|' expr
        { $$ = {type: "binary", op: $2, lhs: $1, rhs: $3}; }
    | expr '&' expr
        { $$ = {type: "binary", op: $2, lhs: $1, rhs: $3}; }
    | expr '<<' expr
        { $$ = {type: "binary", op: $2, lhs: $1, rhs: $3}; }
    | expr '>>' expr
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
        { $$ = {type: "range", min: $1, max: $3, inclusive: false}; }
    | expr '...' expr
        { $$ = {type: "range", min: $1, max: $3, inclusive: true}; }
    | '-' expr  %prec UNARY
        { $$ = {type: "unary", op: $1, expr: $2}; }
    | '!' expr  %prec UNARY
        { $$ = {type: "unary", op: $1, expr: $2}; }
    | '~' expr  %prec UNARY
        { $$ = {type: "unary", op: $1, expr: $2}; }
    ;
expr-stmt
    : var '=' expr
        { $$ = {type: "binary-assign", var: $1, op: $2, rhs: $3}; }
    | var '++'
        { $$ = {type: "unary-assign", var: $1, op: $2}; }
    | var '--'
        { $$ = {type: "unary-assign", var: $1, op: $2}; }
    | expr '.' name '=' expr
        { $$ = {type: "field-set", expr: $1, name: $3, rhs: $5}; }
    | expr '.' name '++'
        { $$ = {type: "unary-field-set", expr: $1, name: $3, op: $4}; }
    | expr '.' name '--'
        { $$ = {type: "unary-field-set", expr: $1, name: $3, op: $4}; }
    | expr '[' expr ']' '=' expr
        { $$ = {type: "array-set", expr: $1, "array": $3, rhs: $6}; }
    | expr-call
    | ts_fence
        { $$ = {type: "ts-fence-expr", code: $1.substring(1, $1.length-1)}; }
    //| 'new' name '(' expr-list ')'
    //    { $$ = {type: "new-object", class: $2, args: $4, block: undefined}; }
    | 'new' name '(' expr-list ')' '{' map-pair-list '}'
        { $$ = {type: "new-object", class: $2, args: $4, block: $7}; }
    ;
expr-call
    : name '(' expr-list ')'
        { $$ = {type: "call", name: $1, args: $3}; }
    | name '::' name '(' expr-list ')'
        { $$ = {type: "call", name: $3, scope: $1, args: $5}; }
    | expr '.' name '(' expr-list ')'
        { $$ = {type: "call", name: $3, target: $1, args: $5}; }
    | expr '!' '(' expr-list ')'
        { $$ = {type: "call-expr", expr: $1, args: $4}; }
    ;
expr-list-r
    : expr
        { $$ = [$1]; }
    | expr-list-r ',' expr
        { $$ = $1; $$.push($3); }
    ;
expr-list: { $$ = []; } | expr-list-r;

constant
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
    // Causes conflict
    // | '(' name-list ')' '->' expr
    //     { $$ = {type: "lambda", args: $2, body: {type: "return-stmt", expr: $5}}; }
    | 'fn' '(' name-list ')' '{' stmt-list '}'
        { $$ = {type: "lambda", args: $3, body: $6}; }
    | '[' expr-list ']'
        { $$ = {type: "create-vec", values: $2}; }
    | '{' map-pair-list '}'
        { $$ = {type: "create-map", pairs: $2}; }
    ;

map-pair
    : name ':' expr
        { $$ = [{type: "constant", what: "string", value: $1}, $3]; }
    | 'string' ':' expr
        { $$ = [{type: "constant", what: "string", value: $1.substring(1, $1.length-1)}, $3]; }
    ;
map-pair-list-r
    : map-pair
        { $$ = [$1]; }
    | map-pair-list-r ',' map-pair
        { $$ = $1; $$.push($3); }
    ;
map-pair-list: { $$ = []; } | map-pair-list-r;

name-list-r
    : name
        { $$ = [$1]; }
    | name-list-r ',' name
        { $$ = $1; $$.push($3); }
    ;
name-list: { $$ = []; } | name-list-r;

var
    : name
        { $$ = {type: "variable", global: false, name: $1}; }
    | global
        { $$ = {type: "variable", global: true, name: $1.substr(1)}; }
    ;
