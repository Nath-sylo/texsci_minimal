/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton interface for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     MULTOP = 258,
     TEXSCI_BEGIN = 259,
     TEXSCI_END = 260,
     BLANKLINE = 261,
     EMPTY = 262,
     ID = 263,
     INT = 264,
     BOOL = 265,
     REAL = 266,
     STR = 267,
     MIN = 268,
     PLUS = 269,
     PRINTINT = 270,
     PRINTTEXT = 271,
     MBOX = 272,
     LEFT = 273,
     INPUT = 274,
     OUTPUT = 275,
     CONST = 276,
     INTEGER = 277,
     BOOLEAN = 278,
     COMPLEX = 279,
     EQUAL = 280,
     GLOBAL = 281,
     LOCAL = 282,
     CIN = 283,
     ENDINST = 284
   };
#endif
/* Tokens.  */
#define MULTOP 258
#define TEXSCI_BEGIN 259
#define TEXSCI_END 260
#define BLANKLINE 261
#define EMPTY 262
#define ID 263
#define INT 264
#define BOOL 265
#define REAL 266
#define STR 267
#define MIN 268
#define PLUS 269
#define PRINTINT 270
#define PRINTTEXT 271
#define MBOX 272
#define LEFT 273
#define INPUT 274
#define OUTPUT 275
#define CONST 276
#define INTEGER 277
#define BOOLEAN 278
#define COMPLEX 279
#define EQUAL 280
#define GLOBAL 281
#define LOCAL 282
#define CIN 283
#define ENDINST 284




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 17 "texcc.y"
{
  char* name;
  char* val;
  char* str;
}
/* Line 1529 of yacc.c.  */
#line 113 "y.tab.h"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;

