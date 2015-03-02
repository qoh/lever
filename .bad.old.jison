%lex /* defines */

DIGIT    [0-9]
INTEGER  {DIGIT}+
FLOAT    ({INTEGER}\.{INTEGER})|({INTEGER}(\.{INTEGER})?[eE][+-]?{INTEGER})|(\.{INTEGER})|((\.{INTEGER})?[eE][+-]?{INTEGER})
LETTER   [A-Za-z_]
FILECHAR [A-Za-z_\.]
VARMID   [:A-Za-z0-9_]
IDTAIL   [A-Za-z0-9_]
VARTAIL  {VARMID}*{IDTAIL}
VAR      [$%]{LETTER}{VARTAIL}*
ID       {LETTER}{IDTAIL}*
ILID     [$%]{DIGIT}+{LETTER}{VARTAIL}*
FILENAME {FILECHAR}+
SPACE    [ \t\v\f]
HEXDIGIT [a-fA-F0-9]

ident    [_a-zA-Z][_a-zA-Z0-9]*

%%

\s+                     /* skip */
"//".*                  /* ignore comment */
"/*"[\w\W]*?"*/"        /* ignore comment */

"%"{ident}               return 'variable';
"$"{ident}("::"{ident})* return 'variable';

{ident}                 return 'identifier';
[0-9]+("."[0-9]+)?      return 'number';
// hex parsing
// exponents

"=="                    return '==';
"!="                    return '!=';
">="                    return '>=';
"<="                    return '<=';
"&&"                    return '&&';
"||"                    return '||';
"::"                    return '::';
"--"                    return '--';
"++"                    return '++';
"$="                    return '$=';
"!$="                   return '!$=';
"<<"                    return '<<';
">>"                    return '>>';
"+="                    return '+=';
"-="                    return '-=';
"*="                    return '*=';
"/="                    return '/=';
"%="                    return '%=';
"&="                    return '&=';
"^="                    return '^=';
"|="                    return '|=';
"<<="                   return '<<=';
">>="                   return '>>=';
"@"                    return '@';

"?"                     return '?';
"["                     return '[';
"]"                     return ']';
"("                     return '(';
")"                     return ')';
"+"                     return '+';
"-"                     return '-';
"*"                     return '*';
"/"                     return '/';
"<"                     return '<';
">"                     return '>';
"|"                     return '|';
"."                     return '.';
"!"                     return '!';
":"                     return ':';
";"                     return ';';
"{"                     return '{';
"}"                     return '}';
","                     return ',';
"&"                     return '&';
"%"                     return '%';
"^"                     return '^';
"~"                     return '~';
"="                     return '=';

"or"                    return 'or';
"break"                 return 'break';
"return"                return 'return';
"else"                  return 'else';
"while"                 return 'while';
"do"                    return 'do';
"if"                    return 'if';
"for"                   return 'for';
"continue"              return 'continue';
"function"              return 'function';
"new"                   return 'new';
"datablock"             return 'datablock';
"case"                  return 'case';
"switch$"               return yytext;
"switch"                return 'switch';
"default"               return 'default';
"package"               return 'package';
"namespace"             return 'namespace';
"true"                  ttt = 1; return 'INTCONST';
"false"                 ttt = 0; return 'INTCONST';

<<EOF>>               return 'EOF';
.                     return 'INVALID';

/lex

/* operator associations and precedence */
%left '+' '-'
%left '*' '/'
%left '^'
%right '!'
%right '%'
%left UMINUS

%left '['
%right '%=' '&=' '^=' '+=' '-=' '*=' '/=' '|=' '<<=' '>>=' '='
%left '?' ':'
%left '||'
%left '&&'
%left '|'
%left '^'
%left '&'
%left '==' '!='
%left '<' '<=' '>' '>='
%left '@' '$=' '!$='
%left '<<' '>>'
%left '+' '-'
%left '*' '/' '%'
%right '!' '~' '++' '--' UNARY
%left '.'

//%start decl_list
%start start

%% /* language grammar */

