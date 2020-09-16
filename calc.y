%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdbool.h>
#include <string.h>
void print();
int yylex();
int yyerror(char *s);
void add_sym_tab(char *id1,int type);
void update_sym_tab(char *id1,float value);
int get_id(char *id1);
void print_sym_tab(char *id1);
struct exp get_sym_tab(char *id1);
bool is_integer(float val);
extern int line_no;

%}

%union{
        int int_val;
        float fval;
        char *id ;
        struct exp{
        	float val;
        	int type;
        }e;
}

%type <fval> f_point
%type <e> exp
%token <fval> TOK_FNUM 
%token <int_val> TOK_INUM 
%token <id> TOK_ID TOK_INT TOK_FLOAT TOK_MAIN  
%token TOK_PRINTEXP TOK_PRINTID

%right '='
%left '+' '-'
%left '*' '/'


%%

start: 		
			| TOK_MAIN '{' line '}'		{YYACCEPT;}
			;

line:		
			| line vardef
			| line statements
			;


vardef:		 	TOK_INT TOK_ID ';'		{add_sym_tab($2,1);}	
			| TOK_FLOAT TOK_ID ';'		{add_sym_tab($2,0);}
			;

statements:		TOK_ID '=' exp ';'		{
							int k = get_id($1);
							if(k == $3.type)	
								{update_sym_tab($1,$3.val);}
							else
								{printf("Line %d:type error\n",line_no); YYERROR;}
							}					
			| TOK_PRINTID TOK_ID ';'	{print_sym_tab($2);}
			| TOK_PRINTEXP exp ';' 		{
							if(is_integer($2.val))
								printf("%d\n",(int)$2.val);
							else
								printf("%.2f\n",$2.val);
							}
			;


exp:			TOK_INUM			{$$.type = 1; $$.val = $1;}
			|TOK_ID 			{$$ = get_sym_tab($1);}
			|f_point			{$$.type = 0; $$.val = $1;}								
			| exp '-' exp 			{
							if($1.type == $3.type){$$.type = $1.type; $$.val = $1.val - $3.val;}
							else {printf("Line %d:type error\n",line_no); YYERROR;}
							}
			| exp '*' exp 			{
							if($1.type == $3.type){$$.type = $1.type; $$.val = $1.val * $3.val;}
							else {printf("Line %d:type error\n",line_no); YYERROR;}
							}
			;


f_point:		TOK_FNUM
			| TOK_INUM'E'TOK_INUM		{$$ = $1 * pow(10,$3);}
			| f_point'E'TOK_INUM		{$$ = $1 * pow(10,$3);}
			;

%%



int c = -1;

struct sym_tab{
	int type;
	float val;
	char *name;
};
struct sym_tab a[10];

bool is_integer(float val)
{
	int x = (int)val;
	return(x==val);
}

void add_sym_tab(char *id1,int type)
{
	c++;
	a[c].name=id1;
	a[c].type=type;
	a[c].val=0;
}

void update_sym_tab(char *id1,float value)
{
	for(int i=0;i<=c;i++)
	if(strcmp(a[i].name,id1)==0)
	{
		a[i].val=value;
		break;
	}
}

int get_id(char *id1)
{
	for(int i=0;i<=c;i++)
	if(strcmp(a[i].name,id1)==0)
	{
		return a[i].type;
	}
	printf("Line %d: %s is used but is not declared\n",line_no,id1);
	exit(1);
}

void print_sym_tab(char *id1)
{
	for(int i=0;i<=c;i++)
	if(*a[i].name==*id1)
	{
		if(a[i].type==1)
		{
			printf("%d\n",(int)a[i].val);
			return;
		}
		else
		{
			printf("%.2f\n", a[i].val);
			return;
		}
	}
	printf("Error:Element %s does not exist\n",id1);
}

struct exp get_sym_tab(char *id1)
{
	for(int i=0;i<=c;i++)
	if(*a[i].name==*id1)
	{
		struct exp x;
		x.val=a[i].val;
		x.type=a[i].type;	
		return x;	
	}
	printf("Error:element does not exist");
	exit(1);
}

//function for printing the entire symbol table
/*void print()
{
	printf("NAME\tVALUE\t\tTYPE\n");
	for(int i=0;i<=c;i++)
	{
		printf("%s\t",a[i].name);
		if(a[i].type==1)
			printf("%d\t\tint\n",(int)a[i].val);
		else
			printf("%f\tfloat\n", a[i].val);
	}
}*/

int yyerror(char *s)
{
	printf("Parsing error: line %d\n",line_no);
	return 0;
}

int main()
{
   yyparse();
   return 0;
}


