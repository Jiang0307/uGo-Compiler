/*DEFINITION*/
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    #define YY_NO_UNPUT
    #define YY_NO_INPUT
    #define print_token(token) printf("%-8s \t %s\n", strcmp(token, "NEWLINE")? yytext: "", token)

    unsigned long long line_count = 0;
    unsigned long long comment_count = 0;
    int last_comment_line = -1;
%}
/*STATE LABELS*/
%x C_COMMENT STRING_LITERAL

/*REGULAR EXPRESSION LABELS*/
letter [a-zA-Z_]
digit [0-9]
id {letter}+({letter}|{digit})*
inumber {digit}+
fnumber ({digit}*\.{digit}+)
CPP_COMMENT "//"(.)*

/* RULES : <STATE (OPTIONAL)> REGEX {ACTIONS} */

%%
"/*"                      { printf("%s" , yytext); BEGIN C_COMMENT; }
<C_COMMENT>"*/"           { print_token("C Comment"); BEGIN 0; comment_count++; }
<C_COMMENT>"\n"           { print_token("C Comment"); comment_count++; line_count++; }
<C_COMMENT>.              { printf("%s" , yytext); }
{CPP_COMMENT}             { print_token("C++ Comment"); comment_count++; }

"+"         { print_token("ADD"); }
"-"         { print_token("SUB"); }
"*"         { print_token("MUL"); }
"/"         { print_token("QUO"); }
"%"         { print_token("REM"); }
"++"        { print_token("INC"); }
"--"        { print_token("DEC"); }
">"         { print_token("GTR"); }
"<"			{ print_token("LSS"); }
">="        { print_token("GEQ"); }
"<="        { print_token("LEQ"); }
"=="        { print_token("EQL"); }
"!="        { print_token("NEQ"); }
"="         { print_token("ASSIGN"); }
"+="        { print_token("ADD_ASSIGN"); }
"-="        { print_token("SUB_ASSIGN"); }
"*="        { print_token("MUL_ASSIGN"); }
"/="        { print_token("QUO_ASSIGN"); }
"%="        { print_token("REM_ASSIGN"); }
"&&"        { print_token("LAND"); }
"||"        { print_token("LOR"); }
"!"         { print_token("NOT"); }
"("         { print_token("LPAREN"); }
")"         { print_token("RPAREN"); }
"["         { print_token("LBRACK"); }
"]"         { print_token("RBRACK"); }
"{"         { print_token("LBRACE"); }
"}"         { print_token("RBRACE"); }
";"         { print_token("SEMICOLON"); }
","         { print_token("COMMA"); }

"\""        { print_token("QUOTA"); BEGIN STRING_LITERAL;}
<STRING_LITERAL>[^\"]*    { print_token("STRING_LIT"); }
<STRING_LITERAL>"\""      { print_token("QUOTA"); BEGIN 0; }

"\n"		{ print_token("NEWLINE"); line_count+=1;}
":"         { print_token("COLON"); }
"print"   	{ print_token("PRINT"); }
"println"   { print_token("PRINTLN"); }
"if"       	{ print_token("IF"); }
"else"      { print_token("ELSE"); }
"for"       { print_token("FOR"); }
"int32"     { print_token("INT"); }
"float32"   { print_token("FLOAT"); }
"string"    { print_token("STRING"); }
"bool"      { print_token("BOOL"); }
"true"      { print_token("TRUE"); }
"false"     { print_token("FALSE"); }
"var"       { print_token("VAR"); }
"func"      { print_token("FUNC"); }
"package"   { print_token("PACKAGE"); }
"return"    { print_token("RETURN"); }
"switch"    { print_token("SWITCH"); }
"case"      { print_token("CASE"); }
"default"   { print_token("DEFAULT"); }	
{inumber}   { print_token("INT_LIT"); }
{fnumber}   { print_token("FLOAT_LIT"); }
{id}        { print_token("IDENT"); }
<<EOF>>     { line_count++; yyterminate(); }
[ \t]+      {;}
.           {;}

%%
/*C CODE*/
int yywrap(void)
{
    return 1;
}

int main(int argc, char *argv[])
{
    if (argc == 2) 
    {
        yyin = fopen(argv[1], "r");
    }
    else 
    {
        yyin = stdin;
    }
    yylex();
    printf("\nFinish scanning,\n");
    printf("total line: %llu\n", line_count);
    printf("comment line: %llu\n", comment_count);
    fclose(yyin);
    return 0;
}