// decl_list
//     : decl_list decl
//         { $1.push($2); $$ = $1; }
//     | decl EOF
//         { return [$1]; }
//     ;
//
// decl
//     : statement
//         { $$ = $1; }
//     // | fn_decl_stmt
//     //     { $$ = $1; }
//     // | package_decl
//     //     { $$ = $1; }
//     ;
//
// statement
//     : 'return' ';'
//         { $$ = {"type": "return"}; }
//     | 'return' expr ';'
//         { $$ = {"type": "return", "expr": $2}; }
//     | expr ';'
//         { $$ = {"type": "stmt_expr", "expr": $1}; }
//     ;
//
// expr
//     : number
//         { $$ = {"type": "number", "value": parseInt($1)}; }
//     | variable '=' expr
//         { $$ = {"type": "assignment", "lhs": $1, "rhs": $3} }
//     | variable
//         { $$ = {"type": "variable-access", "name": $1}; }
// ;






























start
   : decl_list
      { }
   ;

decl_list
   :
      { $$ = nil; }
   | decl_list decl
      { if(!statementList) { statementList = $2; } else { statementList->append($2); } }
   ;

decl
   : stmt
      { $$ = $1; }
    | fn_decl_stmt
      { $$ = $1; }
   | package_decl
     { $$ = $1; }
   ;

package_decl
   : rwPACKAGE IDENT '{' fn_decl_list '}' ';'
      { $$ = $4; for(StmtNode *walk = ($4);walk;walk = walk->getNext() ) walk->setPackage($2); }
   ;

fn_decl_list
   : fn_decl_stmt
      { $$ = $1; }
   | fn_decl_list fn_decl_stmt
      { $$ = $1; ($1)->append($2);  }
   ;

statement_list
   :
      { $$ = nil; }
   | statement_list stmt
      { if(!$1) { $$ = $2; } else { ($1)->append($2); $$ = $1; } }
   ;

stmt
   : if_stmt
   | while_stmt
   | for_stmt
   | datablock_decl
   | switch_stmt
   | rwBREAK ';'
      { $$ = BreakStmtNode::alloc(); }
   | rwCONTINUE ';'
      { $$ = ContinueStmtNode::alloc(); }
   | rwRETURN ';'
      { $$ = ReturnStmtNode::alloc(NULL); }
   | rwRETURN expr ';'
      { $$ = ReturnStmtNode::alloc($2); }
   | expression_stmt ';'
      { $$ = $1; }
   | TTAG '=' expr ';'
      { $$ = TTagSetStmtNode::alloc($1, $3, NULL); }
   | TTAG '=' expr ',' expr ';'
      { $$ = TTagSetStmtNode::alloc($1, $3, $5); }
   ;

fn_decl_stmt
    : 'function' ident '(' var_list_decl ')' '{' statement_list '}'
        { $$ = {"type": "function", "name": $2, "args": $4, "body": $7}; }
    | 'function' ident '::' ident '(' var_list_decl ')' '{' statement_list '}'
        { $$ = {"type": "function", "name": $4, "scope": $2, "args": $6, "body": $9}; }
    ;

var_list_decl
    :
        { $$ = []; }
    | var_list
        { $$ = $1; }
    ;

var_list
    : variable
        { $$ = [{"type": "variable", "name": $1}]; }
    | var_list ',' variable
        { $$ = $1; $1.push({"type": "variable", "name": $1}); }
    ;

