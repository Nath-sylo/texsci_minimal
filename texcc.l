%{
  #include <stdlib.h>
  #include <string.h>
  #include "y.tab.h"
%}

%s texsci
%option yylineno

begin     "\\begin{texsci}"
end       "\\end{texsci}"
blankline "\\BlankLine"
const        "\\Constant"
input        "\\Input"
output       "\\Output"
global       "\\Global"
local        "\\Local"
mbox         "\\mbox"
integer      "\\Integer"
boolean      "\\Boolean"
empty        "\\emptyset"
left         "\\leftarrow"
egal         "="
cin          "\\in"
multOp       "\\times"
printint     "\\printInt"
printtext    "\\printText"
id        [a-zA-Z_][a-zA-Z0-9_]*
number    -?[0-9]+
bool      "\\true"|"\\false"
dollar       "$"
endInst      "\\;"
string \"(\\.|[^"])*\"


%%

{begin}             { BEGIN(texsci);   // Start TexSci scanning mode
                      return TEXSCI_BEGIN;
                    }

<texsci>{end}       { BEGIN(INITIAL); // Reset to default scanning mode
                      return TEXSCI_END;
		    }

<texsci>{blankline} { return BLANKLINE; }

<texsci>[{}]        { return yytext[0]; }

<texsci>[()]        { return yytext[0]; }

[\n]                { }

[ ]                 { }

<texsci>{const}     {return CONST;}

<texsci>{input}     {return INPUT;}

<texsci>{output}     {return OUTPUT;}

<texsci>{global}     {return GLOBAL;}

<texsci>{local}     {return LOCAL;}

<texsci>{integer}     {return INTEGER;}

<texsci>{boolean}     {return BOOLEAN;}

<texsci>{empty}  {return EMPTY; }

<texsci>{left}     {return LEFT;}

<texsci>{egal}  {return EQUAL; }

<texsci>{cin}      {return CIN;}

<texsci>{dollar}         { return yytext[0]; }

<texsci>{endInst}      {return ENDINST;}

<texsci>[+]         { return PLUS; }

<texsci>[-]         { return MIN; }

<texsci>{multOp}      {return MULTOP;}

<texsci>{mbox}      {return MBOX;}

<texsci>{printint} { return PRINTINT;  }

<texsci>{printtext} { return PRINTTEXT;  }

<texsci>[,]         { return yytext[0]; }

<texsci>{id}        { yylval.name = strdup(yytext);
                      return ID;
                    }

<texsci>{number}    { yylval.val = strdup(yytext);
                            return INT; }

<texsci>{bool}      { return BOOL; }

<texsci>{string} { yylval.str = strdup(yytext);
                  return STR;  }

<texsci>.           { fprintf(stderr, "line %d: lexical error [%s] \n",yylineno,yytext); exit(1);}

.                   { }

%%

/**
 * texcc_lexer_free function:
 * this function frees the memory allocated for the lexer. It frees
 * flex's buffer (it supposes there is only one buffer) since flex does
 * never free it itself.
 */
void texcc_lexer_free() {
  yy_delete_buffer(YY_CURRENT_BUFFER);
  free(yy_buffer_stack);
}
