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

start: top-list EOF { return $1; };
top-list: top { $$ = [$1]; } | top-list top { $1.push($2); $$ = $1; };
top
    : stmt
    | decl-func
    | class_decl
    | datablock_decl
    | 'package' name block_fn_class_only
        { $$ = {type: "package-decl", name: $2, body: $3, active: false}; }
    | 'active' 'package' name block_fn_class_only
        { $$ = {type: "package-decl", name: $3, body: $4, active: true}; }
    ;

// ----------------------------
// Declarations

decl-func: decl-func-plain | decl-func-scope;
decl-func-list-req
    : decl-func
        { $$ = [$1]; }
    | decl-func-list-req decl-func
        { $1.push($2); $$ = $1; }
    ;
decl-func-list: { $$ = []; } | decl-func-list-req;
decl-func-plain
    : 'fn' name '(' decl-func-arg-list ')' '{' stmt-star '}'
        { $$ = {type: "fn-stmt", name: $2, args: $4, body: $7}; }
    | 'fn' name '{' stmt-star '}'
        { $$ = {type: "fn-stmt", name: $2, args: [], body: $4}; }
    | 'fn' '/' name '(' decl-func-arg-list ')' '{' stmt-star '}'
        {
            $5.unshift({name: "client"});
            $$ = {type: "fn-stmt", name: "serverCmd" + $3, args: $5, body: $8}; }
        }
    | 'fn' '/' name '{' stmt-star '}'
        { $$ = {type: "fn-stmt", name: "serverCmd" + $3, args: [{name: "client"}], body: $5}; }
    ;
decl-func-scope
    : 'fn' name '::' name '(' decl-func-arg-list ')' '{' stmt-star '}'
        { $$ = {type: "fn-stmt", name: $2 + $3 + $4, args: $6, body: $9}; }
    | 'fn' name '::' name '{' stmt-star '}'
        { $$ = {type: "fn-stmt", name: $2 + $3 + $4, args: [], body: $6}; }
    ;
decl-func-plain-list-req
    : decl-func-plain
        { $$ = [$1]; }
    | decl-func-plain-list-req decl-func-plain
        { $1.push($2); $$ = $1; }
    ;
decl-func-plain-list: { $$ = []; } | decl-func-plain-list-req;
decl-func-arg
    : name
        { $$ = {name: $1}; }
    | name '=' expr
        { $$ = {name: $1, auto: $3}; }
    | name name
        { $$ = {type: $1, name: $2}; }
    | name name '=' expr
        { $$ = {type: $1, name: $2, auto: $4}; }
    ;
decl-func-arg-list-req
    : decl-func-arg
        { $$ = [$1]; }
    | decl-func-arg-list-req ',' decl-func-arg
        { $$ = $1; $1.push($3); }
    ;
decl-func-arg-list: { $$ = []; } | decl-func-arg-list-req;

fn_decl_list: decl-func-list;

fn_assign_decl_list
    : decl-func
        { $$ = [$1]; }
    | name '=' expr ';'
        { $$ = [{type: "assign", var: $1, rhs: $3}]; }
    | fn_assign_decl_list decl-func
        { $$ = $1; $1.push($2); }
    | fn_assign_decl_list name '=' expr ';'
        { $$ = $1; $1.push({type: "assign", var: $2, rhs: $4}); }
    ;

fn_class_decl_list
    : decl-func
        { $$ = [$1]; }
    | class_decl
        { $$ = [$1]; }
    | fn_class_decl_list decl-func
        { $$ = $1; $1.push($2); }
    | fn_class_decl_list class_decl
        { $$ = $1; $1.push($2); }
    ;

class_decl
    : 'static_class' name '{' class-item-star '}'
        { $$ = {type: "class-decl", name: $2, body: $4, static: true}; }
    | 'class' name '{' class-item-star '}'
        { $$ = {type: "class-decl", name: $2, body: $4}; }
    | 'class' name ':' name '{' class-item-star '}'
        { $$ = {type: "class-decl", name: $2, parent: $4, body: $6}; }
    ;
