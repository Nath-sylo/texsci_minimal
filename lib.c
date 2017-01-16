
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "lib.h"

struct symtable * symtable_new()
{
    struct symtable * t = malloc(sizeof(struct symtable));
    t->capacity = 1024;
    t->symbols = malloc(t->capacity*sizeof(struct symbol));
    t->temporary = 0;
    t->size = 0;
    t->print = 0;
    return t;
}

static void symtable_grow(struct symtable * t) 
{
    t->capacity += 1024;
    t->symbols = realloc(t->symbols,t->capacity*sizeof(struct symbol));
    if(t->symbols == NULL) 
    {
      fprintf(stderr,"Error attempting to grow symbol table (actual size is %d)\n",t->size);
        exit(1);
    }
}

struct symbol * symtable_const(struct symtable * t, char * v) 
{
    unsigned int i;
    for ( i=0 ; i<t->size && t->symbols[i].u.value != v; i++ );
    if(i==t->size)
    {
        if(t->size==t->capacity)
          symtable_grow(t);
        struct symbol *s = &(t->symbols[t->size]);
        s->kind = CONSTANT;
        s->u.value = v;
        ++ (t->size);
        return s;
    }
    else 
    {
        return &(t->symbols[i]);
    }
}

struct symbol * symtable_get(struct symtable * t, const char * id) 
{
    unsigned int i;
    for ( i=0 ; i<t->size && strcmp(t->symbols[i].u.name,id) != 0; i++ );
    if(i<t->size)
      return &(t->symbols[i]);
    return NULL;
}

struct symbol * symtable_put(struct symtable * t, const char * id) 
{
    if(t->size==t->capacity)
      symtable_grow(t);
    struct symbol *s = &(t->symbols[t->size]);
    s->kind = NAME;
    s->u.name = strdup(id);
    ++ (t->size);
    return s;
}

void symtable_dump(struct symtable * t)
{
    unsigned int i;
    for ( i=0 ; i<t->size; i++ )
    {
      if(t->symbols[i].kind==CONSTANT)
        printf("       %p = %s\n",&(t->symbols[i]),t->symbols[i].u.value);
      if(t->symbols[i].kind==NAME)
        printf("       %p = %s\n",&(t->symbols[i]),t->symbols[i].u.name);
    }
    printf("       --------\n");
}

void symtable_free(struct symtable * t)
{
    free(t->symbols);
    free(t);
}

struct code * code_new()
{
    struct code * r = malloc(sizeof(struct code));
    r->capacity = 1024;
    r->quads = malloc(r->capacity*sizeof(struct quad));
    r->nextquad = 0;
    return r;
}

static void code_grow(struct code * c)
{
    c->capacity += 1024;
    c->quads = realloc(c->quads,c->capacity*sizeof(struct quad));
    if(c->quads == NULL) 
    {
      fprintf(stderr,"Error attempting to grow quad list (actual size is %d)\n",c->nextquad);
        exit(1);
    }
}

void gencode(struct code * c,
              enum quad_kind k,
              struct symbol * s1,
              struct symbol * s2,
              struct symbol * s3)
{
    if ( c->nextquad == c->capacity )
        code_grow(c);
    struct quad * q = &(c->quads[c->nextquad]);
    q->kind = k;
    q->sym1 = s1;
    q->sym2 = s2;
    q->sym3 = s3;
    ++ (c->nextquad);
}

struct symbol *newtemp(struct symtable * t)
{
  struct symbol * s;
  char* name = malloc(32*sizeof(char));
  sprintf(name,"t%d",t->temporary);
  s = symtable_put(t,name);
  ++ (t->temporary);
  return s;
}

static void symbol_dump(struct symbol * s)
{
    switch ( s->kind )
    {
        case NAME:
            printf("%s",s->u.name);
            break;
        case CONSTANT:
            printf("%s",s->u.value);
            break;
        default:
            break;
    }
}

static void quad_dump(struct quad * q)
{
    switch ( q->kind )
    {
        case BOP_PLUS:
            symbol_dump(q->sym1);
            printf(" := ");
            symbol_dump(q->sym2);
            printf(" + ");
            symbol_dump(q->sym3);
            break;
        case BOP_MINUS:
            symbol_dump(q->sym1);
            printf(" := ");
            symbol_dump(q->sym2);
            printf(" - ");
            symbol_dump(q->sym3);
            break;
        case BOP_MULT:
            symbol_dump(q->sym1);
            printf(" := ");
            symbol_dump(q->sym2);
            printf(" * ");
            symbol_dump(q->sym3);
            break;
        case UOP_MINUS:
            symbol_dump(q->sym1);
            printf(" := ");
            printf("- ");
            symbol_dump(q->sym2);
            break;
        case CALL_PRINT:
            printf("print ");
            symbol_dump(q->sym1);
            break;
        case COPY:
            symbol_dump(q->sym1);
            printf(" := ");
            symbol_dump(q->sym2);
            break;
        default:
            printf("BUG\n");
            break;
    }
}

