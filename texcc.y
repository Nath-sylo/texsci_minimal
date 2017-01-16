%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include "lib.h"
  #define TEXCC_ERROR_GENERAL 4
  void yyerror(const char*);

  // Functions and global variables provided by Lex.
  int yylex();
  void texcc_lexer_free();
  FILE* output;
  struct code * code;
  struct symtable * table;
  extern FILE* yyin;
  extern int yylineno;

%}

%union {
  char* name;
  char* val;
  char* str;
  struct {
      struct symbol * ptr;
  } exprval;
}

%left MULTOP
%token TEXSCI_BEGIN TEXSCI_END BLANKLINE EMPTY
%token <name> ID 
%token <val> INT BOOL REAL
%token <str> STR
%token MULTOP MIN PLUS
%token PRINTINT PRINTTEXT
%token MBOX LEFT INPUT OUTPUT CONST INTEGER BOOLEAN
%token COMPLEX EQUAL GLOBAL LOCAL
%token CIN ENDINST

%type <exprval> expression sous_expression

%start algorithm_list

%%

algorithm_list:
    algorithm_list algorithm
  | algorithm
  ;

algorithm:
    TEXSCI_BEGIN '{' ID '}' initialisation BLANKLINE liste_instructions TEXSCI_END
    {
      fprintf(stderr, "[texcc] info: algorithm \"%s\" parsed\n", $3);
      free($3);
    }
  ;

liste_instructions:
    liste_instructions instruction
  | instruction
  ;

instruction:
           '$' ID LEFT expression '$' ENDINST  {
            struct symbol  * id = symtable_get(table,$2);
            if(id==NULL){
                fprintf(stderr, "line %d: semantic error \n", yylineno);
                exit(3);
            }
            gencode(code,COPY,id,$4.ptr,NULL);
    }
  | '$' MBOX '{' print '}' '$' ENDINST
  | 
  ;

print:
     PRINTINT '(' '$' ID '$' ')' {
         struct symbol * id=symtable_get(table,$4);
      if(id==NULL)
         {
        fprintf(stderr, "line %d: semantic error \n", yylineno);
        exit(3);
      
        }
      gencode(code,CALL_PRINT,id,NULL,NULL);
}
  | PRINTTEXT '(' '$'  STR  '$' ')'   {
      mips_print(output, $4, table);
      char name[10];
      sprintf(name, "print%d", table->print-1);
      symtable_put(table, name);
      struct symbol * id = symtable_get(table,name);
      gencode(code,CALL_TEXT,id,NULL,NULL);
}
  |
  ;
  
//TODO rajouter les instructions
expression:
    sous_expression
  | sous_expression PLUS expression {
         $$.ptr = newtemp(table);
         gencode(code,BOP_PLUS,$$.ptr,$1.ptr,$3.ptr); }
  | sous_expression MIN expression  {
         $$.ptr = newtemp(table);
         gencode(code,BOP_MINUS,$$.ptr,$1.ptr,$3.ptr); }
  | sous_expression MULTOP expression {
         $$.ptr = newtemp(table);
         gencode(code,BOP_MULT,$$.ptr,$1.ptr,$3.ptr); }
  ;

//TODO rajouter les instructions
sous_expression:
   INT  {
        $$.ptr = symtable_const(table, $1);
}
  | BOOL  {
        $$.ptr = symtable_const(table, $1);
}
  | REAL  {
        $$.ptr = symtable_const(table, $1);
}
  | ID  {
     struct symbol * id = symtable_get(table,$1);
      if (id==NULL)
      {
        fprintf(stderr, "line %d: semantic error \n", yylineno);
        exit(3);
      
      }
      $$.ptr = id;
}
  ;

initialisation:
    constantes inputs outputs globales locales
  ;

constantes:
    CONST '{' '$' list_const '$' '}'
  | CONST '{' '$' EMPTY '$' '}'     {printf("Pas de constante trouve\n");}
  | {printf("Pas de constante trouve\n");}
  ;

list_const:
    list_const ',' const
  | const
  ;
  