class-item
    : decl-func-plain
    | name '=' expr ';'
        { $$ = {type: "assign", var: $1, rhs: $3}; }
    ;
class-item-plus
    : class-item { $$ = [$1]; }
    | class-item-plus class-item { $1.push($2); $$ = $1; }
    ;
class-item-star: { $$ = []; } | class-item-plus;

datablock_decl
    : 'datablock' name name '{' datablock_pair_list '}'
        { $$ = {type: "datablock-decl", datatype: $2, name: $3, body: $5}; }
    ;

datablock_pair_list
    : datablock_pair
        { $$ = [$1]; }
    | datablock_pair_list ',' datablock_pair
        { $$ = $1; $1.push($3); }
    ;

datablock_pair
    : 'state' name '{' map-pair-list '}'
        { $$ = { type: "state-decl", name: $2, data: $4 }; }
    | map_pair
    ;

block_fn_class_only
    : '{' '}'
        { $$ = []; }
    | '{' fn_class_decl_list '}'
        { $$ = $2; }
    ;

// ----------------------------
// Statements

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
    | 'for' expr ';' expr ';' expr '{' stmt-star '}'
        { $$ = {type: "for-stmt", init: $2, test: $4, step: $6, body: $8}; }
    | 'for' var 'in' expr '{' stmt-star '}'
        { $$ = {type: "foreach-stmt", "bind": $2, "iter": $4, body: $6}; }
    | 'while' expr '{' stmt-star '}'
        { $$ = {type: "while-stmt", "cond": $2, body: $4}; }
    | 'loop' '{' stmt-star '}'
        { $$ = {type: "loop-stmt", body: $3}; }
    | 'match' expr '{' match_pair_list '}'
        { $$ = {type: "match-decl", variate: $2, body: $4}; }
    ;
stmt-plus
    : stmt { $$ = [$1]; }
    | stmt-plus stmt { $1.push($2); $$ = $1 }
    ;
stmt-star: { $$ = []; } | stmt-plus;

if_stmt
    : 'if' expr '{' stmt-star '}' 'else' if_stmt
        { $$ = {type: "if-stmt", "cond": $2, body: $4, "else": $7}; }
    | 'if' expr '{' stmt-star '}' 'else' '{' stmt-star '}'
        { $$ = {type: "if-stmt", "cond": $2, body: $4, "else": $8}; }
    | 'if' expr '{' stmt-star '}'
        { $$ = {type: "if-stmt", "cond": $2, body: $4, "else": null}; }
    ;

match_pair_list
    : match_pair
        { $$ = [$1]; }
    | match_pair_list ',' match_pair
        { $$ = $1; $1.push($3); }
    ;
match_pair
    : constant ':' '{' stmt-star '}'
        { $$ = [{ key: $1, value: $4 }]}
    | constant 'or' constant ':' '{' stmt-star '}'
        { $$ = [{ key: $1, value: $6}, { key: $3, value: $6}]; }
    ;

ident-list: name { $$ = [$1]; } | ident-list ',' name { $1.push($3); $$ = $1; };
ident-list-opt: { $$ = []; } | ident-list;

// ----------------------------
// Expressions

expr-list-req
    : expr
        { $$ = [$1]; }
    | expr-list-req ',' expr
        { $1.push($3); $$ = $1; }
    ;
expr-list: { $$ = []; } | expr-list-req;

expr
    : stmt_expr
    | '(' expr ')'
        { $$ = {type: "expr-expr", expr: $2}; }
    | var
    | '@' name
        { $$ = {type: "identifier", name: $2}; }
    | expr '.' name
        { $$ = {type: "field-get", expr: $1, name: $3}; }
    | expr '[' expr ']'
        { $$ = {type: "array-get", expr: $1, "array": $3}; }
    | constant
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
    | '-' expr  %prec UNARY
        { $$ = {type: "unary", op: $1, expr: $2}; }
    | '!' expr  %prec UNARY
        { $$ = {type: "unary", op: $1, expr: $2}; }
    | '~' expr  %prec UNARY
        { $$ = {type: "unary", op: $1, expr: $2}; }
    ;

