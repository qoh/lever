digit                       [0-9]
name                        [a-zA-Z_][a-zA-Z_0-9]*
name_scope                  ([a-zA-Z_][a-zA-Z_0-9]*\:\:)*[a-zA-Z_][a-zA-Z_0-9]*

%%

\s+                         /* skip whitespace */
"//".*                      /* ignore comment */
"/*"[\w\W]*?"*/"            /* ignore comment */

"..."                       return yytext;
".."                        return yytext;
"::"                        return yytext;

"->"                        return yytext;
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
"class"                     return 'class';
"static"                    return 'static';
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
"$"{name_scope}             return 'global';
{name}                      return 'name';
"`"[^`]*"`"                 return 'ts_fence';

.                           return 'ROBOCOP';
<<EOF>>                     return 'EOF';
