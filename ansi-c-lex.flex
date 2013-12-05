/* ANSI C grammar, Lex specification
 * 
 * In 1985, Jeff Lee published this Lex specification together with a Yacc
 * grammar for the April 30, 1985 ANSI C draft. Tom Stockfisch reposted
 * both to net.sources in 1987; that original, as mentioned in the answer
 * to question 17.25 of the comp.lang.c FAQ, used to be available via ftp
 * from ftp.uu.net as usenet/net.sources/ansi.c.grammar.Z The version you
 * see here has been updated based on an 1999 draft of the standards
 * document. It allows for restricted pointers, variable arrays, "inline",
 * and designated initializers. The previous version's lex and yacc files
 * (ANSI C as of ca 1995) are still around as archived copies. I want to
 * keep this version as close to the current C Standard grammar as
 * possible; please let me know if you discover discrepancies. (If you
 * feel like it, read the FAQ first.)
 * 
 * Jutta Degener, 2012
 */

D			[0-9]
L			[a-zA-Z_]
H			[a-fA-F0-9]
E			([Ee][+-]?{D}+)
P                       ([Pp][+-]?{D}+)
FS			(f|F|l|L)
IS                      ((u|U)|(u|U)?(l|L|ll|LL)|(l|L|ll|LL)(u|U))

%{
#include <stdio.h>
#include <stdarg.h>
#include <assert.h>

#include "glue.hpp"
#include "ansi-c-yacc.hpp"

#include <string>

std::unordered_map<std::string,int> symmap;
std::unordered_map<int,std::string> revsym;

static void comment();
static void count();
static void lex_error(const char *format,...);
extern int comp_input();
static int reg_sym(const char *text);

int lex_symid = -1;

extern unsigned lex_lineno();

#define YY_INPUT(buf,result,max_size) { \
       int c = comp_input(); \
       result = (c == EOF) ? YY_NULL : (buf[0] = c, 1); \
}

%}

%%
"/*"			{ comment(); }
"//"[^\n]*              { /* consume //-comment */ }
"auto"			{ count(); return(AUTO); }
"_Bool"			{ count(); return(BOOL); }
"break"			{ count(); return(BREAK); }
"case"			{ count(); return(CASE); }
"char"			{ count(); return(CHAR); }
"_Complex"		{ count(); return(COMPLEX); }
"const"			{ count(); return(CONST); }
"continue"		{ count(); return(CONTINUE); }
"default"		{ count(); return(DEFAULT); }
"do"			{ count(); return(DO); }
"double"		{ count(); return(DOUBLE); }
"else"			{ count(); return(ELSE); }
"enum"			{ count(); return(ENUM); }
"extern"		{ count(); return(EXTERN); }
"float"			{ count(); return(FLOAT); }
"for"			{ count(); return(FOR); }
"goto"			{ count(); return(GOTO); }
"if"			{ count(); return(IF); }
"_Imaginary"		{ count(); return(IMAGINARY); }
"inline"		{ count(); return(INLINE); }
"int"			{ count(); return(INT); }
"long"			{ count(); return(LONG); }
"register"		{ count(); return(REGISTER); }
"restrict"		{ count(); return(RESTRICT); }
"return"		{ count(); return(RETURN); }
"short"			{ count(); return(SHORT); }
"signed"		{ count(); return(SIGNED); }
"sizeof"		{ count(); return(SIZEOF); }
"static"		{ count(); return(STATIC); }
"struct"		{ count(); return(STRUCT); }
"switch"		{ count(); return(SWITCH); }
"typedef"		{ count(); return(TYPEDEF); }
"union"			{ count(); return(UNION); }
"unsigned"		{ count(); return(UNSIGNED); }
"void"			{ count(); return(VOID); }
"volatile"		{ count(); return(VOLATILE); }
"while"			{ count(); return(WHILE); }

{L}({L}|{D})*		{ count(); reg_sym(yytext); return(IDENTIFIER); }

0[xX]{H}+{IS}?		{ count(); reg_sym(yytext); return(CONSTANT); }
0[0-7]*{IS}?		{ count(); reg_sym(yytext); return(CONSTANT); }
[1-9]{D}*{IS}?		{ count(); reg_sym(yytext); return(CONSTANT); }
L?'(\\.|[^\\'\n])+'	{ count(); reg_sym(yytext); return(CONSTANT); }

