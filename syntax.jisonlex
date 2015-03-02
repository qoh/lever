digit                       [0-9]
ident                       [a-zA-Z_][a-zA-Z_0-9]*

%%

\s+                         /* skip whitespace */
"//".*                      /* ignore comment */
"/*"[\w\W]*?"*/"            /* ignore comment */

"("                         return yytext;
")"                         return yytext;
"["                         return yytext;
"]"                         return yytext;
"{"                         return yytext;
"}"                         return yytext;
"<"                         return yytext;
">"                         return yytext;
':'                         return yytext;
'.'                         return yytext;
';'                         return yytext;
','                         return yytext;

"fn"                        return 'fn';
"return"                    return 'return';
"foreach"                   return 'foreach';
"loop"                      return 'loop';

{digit}+                    return 'integer';
{digit}+"."{digit}+         return 'float';
"\""[\w\W]*?"\""            return 'string';
"true"|"false"              return 'boolean';
"#"{ident}                  return 'var_global';
{ident}                     return 'var_local';

.                           return 'ROBOCOP';
<<EOF>>                     return 'EOF';