constant
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
    | 'fn' '(' ident-list-opt ')' '{' stmt-star '}'
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
map-pair-list-req
    : map-pair
        { $$ = [$1]; }
    | map-pair-list-req ',' map-pair
        { $1.push($3); $$ = $1; }
    ;
map-pair-list: { $$ = []; } | map-pair-list-req;

unary_assign_op: '++' | '--';
//this causes a massive shift/reduce conflict when used for binary-assign
binary_assign_op: '=' | '+=' | '-=' | '*=' | '/=' | '%=' | '^=' | '|=' | '&=' | '<<=' | '>>=';

stmt_expr
    // : var '=' expr
    //     { $$ = {type: "assign", "var": $1, rhs: $3}; }
    // | var '++'
    //     { $$ = {type: "unary-assign", "var": $1, op: $2}; }
    // | var '--'
    //     { $$ = {type: "unary-assign", "var": $1, op: $2}; }
    : var unary_assign_op
        { $$ = {type: "unary-assign", var: $1, op: $2}; }
    | var '=' expr // so i have to do this. oh god
        { $$ = {type: "binary-assign", var: $1, op: $2, rhs: $3}; }
    | var '+=' expr
        { $$ = {type: "binary-assign", var: $1, op: $2, rhs: $3}; }
    | var '-=' expr
        { $$ = {type: "binary-assign", var: $1, op: $2, rhs: $3}; }
    | var '*=' expr
        { $$ = {type: "binary-assign", var: $1, op: $2, rhs: $3}; }
    | var '/=' expr
        { $$ = {type: "binary-assign", var: $1, op: $2, rhs: $3}; }
    | var '%=' expr
        { $$ = {type: "binary-assign", var: $1, op: $2, rhs: $3}; }
    | var '^=' expr
        { $$ = {type: "binary-assign", var: $1, op: $2, rhs: $3}; }
    | var '|=' expr
        { $$ = {type: "binary-assign", var: $1, op: $2, rhs: $3}; }
    | var '&=' expr
        { $$ = {type: "binary-assign", var: $1, op: $2, rhs: $3}; }
    | var '<<=' expr
        { $$ = {type: "binary-assign", var: $1, op: $2, rhs: $3}; }
    | var '>>=' expr
        { $$ = {type: "binary-assign", var: $1, op: $2, rhs: $3}; }
    | expr '.' name '=' expr
        { $$ = {type: "field-set", expr: $1, name: $3, rhs: $5}; }
    | expr '.' name unary_assign_op
        { $$ = {type: "unary-field-set", expr: $1, name: $3, op: $4}; }
    | expr '.' name '+=' expr // fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
        { $$ = {type: "binary-field-set", expr: $1, name: $3, op: $4, rhs: $5}; }
    | expr '.' name '-=' expr
        { $$ = {type: "binary-field-set", expr: $1, name: $3, op: $4, rhs: $5}; }
    | expr '.' name '*=' expr
        { $$ = {type: "binary-field-set", expr: $1, name: $3, op: $4, rhs: $5}; }
    | expr '.' name '/=' expr
        { $$ = {type: "binary-field-set", expr: $1, name: $3, op: $4, rhs: $5}; }
    | expr '.' name '%=' expr
        { $$ = {type: "binary-field-set", expr: $1, name: $3, op: $4, rhs: $5}; }
    | expr '.' name '^=' expr
        { $$ = {type: "binary-field-set", expr: $1, name: $3, op: $4, rhs: $5}; }
    | expr '.' name '|=' expr
        { $$ = {type: "binary-field-set", expr: $1, name: $3, op: $4, rhs: $5}; }
    | expr '.' name '&=' expr
        { $$ = {type: "binary-field-set", expr: $1, name: $3, op: $4, rhs: $5}; }
    | expr '.' name '<<=' expr
        { $$ = {type: "binary-field-set", expr: $1, name: $3, op: $4, rhs: $5}; }
    | expr '.' name '>>=' expr
        { $$ = {type: "binary-field-set", expr: $1, name: $3, op: $4, rhs: $5}; }
    | expr '[' expr ']' '=' expr
        { $$ = {type: "array-set", expr: $1, "array": $3, rhs: $6}; }
    // | expr '[' expr ']' unary_assign_op
    //     { $$ = {type: "unary-array-set", expr: $1, "array": $3, op: $5}; }
    | expr '[' expr ']' '++'
        { $$ = {type: "binary-array-set", expr: $1, "array": $3, op: "+", rhs: {type: "constant", what: "integer", value: 1}}; }
    | expr '[' expr ']' '--'
        { $$ = {type: "binary-array-set", expr: $1, "array": $3, op: "-", rhs: {type: "constant", what: "integer", value: 1}}; }
    | expr '[' expr ']' '+=' expr // omgggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg
        { $$ = {type: "binary-array-set", expr: $1, "array": $3, op: $5.slice(0, -1), rhs: $6}; }
    | expr '[' expr ']' '-=' expr
        { $$ = {type: "binary-array-set", expr: $1, "array": $3, op: $5.slice(0, -1), rhs: $6}; }
    | expr '[' expr ']' '*=' expr
        { $$ = {type: "binary-array-set", expr: $1, "array": $3, op: $5.slice(0, -1), rhs: $6}; }
    | expr '[' expr ']' '/=' expr
        { $$ = {type: "binary-array-set", expr: $1, "array": $3, op: $5.slice(0, -1), rhs: $6}; }
    | expr '[' expr ']' '%=' expr
        { $$ = {type: "binary-array-set", expr: $1, "array": $3, op: $5.slice(0, -1), rhs: $6}; }
    | expr '[' expr ']' '^=' expr
        { $$ = {type: "binary-array-set", expr: $1, "array": $3, op: $5.slice(0, -1), rhs: $6}; }
    | expr '[' expr ']' '|=' expr
        { $$ = {type: "binary-array-set", expr: $1, "array": $3, op: $5.slice(0, -1), rhs: $6}; }
    | expr '[' expr ']' '&=' expr
        { $$ = {type: "binary-array-set", expr: $1, "array": $3, op: $5.slice(0, -1), rhs: $6}; }
    | expr '[' expr ']' '<<=' expr
        { $$ = {type: "binary-array-set", expr: $1, "array": $3, op: $5.slice(0, -1), rhs: $6}; }
    | expr '[' expr ']' '>>=' expr
        { $$ = {type: "binary-array-set", expr: $1, "array": $3, op: $5.slice(0, -1), rhs: $6}; }
    | name '(' expr-list ')'
        { $$ = {type: "call", name: $1, args: $3}; }
    | name '::' name '(' expr-list ')'
        { $$ = {type: "call", name: $3, scope: $1, args: $5}; }
    | expr '.' name '(' expr-list ')'
        { $$ = {type: "call", name: $3, target: $1, args: $5}; }
    | ts_fence
        { $$ = {type: "ts-fence-expr", code: $1.substring(1, $1.length-1)}; }
    | 'new' name '(' expr-list ')'
        { $$ = {type: "new-object", class: $2, args: $4}; }
    | 'new' 'class' name '(' expr-list ')'
        { $$ = {type: "call", name: $3, args: $5}; }
    ;

var
    : name
        { $$ = {type: "variable", global: false, name: $1}; }
    | global
        { $$ = {type: "variable", global: true, name: $1.substr(1)}; }
    ;
