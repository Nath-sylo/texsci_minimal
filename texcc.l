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
id        [a-zA-Z_][a-zA-Z0-9_]*
letter    [a-zA-Z]
number    [0-9]+
space     [\t\n ]+

mbox         "\\mbox"
left         "\\leftarrow"
input        "\\Input"
output       "\\Output"
integer      "\\Integer"
boolean      "\\Boolean"
const        "\\Constant"
real         "\\Real"
complex      "\\Complex"
global       "\\Global"
local        "\\Local"
cin          "\\in"
cwhile       "\\While"
cfor         "\\For"
cif          "\\If"
ceif         "\\eIf"
endInst      "\\;"
multOp       "\\times"
printint     "\\printInt"
printtext    "\\printText"

string \"(\\.|[^"])*\"

%%

{begin}             { BEGIN(texsci);   // Start TexSci scanning mode
                      return TEXSCI_BEGIN;
                    }
<texsci>{end}       { BEGIN(INITIAL); // Reset to default scanning mode
                      return TEXSCI_END;
		    }
<texsci>{id}        { yylval.name = strdup(yytext);
                      return ID;
                    }
<texsci>{blankline} { return BLANKLINE; }
<texsci>[{}]        { return yytext[0]; }
[\n]                { }
.                   { }

<texsci>{mbox}      {return MBOX;}
<texsci>{left}     {return LEFT;}
<texsci>{input}     {return INPUT;}
<texsci>{output}     {return OUTPUT;}
<texsci>{integer}     {return INTEGER;}
<texsci>{boolean}     {return BOOLEAN;}
<texsci>{const}     {return CONST;}
<texsci>{real}     {return REAL;}
<texsci>{complex}     {return COMPLEX;}
<texsci>{global}     {return GLOBAL;}
<texsci>{local}     {return LOCAL;}
<texsci>{cin}      {return CIN;}
<texsci>{cwhile}     {return CWHILE;}
<texsci>{cfor}      {return CFOR;}
<texsci>{cif}      {return CIF;}
<texsci>{ceif}      {return CEIF;}
<texsci>{endInst}      {return ENDINST;}
<texsci>{multOp}      {return MULTOP;}
<texsci>{printint} { return PRINTINT;  }
<texsci>{printtext} { return PRINTTEXT;  }
<texsci>{string} { return STR;  }
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