//TODO rajouter les instructions d'ajout dans la table des symboles #Done !
const:
    ID '=' INT CIN type {
        struct symbol * id = symtable_get(table,$1);
        if(id==NULL){
            id=symtable_put(table,$1);
            mips_int_const(output,$1,$3);
        }
        else {
            fprintf(stderr, "line %d: semantic error \n", yylineno);
            exit(3);
        }
  }
  ;

inputs:
    INPUT '{' '$' list_input '$' '}'
  | INPUT '{' '$' EMPTY '$' '}'     {printf("Pas d'input trouve\n");}
  | {printf("Pas d'input trouve\n");}
  ;

list_input:
    list_input ',' input
  | input
  ;
  
//TODO rajouter les instructions d'ajout ans la table des symboles #Done
input:
     ID CIN type {
        struct symbol * id = symtable_get(table,$1);
        if(id==NULL){
            id=symtable_put(table,$1);
            mips_int(output,$1);
        }
        else {
            fprintf(stderr, "line %d: semantic error \n", yylineno);
            exit(3);
        }
}
  ;

outputs:
    OUTPUT '{' '$' list_output '$' '}'
  | OUTPUT '{' '$' EMPTY '$' '}'    {printf("Pas d'output trouve\n");}
  | {printf("Pas d'output trouve\n");}
  ;

list_output:
    list_output ',' output
  | output
  ;
  
//TODO rajouter les instructions
output:
    ID CIN type 
        {struct symbol * id = symtable_get(table,$1);
        if(id==NULL){
            id=symtable_put(table,$1);
            mips_int(output,$1);
        }
        else {
            fprintf(stderr, "line %d: semantic error \n", yylineno);
            exit(3);
        }
  }
  ;

globales:
    GLOBAL '{' '$' list_global '$' '}'
  | GLOBAL '{' '$' EMPTY '$' '}'    {printf("Pas de variable globale trouve\n");}
  | {printf("Pas de variable globale trouve\n");}
  ;

list_global:
    list_global ',' global
  | global
  ;
  
//TODO rajouter les instructions
global:
    ID CIN type 
        {struct symbol * id = symtable_get(table,$1);
        if(id==NULL){
            id=symtable_put(table,$1);
            mips_int(output,$1);
        }
        else {
            fprintf(stderr, "line %d: semantic error \n", yylineno);
            exit(3);
        }
  }
  ;

locales:
    LOCAL '{' '$' list_local '$' '}'
  | LOCAL '{' '$' EMPTY '$' '}'     {printf("Pas de variable locale trouve\n");}
  | {printf("Pas de variable locale trouve\n");}
  ;

list_local:
    list_local ',' local
  | local
  ;
  
//TODO rajouter les instructions
local:
    ID CIN type 
        {struct symbol * id = symtable_get(table,$1);
        if(id==NULL){
            id=symtable_put(table,$1);
            mips_int(output,$1);
        }
        else {
            fprintf(stderr, "line %d: semantic error \n", yylineno);
            exit(3);
        }
  }
  ;

type:
    INTEGER
  | REAL
  | BOOLEAN
  ;

%%

void yyerror(const char * s)
{
  char error[] = "syntax error";
  fprintf(stderr, "line %d: %s \n", yylineno, s);
  if(strcmp (error,s) == 0)
    exit(2);
  else
    exit(4);
}

int main(int argc, char* argv[]) {
  if (argc == 2) {
    if ((yyin = fopen(argv[1], "r")) == NULL) {
      fprintf(stderr, "[texcc] error: unable to open file %s\n", argv[1]);
      exit(TEXCC_ERROR_GENERAL);
    }
    if ((output = fopen("output.s","w")) == NULL) {
        fprintf(stderr, "[texcc] error: unable to open output file\n");
        exit(TEXCC_ERROR_GENERAL);
    }
  } else {
    fprintf(stderr, "[texcc] usage: %s input_file\n", argv[0]);
    exit(TEXCC_ERROR_GENERAL);
  }

  code=code_new();
  table=symtable_new();

  fprintf(output, ".data\n");
  fprintf(output, " print: .asciiz \"\\n\" \n");
  yyparse();
  fclose(yyin);
  fprintf(output, ".text\n");
  fprintf(output, "main:\n");
  print_code(output,code);
  fprintf(output, " li $v0, 10\n");
  fprintf(output, " syscall\n");
  texcc_lexer_free();
  return EXIT_SUCCESS;
}
