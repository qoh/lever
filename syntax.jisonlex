digit                       [0-9]
ident                       [a-zA-Z_][a-zA-Z_0-9]*
namespaceident              [a-zA-Z_][a-zA-Z_0-9:]*

%%

\s+                         /* skip whitespace */
"//".*                      /* ignore comment */
"/*"[\w\W]*?"*/"            /* ignore comment */

"..."                       return yytext;
".."                        return yytext;
"::"                        return yytext;

"++"                        return yytext;
"--"                        return yytext;
"+="                        return yytext;
"-="                        return yytext;
"*="                        return yytext;
"/="                        return yytext;
"%="                        return yytext;
"^="                        return yytext;
"|="                        return yytext;
"&="                        return yytext;
"<<="                       return yytext;
">>="                       return yytext;
"=="                        return yytext;
"!="                        return yytext;
"$="                        return yytext;
"!$="                       return yytext;
"||"                        return yytext;
"&&"                        return yytext;
"<="                        return yytext;
">="                        return yytext;
"<"                         return yytext;
">"                         return yytext;
"+"                         return yytext;
"-"                         return yytext;
"*"                         return yytext;
"/"                         return yytext;
"%"                         return yytext;

"=>"                        return yytext;
"="                         return yytext;
"("                         return yytext;
")"                         return yytext;
"["                         return yytext;
"]"                         return yytext;
"{"                         return yytext;
"}"                         return yytext;
"<"                         return yytext;
">"                         return yytext;
":"                         return yytext;
"."                         return yytext;
";"                         return yytext;
","                         return yytext;
"@"                         return yytext;
"SPC"                       return yytext;
"TAB"                       return yytext;
"NL"                        return yytext;

"!"                         return yytext;
"~"                         return yytext;

"scoped"                    return 'scoped';
"fn"                        return 'fn';
"new"                       return 'new';
"static class"              return 'static_class'; // cheating.
"class"                     return 'class';
"return"                    return 'return';
"break"                     return 'break';
"continue"                  return 'continue';
"if"                        return 'if';
"else"                      return 'else';
"for"                       return 'for';
"in"                        return 'in';
"loop"                      return 'loop';
"while"                     return 'while';
"package"                   return 'package';
"active"                    return 'active';
"datablock"                 return 'datablock';
"state"                     return 'state';
"use"                       return 'use';
"match"                     return 'match';
"or"                        return 'or';


{digit}+"."{digit}+         return 'float';
{digit}+                    return 'integer';
"\""[\w\W]*?"\""            return 'string';
"'"[\w\W]*?"'"              return 'tagged_string';
"true"|"false"              return 'boolean';
"$"{namespaceident}         return 'var_global';
{ident}"!"                  return 'macro_name';
{ident}                     return 'var_local';
"`"[^`]*"`"                 return 'ts_fence';

.                           return 'ROBOCOP';
<<EOF>>                     return 'EOF';