//
// datablock_decl
//    : rwDATABLOCK IDENT '(' IDENT parent_block ')'  '{' slot_assign_list '}' ';'
//       { $$ = ObjectDeclNode::alloc(ConstantNode::alloc($2), ConstantNode::alloc($4), NULL, $5, $8, NULL, true); }
//    ;
//
// object_decl
//    : rwDECLARE class_name_expr '(' object_name parent_block object_args ')' '{' object_declare_block '}'
//       { $$ = ObjectDeclNode::alloc($2, $4, $6, $5, $9.slots, $9.decls, false); }
//    | rwDECLARE class_name_expr '(' object_name parent_block object_args ')'
//       { $$ = ObjectDeclNode::alloc($2, $4, $6, $5, NULL, NULL, false); }
//    ;
//
// parent_block
//    :
//       { $$ = NULL; }
//    | ':' IDENT
//       { $$ = $2; }
//    ;
//
// object_name
//    :
//       { $$ = StrConstNode::alloc("", false); }
//    | expr
//       { $$ = $1; }
//    ;
//
// object_args
//    :
//       { $$ = NULL; }
//    | ',' expr_list
//       { $$ = $2; }
//    ;
//
// object_declare_block
//    :
//       { $$.slots = NULL; $$.decls = NULL; }
//    | slot_assign_list
//       { $$.slots = $1; $$.decls = NULL; }
//    | object_decl_list
//       { $$.slots = NULL; $$.decls = $1; }
//    | slot_assign_list object_decl_list
//       { $$.slots = $1; $$.decls = $2; }
//    ;
//
// object_decl_list
//    : object_decl ';'
//       { $$ = $1; }
//    | object_decl_list object_decl ';'
//       { $1->append($2); $$ = $1; }
//    ;
//
// stmt_block
//    : '{' statement_list '}'
//       { $$ = $2; }
//    | stmt
//       { $$ = $1; }
//    ;
//
// switch_stmt
//    : rwSWITCH '(' expr ')' '{' case_block '}'
//       { $$ = $6; $6->propagateSwitchExpr($3, false); }
//    | rwSWITCHSTR '(' expr ')' '{' case_block '}'
//       { $$ = $6; $6->propagateSwitchExpr($3, true); }
//    ;
//
// case_block
//    : rwCASE case_expr ':' statement_list
//       { $$ = IfStmtNode::alloc($1, $2, $4, NULL, false); }
//    | rwCASE case_expr ':' statement_list rwDEFAULT ':' statement_list
//       { $$ = IfStmtNode::alloc($1, $2, $4, $7, false); }
//    | rwCASE case_expr ':' statement_list case_block
//       { $$ = IfStmtNode::alloc($1, $2, $4, $5, true); }
//    ;
//
// case_expr
//    : expr
//       { $$ = $1;}
//    | case_expr rwCASEOR expr
//       { ($1)->append($3); $$=$1; }
//    ;
//
// if_stmt
//    : rwIF '(' expr ')' stmt_block
//       { $$ = IfStmtNode::alloc($1, $3, $5, NULL, false); }
//    | rwIF '(' expr ')' stmt_block rwELSE stmt_block
//       { $$ = IfStmtNode::alloc($1, $3, $5, $7, false); }
//    ;
//
// while_stmt
//    : rwWHILE '(' expr ')' stmt_block
//       { $$ = LoopStmtNode::alloc($1, nil, $3, nil, $5, false); }
//    | rwDO stmt_block rwWHILE '(' expr ')'
//       { $$ = LoopStmtNode::alloc($3, nil, $5, nil, $2, true); }
//    ;
//
// for_stmt
//    : rwFOR '(' expr ';' expr ';' expr ')' stmt_block
//       { $$ = LoopStmtNode::alloc($1, $3, $5, $7, $9, false); }
//    | rwFOR '(' expr ';' expr ';'      ')' stmt_block
//       { $$ = LoopStmtNode::alloc($1, $3, $5, NULL, $8, false); }
//    | rwFOR '(' expr ';'      ';' expr ')' stmt_block
//       { $$ = LoopStmtNode::alloc($1, $3, NULL, $6, $8, false); }
//    | rwFOR '(' expr ';'      ';'      ')' stmt_block
//       { $$ = LoopStmtNode::alloc($1, $3, NULL, NULL, $7, false); }
//    | rwFOR '('      ';' expr ';' expr ')' stmt_block
//       { $$ = LoopStmtNode::alloc($1, NULL, $4, $6, $8, false); }
//    | rwFOR '('      ';' expr ';'      ')' stmt_block
//       { $$ = LoopStmtNode::alloc($1, NULL, $4, NULL, $7, false); }
//    | rwFOR '('      ';'      ';' expr ')' stmt_block
//       { $$ = LoopStmtNode::alloc($1, NULL, NULL, $5, $7, false); }
//    | rwFOR '('      ';'      ';'      ')' stmt_block
//       { $$ = LoopStmtNode::alloc($1, NULL, NULL, NULL, $6, false); }
//    ;

