/* Definition section */
%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <stdbool.h>


	/* Symbol table function */
	void create_symbol();
	void insert_symbol(int index, char* id, char* type);
	int lookup_symbol(char* find);
	void dump_symbol();
	int hashCode(char* id);
	
	/* Global variables */
	bool first = true;
	int commentCount = 0;
	int size = 10;
	int globalIndex = 0;
	struct DataItem{
		int Index;
		char* ID;
		char* Type;
		struct DataItem* next;
	};

	struct DataItem* hashArray[10];
	struct DataItem* dummyItem;
	struct DataItem* item;

%}

%option yylineno

/* Define regular expression label */

letter [a-zA-Z]
digit [0-9]
id {letter}+({letter}|{digit})*
number {digit}+
blank [ \t\n]
string ["]({id}|[ ])*["]
declareINT var[ ]+{id}[ ]+int
declareFLOAT32 var[ ]+{id}[ ]+float32
ccomment "/*"([^*]|\*+[^*/])*\*+"/"
cpluscomment ("//"([^\n])*[\n])
/*string \"([^"]|\"\")*\"*/

/* Rules section */
%%

"+" 	{ printf("%s \t Add \n", yytext); }
"-"		{ printf("%s \t Sub \n", yytext); }
"*"		{ printf("%s \t Mul \n", yytext); }
"/"		{ printf("%s \t Div \n", yytext); }
"%"		{ printf("%s \t Mod \n", yytext); }

"++"	{ printf("%s \t Increment \n", yytext); }
"--"	{ printf("%s \t Decrement \n", yytext); }
"+="	{ printf("%s \t Add and Assign \n", yytext); }
"-="	{ printf("%s \t Sub and Assign \n", yytext); }
"*="	{ printf("%s \t Mul and Assign \n", yytext); }
"/="	{ printf("%s \t Div and Assign \n", yytext); }
"%="	{ printf("%s \t Mod and Assign \n", yytext); }
"="		{ printf("%s \t Assign  \n", yytext); }

"=="	{ printf("%s \t Equal \n", yytext); }
"!="	{ printf("%s \t Not equal \n", yytext); }
"<"		{ printf("%s \t Less than  \n", yytext); }
">"		{ printf("%s \t Greater than  \n", yytext); }
">="	{ printf("%s \t Greater than or equal \n", yytext); }
"<="	{ printf("%s \t Less than or equal \n", yytext); }

"&&"	{ printf("%s \t And \n", yytext); }
"||"	{ printf("%s \t Or \n", yytext); }
"!"		{ printf("%s \t Not \n", yytext); }

"("		{ printf("%s \t LB  \n", yytext); }
")"		{ printf("%s \t RB  \n", yytext); }
"{"		{ printf("%s \t LCB  \n", yytext); }
"}"		{ printf("%s \t RCB  \n", yytext); }
"\""	{ printf("%s \t Quote  \n", yytext); }

"if"	{ printf("%s \t IF function \n", yytext); }
"else"	{ printf("%s \t ELSE statement \n", yytext); }
"for"	{ printf("%s \t FOR function \n", yytext); }
"print"	{ printf("%s \t PRINT function \n", yytext); }
"println"	{ printf("%s \t PRINTLN function \n", yytext); }

{id}	{ int declared = lookup_symbol(yytext);
			if(declared == 0){
				printf("Error: Variable \"%s\" at line %d undeclared\n", yytext, yylineno);
				exit(0);
			}
			printf("%s \t ID \n", yytext); }
{number} { printf("%s \t Number \n", yytext); }
{string} { printf("%s \t String \n", yytext); }
{declareINT} { char * id;
			   strtok(yytext, " ");
			   id = strtok(NULL, " ");
			   printf("%s \t int TYPE VAR \n", id); 
			   int redefined = lookup_symbol(id);
			   if(redefined == 1){
			   	printf("Error: Variable \"%s\" at line %d redefined\n", id, yylineno);
				exit(0);
			   }
			   insert_symbol(globalIndex, id, "int");
			   globalIndex++;}
{declareFLOAT32} { char * id;
				   strtok(yytext, " ");
				   id = strtok(NULL, " ");
				   printf("%s \t float32 TYPE VAR \n", id);
			   	   int redefined = lookup_symbol(id);
			   	   if(redefined == 1){
				   		printf("Error: Variable \"%s\" at line %d redefined\n", id, yylineno);
						exit(0);
					}
				   insert_symbol(globalIndex, id, "float32");
				   globalIndex++;}
{ccomment} { printf("%s \t C Comment \n", yytext);
			 int index=0;
			 while(yytext[index]!=0){
			 	if(yytext[index] == 10){commentCount++;}
				index++;}
			 commentCount++;}
{cpluscomment} { char comment[strlen(yytext)];
				 strncpy(comment, yytext, strlen(yytext)-1);
				 printf("%s \t C++ Comment \n", comment);
				 commentCount++; }
{blank} {;}


%%

/*	C Code section */
int yywrap(void)
{
    return 1;
}

void create_symbol() {
	printf("Create a symbol table\n");
}
void insert_symbol(int globalIndex, char* id, char* type){
	if(first == true){
		create_symbol();
		first = false;
	}
	printf("Insert a symbol: %s\n", id);
	struct DataItem* item = (struct DataItem*)malloc(sizeof(struct DataItem));

	item->Index = globalIndex;
	item->ID = id;
	item->Type = type;
	item->next = NULL;

	int hashIndex = hashCode(id);
	
	struct DataItem* last = hashArray[hashIndex];
	if(hashArray[hashIndex] == NULL)
	{
		hashArray[hashIndex] = item;
		return;
	}
	while(last->next != NULL){
		last = last->next;
	}

	last->next = item;
}

int lookup_symbol(char* find){
	int search = hashCode(find);
	if(hashArray[search] == NULL){
		return 0;
	}

	struct DataItem* temp = (struct DataItem*)malloc(sizeof(struct DataItem));
	temp = hashArray[search];
	while(temp != NULL){
		if(strcmp(find, temp->ID) == 0){
			return 1;
		}
		temp = temp->next;
	}
	return 0;
}
void dump_symbol() {
	printf("The symbol table dump:\n");
	for(int i = 0; i < size; ++i){
		if(hashArray[i] == NULL){
			continue;
		}
		printf("%d\t%s\t%s\n", hashArray[i]->Index, hashArray[i]->ID, hashArray[i]->Type );
		while(hashArray[i]->next != NULL){
			hashArray[i] = hashArray[i]->next;
			printf("%d\t%s\t%s\n", hashArray[i]->Index, hashArray[i]->ID, hashArray[i]->Type );
		}
	}
}
int hashCode(char* id){
	return strlen(id) % size;
}
int main(int argc,char *argv[])
{
	yyin = fopen(argv[1],"r");
	yylex();
	printf("\nParse over, the line number is %d.\n", yylineno-1);
	printf("\ncomment: %d lines\n", commentCount);
	dump_symbol();

	return 0;
}