void code_dump(struct code * c)
{
    unsigned int i;
    for ( i=0 ; i<c->nextquad ; i++ )
    {
        printf("%4u | ",i);
        quad_dump(&(c->quads[i]));
        printf("\n");
    }
}

void code_free(struct code * c)
{
    free(c->quads);
    free(c);
}

char* print_symbol(struct symbol * sym){
    
    switch(sym->kind){
        case NAME:
            return sym->u.name;
            break;
        case CONSTANT:
            return sym->u.value;
            break;
        default:
            return NULL;
            break;
    }
}

void print_quad(FILE * output, struct quad * quadre){

    char* s1 = NULL;
    char* s2 = NULL;
    char* s3 = NULL;
    switch ( quadre->kind )
    {
        case BOP_PLUS:
            s1=print_symbol(quadre->sym1);
            s2=print_symbol(quadre->sym2);
            s3=print_symbol(quadre->sym3);
            if(quadre->sym2->kind == CONSTANT){
                fprintf(output, "\t\tli $t0, %s\n", s2);
            }
            else if (s2[0] != '$'){
                fprintf(output, "\t\tlw $t0, %s\n", s2);
            }
            if(quadre->sym3->kind == CONSTANT){
                fprintf(output, "\t\tli $t1, %s\n", s3);
            }
            else if (s3[0] != '$'){
                fprintf(output, "\t\tlw $t1, %s\n", s3);
            }

            if ((s2[0] != '$') && (s3[0] != '$')){
                fprintf(output, "add %s, $t0, $t1\n", s1);
            }
            else{
                if ((s2[0]=='$') && (s3[0]=='$')) fprintf(output, "add %s, %s, %s\n",s1,s2,s3);
                else if(s3[0]=='$') fprintf(output, "add %s, %s, $t1\n",s1,s2);
                else if(s2[0]=='$') fprintf(output, "add %s, $t2, %s\n",s1,s3);
                
            }
            break;
        case BOP_MINUS:
            s1=print_symbol(quadre->sym1);
            s2=print_symbol(quadre->sym2);
            s3=print_symbol(quadre->sym3);
            if(quadre->sym2->kind == CONSTANT){
                fprintf(output, "\t\tli $t0, %s\n", s2);
            }
            else if (s2[0] != '$'){
                fprintf(output, "\t\tlw $t0, %s\n", s2);
            }
            if(quadre->sym3->kind == CONSTANT){
                fprintf(output, "\t\tli $t1, %s\n", s3);
            }
            else if (s3[0] != '$'){
                fprintf(output, "\t\tlw $t1, %s\n", s3);
            }

            if ((s2[0] != '$') && (s3[0] != '$')){
                fprintf(output, "sub %s, $t0, $t1\n", s1);
            }
            if((s2[0]=='$') || (s3[0]=='$')){
                if(s3[0]!='$') fprintf(output, "sub %s, %s, $t1\n",s1,s2);
                else if(s2[0]!='$') fprintf(output, "sub %s, $t2, %s\n",s1,s3);
                else fprintf(output, "sub %s, %s, %s\n",s1,s2,s3);
            }
            break;
        case BOP_MULT:
            s1=print_symbol(quadre->sym1);
            s2=print_symbol(quadre->sym2);
            s3=print_symbol(quadre->sym3);
            break;
        case UOP_MINUS:
            s1=print_symbol(quadre->sym1);
            s2=print_symbol(quadre->sym2);
            s3=print_symbol(quadre->sym3);
            break;
        case CALL_PRINT:
            s1=print_symbol(quadre->sym1);
            fprintf(output, "\t\tli $v0, 1\n");
            fprintf(output, "\t\tlw $a0, %s\n", s1);
            fprintf(output, "\t\tsyscall\n");

            fprintf(output, "\t\tli $v0, 4\n");
            fprintf(output, "\t\tla $a0, print\n");
            fprintf(output, "\t\tsyscall\n");
            break;
        case CALL_TEXT:
            s1=print_symbol(quadre->sym1);
            fprintf(output, "\t\tli $v0, 4\n");
            fprintf(output, "\t\tla $a0, %s\n", s1);
            fprintf(output, "\t\tsyscall\n");
            break;
        case COPY:
            s1=print_symbol(quadre->sym1);
            s2=print_symbol(quadre->sym2);
            if (s2[0] == '$') fprintf(output, "\t\t sw %s, %s\n",s2, s1);
            else {
                fprintf(output, "\t\tli $t0, %s\n",s2);
                fprintf(output, "\t\tsw $t0, %s\n",s1);
            }
            break;
        default:
            printf("BUG\n");
            break;
    }

}

void print_code(FILE * output, struct code * code){

    int i;
    for (i=0; i < code->nextquad; i++){
        print_quad(output, &code->quads[i]);
    }
}

void mips_print(FILE* output, char* str, struct symtable * table){
    fprintf(output," print%d: .asciiz %s \n", table->print, str);
    ++ (table->print);
}
void mips_int(FILE* output,char* str){
        fprintf(output, " %s: .word 0\n", str);
}
void mips_int_const(FILE* output,char* str, char* value){
        fprintf(output, " %s: .word %s\n", str, value);
}