{D}+{E}{FS}?		{ count(); reg_sym(yytext); return(CONSTANT); }
{D}*"."{D}+{E}?{FS}?	{ count(); reg_sym(yytext); return(CONSTANT); }
{D}+"."{D}*{E}?{FS}?	{ count(); reg_sym(yytext); return(CONSTANT); }
0[xX]{H}+{P}{FS}?	{ count(); reg_sym(yytext); return(CONSTANT); }
0[xX]{H}*"."{H}+{P}?{FS}?     { count(); reg_sym(yytext); return(CONSTANT); }
0[xX]{H}+"."{H}*{P}?{FS}?     { count(); reg_sym(yytext); return(CONSTANT); }


L?\"(\\.|[^\\"\n])*\"	{ count(); reg_sym(yytext); return(STRING_LITERAL); }

"..."			{ count(); return(ELLIPSIS); }
">>="			{ count(); return(RIGHT_ASSIGN); }
"<<="			{ count(); return(LEFT_ASSIGN); }
"+="			{ count(); return(ADD_ASSIGN); }
"-="			{ count(); return(SUB_ASSIGN); }
"*="			{ count(); return(MUL_ASSIGN); }
"/="			{ count(); return(DIV_ASSIGN); }
"%="			{ count(); return(MOD_ASSIGN); }
"&="			{ count(); return(AND_ASSIGN); }
"^="			{ count(); return(XOR_ASSIGN); }
"|="			{ count(); return(OR_ASSIGN); }
">>"			{ count(); return(RIGHT_OP); }
"<<"			{ count(); return(LEFT_OP); }
"++"			{ count(); return(INC_OP); }
"--"			{ count(); return(DEC_OP); }
"->"			{ count(); return(PTR_OP); }
"&&"			{ count(); return(AND_OP); }
"||"			{ count(); return(OR_OP); }
"<="			{ count(); return(LE_OP); }
">="			{ count(); return(GE_OP); }
"=="			{ count(); return(EQ_OP); }
"!="			{ count(); return(NE_OP); }
";"			{ count(); return(';'); }
("{"|"<%")		{ count(); return('{'); }
("}"|"%>")		{ count(); return('}'); }
","			{ count(); return(','); }
":"			{ count(); return(':'); }
"="			{ count(); return('='); }
"("			{ count(); return('('); }
")"			{ count(); return(')'); }
("["|"<:")		{ count(); return('['); }
("]"|":>")		{ count(); return(']'); }
"."			{ count(); return('.'); }
"&"			{ count(); return('&'); }
"!"			{ count(); return('!'); }
"~"			{ count(); return('~'); }
"-"			{ count(); return('-'); }
"+"			{ count(); return('+'); }
"*"			{ count(); return('*'); }
"/"			{ count(); return('/'); }
"%"			{ count(); return('%'); }
"<"			{ count(); return('<'); }
">"			{ count(); return('>'); }
"^"			{ count(); return('^'); }
"|"			{ count(); return('|'); }
"?"			{ count(); return('?'); }

[ \t\v\n\f]		{ count(); }
.			{ /* Add code to complain about unmatched characters */ }

%%

int 
yywrap() {
	return 1;
}

static void
comment() {
	char c, prev = 0;
	unsigned line_no = lex_lineno();
  
	while ( (c = yyinput()) != 0 ) {	/* (EOF maps to 0) */
		if ( c == '/' && prev == '*' )
			return;
		prev = c;
	}
	lex_error("Unterminated comment in line %u\n",line_no);
}

unsigned column = 0;

int
lex_token() {
	return lex_symid;
}

static void
count() {
	lex_symid = -1;
}

static void
lex_error(const char *format,...) {
	va_list ap;

	fflush(stdout);

	fprintf(stderr,"Lexical error: ");
	va_start(ap,format);
	vfprintf(stderr,format,ap);
	va_end(ap);
	fflush(stderr);
}

static int
reg_sym(const char *text) {
	static int nsymid = 0;

	auto it = symmap.find(text);
	if ( it != symmap.end() )
		return it->second;	// Sym id

	symmap[text] = ++nsymid;	// Allocate a symbol id
	revsym[nsymid] = text;

	lex_symid = nsymid;
	return lex_symid;
}

/* End ansi-c-lex.flex */
