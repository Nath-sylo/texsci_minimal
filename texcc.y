%{
  #include <stdio.h>
  #include <stdlib.h>
  #define TEXCC_ERROR_GENERAL 4

  void yyerror(char*);

  // Functions and global variables provided by Lex.
  int yylex();
  void texcc_lexer_free();
  extern FILE* yyin;
%}

%union {
  char* name;
  char* val;
  char* str;
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
%token CIN CWHILE CFOR CIF CEIF ENDINST

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
     '$' ID LEFT expression '$' ENDINST
  | '$' MBOX '{' print '}' '$' ENDINST
  | {printf("je bloque la\n");}
  ;

print:
    PRINTINT '(' '$' ID '$' ')'
  | PRINTTEXT '(' '$'  STR  '$' ')'
  |
  ;
  
//TODO rajouter les instructions
expression:
    sous_expression
  | sous_expression PLUS expression
  | sous_expression MIN expression
  | sous_expression MULTOP expression 
  ;

//TODO rajouter les instructions
sous_expression:
    INT 
  | BOOL
  | REAL
  | ID
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
  
//TODO rajouter les instructions d'ajout dans la table des symboles
const:
    ID EQUAL INT CIN type
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
  
//TODO rajouter les instructions d'ajjout ans la table des symboles
input:
    ID CIN type 
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
  ;

type:
    INT
  | REAL
  | BOOL
  ;

%%

int main(int argc, char* argv[]) {
  if (argc == 2) {
    if ((yyin = fopen(argv[1], "r")) == NULL) {
      fprintf(stderr, "[texcc] error: unable to open file %s\n", argv[1]);
      exit(TEXCC_ERROR_GENERAL);
    }
  } else {
    fprintf(stderr, "[texcc] usage: %s input_file\n", argv[0]);
    exit(TEXCC_ERROR_GENERAL);
  }

  yyparse();
  fclose(yyin);
  texcc_lexer_free();
  return EXIT_SUCCESS;
}
