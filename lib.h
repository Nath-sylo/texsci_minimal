

/* TABLE DES SYMBOLES */

struct symbol {
  enum { NAME, CONSTANT } kind;
    union {
        char* name;
        char* value;
    } u;
};

struct symtable {
    unsigned int capacity;
    unsigned int temporary; 
    unsigned int size;
    unsigned int print;
    struct symbol * symbols;
};

struct symtable * symtable_new();

struct symbol * symtable_const(struct symtable * t, char * v);

struct symbol * symtable_get(struct symtable * t, const char * s);

struct symbol * symtable_put(struct symtable * t, const char * s);

void symtable_dump(struct symtable * t);

void symtable_free(struct symtable * t);


/* QUADRUPLETS ET CODE */

struct quad {
  enum quad_kind { BOP_PLUS, BOP_MINUS, BOP_MULT, UOP_MINUS, COPY, CALL_PRINT, CALL_TEXT } kind;
  struct symbol * sym1;
  struct symbol * sym2;
  struct symbol * sym3;
};

struct code {
    unsigned int capacity;
    unsigned int nextquad;
    struct quad * quads;
};

struct code * code_new();

void gencode(struct code * c,
              enum quad_kind k,
              struct symbol * s1,
              struct symbol * s2,
              struct symbol * s3);

struct symbol *newtemp(struct symtable * t);

void code_dump(struct code * c);

void code_free(struct code * c);

char* print_symbol(struct symbol * sym);

void print_quad(FILE * output, struct quad * quadre);

void print_code(FILE * output, struct code * code);

void mips_print(FILE* output, char* str, struct symtable * table);

void mips_int(FILE* output,char* str);

void mips_int_const(FILE* output,char* str, char* value);