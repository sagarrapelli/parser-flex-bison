%{
#include <stdio.h>
#include <math.h>
#include <string.h>
#include "calc.tab.h"
int line_no = 1;
%}

digit	([0-9])

%%

"main()"			{	return(TOK_MAIN);}
"int"				{	return(TOK_INT);}
"float"				{	return(TOK_FLOAT);}
"printID"			{   	return(TOK_PRINTID);}
"printExp"			{   	return(TOK_PRINTEXP);}

{digit}+			{
					yylval.int_val = atoi(yytext);
					return TOK_INUM;
				}

[0-9]+\.[0-9]+			{
					yylval.fval = atof(yytext);
					return TOK_FNUM;
				}

[a-z]+[a-zA-Z0-9]* 		{	yylval.id = strdup(yytext);return(TOK_ID);}



[-*=;{}E]			{	return yytext[0];}

[ \t]				;/* ignore this */
[\n] 				{++line_no;}

.					{	printf("Lexical error :%s\n", yytext);}

%%