expression_stmt
    : stmt_expr
        { $$ = $1; }
    ;

expr
    : stmt_expr
        { $$ = $1; }
    | '(' expr ')'
        { $$ = $2; }
    | expr '^' expr
        { $$ = {"type": "binary", "op": $2, "lhs": $1, "rhs": $3}; }
    | expr '%' expr
        { $$ = {"type": "binary", "op": $2, "lhs": $1, "rhs": $3}; }
    | expr '&' expr
        { $$ = {"type": "binary", "op": $2, "lhs": $1, "rhs": $3}; }
    | expr '|' expr
        { $$ = {"type": "binary", "op": $2, "lhs": $1, "rhs": $3}; }
    | expr '+' expr
        { $$ = {"type": "binary", "op": $2, "lhs": $1, "rhs": $3}; }
    | expr '-' expr
        { $$ = {"type": "binary", "op": $2, "lhs": $1, "rhs": $3}; }
    | expr '*' expr
        { $$ = {"type": "binary", "op": $2, "lhs": $1, "rhs": $3}; }
    | expr '/' expr
        { $$ = {"type": "binary", "op": $2, "lhs": $1, "rhs": $3}; }
    | expr '<' expr
        { $$ = {"type": "binary", "op": $2, "lhs": $1, "rhs": $3}; }
    | expr '>' expr
        { $$ = {"type": "binary", "op": $2, "lhs": $1, "rhs": $3}; }
    | expr '>=' expr
        { $$ = {"type": "binary", "op": $2, "lhs": $1, "rhs": $3}; }
    | expr '<=' expr
        { $$ = {"type": "binary", "op": $2, "lhs": $1, "rhs": $3}; }
    | expr '==' expr
        { $$ = {"type": "binary", "op": $2, "lhs": $1, "rhs": $3}; }
    | expr '!=' expr
        { $$ = {"type": "binary", "op": $2, "lhs": $1, "rhs": $3}; }
    | expr '||' expr
        { $$ = {"type": "binary", "op": $2, "lhs": $1, "rhs": $3}; }
    | expr '&&' expr
        { $$ = {"type": "binary", "op": $2, "lhs": $1, "rhs": $3}; }
    | expr '<<' expr
        { $$ = {"type": "binary", "op": $2, "lhs": $1, "rhs": $3}; }
    | expr '>>' expr
        { $$ = {"type": "binary", "op": $2, "lhs": $1, "rhs": $3}; }
    | expr '$=' expr
        { $$ = {"type": "binary", "op": $2, "lhs": $1, "rhs": $3}; }
    | expr '!$=' expr
        { $$ = {"type": "binary", "op": $2, "lhs": $1, "rhs": $3}; }
    | expr '@' expr
        { $$ = {"type": "binary", "op": $2, "lhs": $1, "rhs": $3}; }
    | '-' expr  %prec UNARY
        { $$ = {"type": "unary", "op": $1, "expr": $2}; }
    | '!' expr  %prec UNARY
        { $$ = {"type": "unary", "op": $1, "expr": $2}; }
    | '~' expr  %prec UNARY
        { $$ = {"type": "unary", "op": $1, "expr": $2}; }
    | expr '?' expr ':' expr
        { $$ = {"type": "conditional-expr", "cond": $1, "y": $3, "n": $5}; }
    | number
        { $$ = {"type": "number", "value": $1}; }
    | string
        { $$ = {"type": "number", "value": $1}; }
    | 'break'
        { $$ = {"type": "string", "value": "break"}; }
    | slot_acc
        { $$ = $1; }
    | ident
        { $$ = {"type": "ident", "value": $1}; }
    | variable
        { $$ = {"type": "variable", "name": $1}; }
    | variable '[' aidx_expr ']'
        { $$ = {"type": "variable", "name": $1, "array": $3}; }
    ;

slot_acc
    : expr '.' ident
        { $$ = {"target": $1, "field": $3}; }
    | expr '.' ident '[' aidx_expr ']'
        { $$ = {"target": $1, "field": $3, "array": $5}; }
    ;

class_name_expr
    : ident
        { $$ = {"type": "string", "value": $1}; }
    | '(' expr ')'
        { $$ = $2; }
    ;

assign_op_struct
    : '++'
        { $$ = {"op": "+", "rval": {"type": "number", "value": 1}}; }
    | '--'
        { $$ = {"op": "-", "rval": {"type": "number", "value": 1}}; }
    | '+=' expr
        { $$ = {"op": "+", "rval": $2; }
    | '-=' expr
        { $$ = {"op": "-", "rval": $2; }
    | '*=' expr
        { $$ = {"op": "*", "rval": $2; }
    | '/=' expr
        { $$ = {"op": "/", "rval": $2; }
    | '%=' expr
        { $$ = {"op": "%", "rval": $2; }
    | '&=' expr
        { $$ = {"op": "&", "rval": $2; }
    | '^=' expr
        { $$ = {"op": "^", "rval": $2; }
    | '|=' expr
        { $$ = {"op": "|", "rval": $2; }
    | '<<=' expr
        { $$ = {"op": "<<", "rval": $2; }
    | '>>=' expr
        { $$ = {"op": ">>", "rval": $2; }
    ;

stmt_expr
    : funcall_expr
        { $$ = $1; }
    | object_decl
        { $$ = $1; }
    | variable '=' expr
        { $$ = {"type": "assign", "name": $1, "rval": $3}; }
    | variable '[' aidx_expr ']' '=' expr
        { $$ = {"type": "assign", "name": $1, "rval": $6, "array": $3}; }
    | variable assign_op_struct
        { $$ = {"type": "assign-op", "name": $1, "rval": $2.rval, "op": $2.op}; }
    | variable '[' aidx_expr ']' assign_op_struct
        { $$ = {"type": "assign-op", "name": $1, "rval": $5.rval, "op": $5.op, "array": $3}; }
    | slot_acc assign_op_struct
        { $$ = {"type": "todo"}; }
        //{ $$ = SlotAssignOpNode::alloc($1.object, $1.slotName, $1.array, $2.token, $2.expr); }
    | slot_acc '=' expr
        { $$ = {"type": "todo"}; }
        // { $$ = SlotAssignNode::alloc($1.object, $1.array, $1.slotName, $3); }
    | slot_acc '=' '{' expr_list '}'
        { $$ = {"type": "todo"}; }
        //{ $$ = SlotAssignNode::alloc($1.object, $1.array, $1.slotName, $4); }
   ;

funcall_expr
    : ident '(' expr_list_decl ')'
        { $$ = {"type": "function-call", "name": $1, "args": $3}; }
    | ident '::' ident '(' expr_list_decl ')'
        { $$ = {"type": "function-call", "name": $1, "scope": $3, "args": $5}; }
    | expr '.' ident '(' expr_list_decl ')'
        { $$ = {"type": "function-call", "name": $3, "target": $3, "args": $5}; }
    ;

expr_list_decl
    :
        { $$ = null; }
    | expr_list
        { $$ = $1; }
    ;

expr_list
    : expr
        { $$ = [$1]; }
    | expr_list ',' expr
        { $1.push($3); $$ = $1; }
    ;

slot_assign_list
    // : slot_assign
    //     { $$ = $1; }
    // | slot_assign_list slot_assign
    //     { $1->append($2); $$ = $1; }
    : slot_assign
        { $$ = [$1]; }
    | slot_assign_list slot_assign
        { $1.push($2); $$ = $1; }
    ;

slot_assign
    : ident '=' expr ';'
        { $$ = {"type": "slot-assign", "slot": $1, "value": $3}; }
    | ident '[' aidx_expr ']' '=' expr ';'
        { $$ = {"type": "slot-assign", "slot": $1, "array": $3, "value": $6}; }
    ;

aidx_expr
   : expr
      { $$ = $1; }
   | aidx_expr ',' expr
      { $$ = {"type": "comma_cat_expr", "lhs": $1, "rhs": $3}; }
   ;
