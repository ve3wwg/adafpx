/* ANSI C Yacc grammar
 * 
 * In 1985, Jeff Lee published his Yacc grammar for the April 30, 1985
 * draft version of the ANSI C standard.  Tom Stockfisch reposted it to
 * net.sources in 1987; that original, as mentioned in the answer to
 * question 17.25 of the comp.lang.c FAQ, used to be available via ftp from
 * ftp.uu.net as usenet/net.sources/ansi.c.grammar.Z The version you see
 * here has been updated based on an 1999 draft of the standards document.
 * It allows for restricted pointers, variable arrays, "inline", and
 * designated initializers. The previous version's lex and yacc files (ANSI
 * C as of ca 1995) are still around as archived copies. I want to keep
 * this version as close to the current C Standard grammar as possible;
 * please let me know if you discover discrepancies. (If you feel like
 * it, read the FAQ first.)
 * 
 * Jutta Degener, 2012
 */
%{
#define YYDEBUG 1

#include <iostream>
#include <vector>

#include <stdio.h>
#include <assert.h>
#include "glue.hpp"
#include "comp.hpp"
#include "ansi-c-yacc.hpp"

static void yyerror(char const *s);

unsigned lex_lineno();

static const char *to_string(e_ntype type);
static void dump(s_node& node,const char *desc=0,int level=0);
static void dump(int lval,const char *desc);

static int Node(s_node& node);
s_node& Get(int nno);
static int Append(s_node& node,int nodeno);

std::string yytarget;
int yytarget_struct = 0;

#define YYSTYPE 	int

extern int yylex();
%}

%token IDENTIFIER CONSTANT STRING_LITERAL SIZEOF
%token PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token XOR_ASSIGN OR_ASSIGN TYPE_NAME

%token TYPEDEF EXTERN STATIC AUTO REGISTER INLINE RESTRICT
%token CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE CONST VOLATILE VOID
%token BOOL COMPLEX IMAGINARY
%token STRUCT UNION ENUM ELLIPSIS

%token CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN

%token ATTRIBUTE ASM

%start translation_unit
%%

/* int open(const char *, int, ...) __asm("_" "open" ); */

/* asm_clause
	: ASM '(' asm_list ')'
	;
*/

asm_list
	: STRING_LITERAL
	| asm_list STRING_LITERAL ;

attribute_clause_list
	: attribute_clause
	| attribute_clause_list attribute_clause
	| ;

attribute_clause
	: ATTRIBUTE '(' '(' ')' ')'
	| ATTRIBUTE '(' '(' IDENTIFIER ')' ')'
	| ATTRIBUTE '(' '(' CONST ')' ')'
	| ATTRIBUTE '(' '(' IDENTIFIER '(' attribute_list ')' ')' ')'
	;

attribute_list
	: attr_parm
	| attribute_list ',' attr_parm
	;

attr_parm
	: IDENTIFIER
	| IDENTIFIER '=' attr_const
	| CONSTANT
	;

attr_const
	: IDENTIFIER
	| STRING_LITERAL
	| CONSTANT;

primary_expression
	: IDENTIFIER {
		s_node node;
		node.type = Ident;
		node.symbol = $1;
		dump(node,"IDENTIFIER");
		$$ = Node(node);
	}
	| CONSTANT
	| STRING_LITERAL
	| '(' expression ')'
	;

postfix_expression
	: primary_expression
	| postfix_expression '[' expression ']'
	| postfix_expression '(' ')'
	| postfix_expression '(' argument_expression_list ')'
	| postfix_expression '.' IDENTIFIER
	| postfix_expression PTR_OP IDENTIFIER
	| postfix_expression INC_OP
	| postfix_expression DEC_OP
	| '(' type_name ')' '{' initializer_list '}'
	| '(' type_name ')' '{' initializer_list ',' '}'
	;

argument_expression_list
	: assignment_expression
	| argument_expression_list ',' assignment_expression
	;

unary_expression
	: postfix_expression
	| INC_OP unary_expression
	| DEC_OP unary_expression
	| unary_operator cast_expression
	| SIZEOF unary_expression
	| SIZEOF '(' type_name ')'
	;

unary_operator
	: '&'
	| '*'
	| '+'
	| '-'
	| '~'
	| '!'
	;

cast_expression
	: unary_expression
	| '(' type_name ')' cast_expression
	;

multiplicative_expression
	: cast_expression
	| multiplicative_expression '*' cast_expression
	| multiplicative_expression '/' cast_expression
	| multiplicative_expression '%' cast_expression
	;

additive_expression
	: multiplicative_expression
	| additive_expression '+' multiplicative_expression
	| additive_expression '-' multiplicative_expression
	;

shift_expression
	: additive_expression
	| shift_expression LEFT_OP additive_expression
	| shift_expression RIGHT_OP additive_expression
	;

relational_expression
	: shift_expression
	| relational_expression '<' shift_expression
	| relational_expression '>' shift_expression
	| relational_expression LE_OP shift_expression
	| relational_expression GE_OP shift_expression
	;

equality_expression
	: relational_expression
	| equality_expression EQ_OP relational_expression
	| equality_expression NE_OP relational_expression
	;

and_expression
	: equality_expression
	| and_expression '&' equality_expression
	;

exclusive_or_expression
	: and_expression
	| exclusive_or_expression '^' and_expression
	;

inclusive_or_expression
	: exclusive_or_expression
	| inclusive_or_expression '|' exclusive_or_expression
	;

logical_and_expression
	: inclusive_or_expression
	| logical_and_expression AND_OP inclusive_or_expression
	;

logical_or_expression
	: logical_and_expression
	| logical_or_expression OR_OP logical_and_expression
	;

conditional_expression
	: logical_or_expression
	| logical_or_expression '?' expression ':' conditional_expression
	;

assignment_expression
	: conditional_expression
	| unary_expression assignment_operator assignment_expression
	;

assignment_operator
	: '='
	| MUL_ASSIGN
	| DIV_ASSIGN
	| MOD_ASSIGN
	| ADD_ASSIGN
	| SUB_ASSIGN
	| LEFT_ASSIGN
	| RIGHT_ASSIGN
	| AND_ASSIGN
	| XOR_ASSIGN
	| OR_ASSIGN
	;

expression
	: assignment_expression
	| expression ',' assignment_expression
	;

constant_expression
	: conditional_expression
	;

declaration
	: declaration_specifiers ';' {
		$$ = $1;
		dump($$,"declaration_specifiers ';'");
	}
	| attribute_clause declaration_specifiers ';' {
		$$ = $2;
		dump($$,"attr declaration_specifiers ';'");
	}
	| declaration_specifiers init_declarator_list ';' {
		if ( $1 != 0 ) {
			s_node& decl = Get($1);

			dump(decl,"declaration_specifiers");

			if ( decl.type == Typedef ) {
				s_node& node = Get($2);

				decl.next = $2;
				dump(decl,"init_declarator_list");

				for ( auto it=node.list.begin(); it != node.list.end(); ++it ) {
					int nid = *it;
					s_node& tnode = Get(nid);
					register_type(tnode.symbol);
				}
			}
		}
		$$ = $1;
	}
	| attribute_clause declaration_specifiers init_declarator_list ';' {
		if ( $2 != 0 ) {
			s_node& decl = Get($2);

			dump(decl,"attr + declaration_specifiers");

			if ( decl.type == Typedef ) {
				s_node& node = Get($3);

				dump(node,"attr + init_declaration_list");

				for ( auto it=node.list.begin(); it != node.list.end(); ++it ) {
					s_node& dnode = Get(*it);
					assert(dnode.type == Ident);
					register_type(dnode.symbol);	// Register this symbol as a type with lexer
				}
			}
		}
		$$ = $2;
		dump($$,"attr declaration_specifiers init_declarator_list ';'");
	}
	;

declaration_specifiers
	: storage_class_specifier {
		$$ = $1;
		dump($$,"storage_class_specifier");
	}
	| storage_class_specifier declaration_specifiers {
		if ( !$1 ) {
			$$ = $2;
		} else if ( !$2 ) {
			$$ = $1;
		} else	{
			s_node& node1 = Get($1);

			node1.next = $2;
			dump(node1,"storage_class_specifier declaration_specifiers");
		}
		dump($1,"storage_class_specifier");
	}
	| type_specifier {
		$$ = 0;		// Ignore these
	}
	| type_specifier declaration_specifiers {
		$$ = $2;
		dump($$,"type_specifier declaration_specifiers");
	}
	| type_qualifier {
		$$ = 0;
	}
	| type_qualifier declaration_specifiers {
		$$ = $2;
		dump($$,"type_qualifier declaration_specifiers");
	}
	| function_specifier {
		$$ = 0;
		dump($$,"function_specifier");
	}
	| function_specifier declaration_specifiers {
		$$ = $2;
		dump($$,"function_specifier declaration_specifiers");
	}
	;

init_declarator_list
	: init_declarator {
		s_node node;
		node.type = List;
		node.list.push_back($1);
		$$ = Node(node);
		dump($$,"init_declarator");
	}
	| init_declarator_list ',' init_declarator {
		s_node& node = Get($1);
		node.list.push_back($2);
		$$ = $1;
		dump($$,"init_declarator_list init_declarator");
	}
	;

init_declarator
	: declarator {
		$$ = $1;
		dump($$,"declarator");
	}
	| declarator attribute_clause attribute_clause_list {
		$$ = $1;
		dump($$,"declarator attr attr_list");
	}
	| declarator ASM '(' asm_list ')' {
		$$ = $1;
		dump($$,"declarator ASM (...)");
	}
	| declarator '=' initializer {
		$$ = $1;
		dump($$,"declarator '=' initializer");
	}
	;

storage_class_specifier
	: TYPEDEF {
		s_node node;
		node.type = Typedef;
		$$ = Node(node);
		dump($$,"storage_class_specifier");
std::cout << "Storage_Class_Specifier $$ = " << $$ << " node.type = " << Get($$).type << "\n";
	}
	| EXTERN {
		$$ = 0;
	}
	| STATIC {
		$$ = 0;
	}
	| AUTO {
		$$ = 0;
	}
	| REGISTER {
		$$ = 0;
	}
	;

type_specifier
	: VOID {
		$$ = 0;
	}
	| CHAR {
		$$ = 0;
	}
	| SHORT {
		$$ = 0;
	}
	| INT {
		$$ = 0;
	}
	| LONG {
		$$ = 0;
	}
	| FLOAT {
		$$ = 0;
	}
	| DOUBLE {
		$$ = 0;
	}
	| SIGNED {
		$$ = 0;
	}
	| UNSIGNED {
		$$ = 0;
	}
	| BOOL {
		$$ = 0;
	}
	| COMPLEX {
		$$ = 0;
	}
	| IMAGINARY {
		$$ = 0;
	}
	| struct_or_union_specifier {
		s_node& node = Get($1);
		$$ = $1;
		dump($$,"struct_or_union_specifier");
	}
	| enum_specifier {
		$$ = $1;
		dump($$,"enum_specifier");
	}
	| TYPE_NAME {
		s_node node;
		node.type = Type;
		node.symbol = $1;
		$$ = Node(node);
		dump($$,"TYPE_NAME");
	}
	;

struct_or_union_specifier
	: struct_or_union IDENTIFIER '{' struct_declaration_list '}' attribute_clause_list {
		assert($1);
		assert($2);
		assert($4);
		s_node& node = Get($1);
		node.symbol = $2;
		node.next = $4;
		$$ = $1;
		dump($$,"struct_or_union IDENTIFIER '{' struct_declaration_list '}' attr");
		if ( lex_revsym($2) == yytarget )
			yytarget_struct = $$;

	}
	| struct_or_union '{' struct_declaration_list '}' attribute_clause_list {
		s_node& node = Get($1);
		node.symbol = 0;		// Anonymous struct/union
		node.next = $3;
		$$ = $1;
		dump($$,"struct_or_union '{' struct_declaration_list '}' attribute_clause_list");
	}
	| struct_or_union IDENTIFIER {
		s_node& node = Get($1);
		node.symbol = $2;
		node.next = 0;
		$$ = $1;
		dump($$,"struct_or_union IDENTIFIER");
	}
	;

struct_or_union
	: STRUCT {
		s_node node;
		node.type = Struct;
		node.symbol = 0;
		$$ = Node(node);
		dump($$,"***STRUCT***");
	}
	| UNION {
		s_node node;
		node.type = Union;
		node.symbol = 0;
		$$ = Node(node);
		dump($$,"***UNION***");
	}
	;

struct_declaration_list
	: struct_declaration {
		s_node node;
		node.type = List;
		node.list.push_back($1);
		$$ = Node(node);
		dump($$,"struct_dclaration");
	}
	| struct_declaration_list struct_declaration {
		s_node& node = Get($1);
		s_node& node2 = Get($2);

		if ( node2.type != Type || !node.next ) {
			node.list.push_back($2);
		} else	{
			node.list.push_back(node2.next);
		}
		$$ = $1;
		dump($$,"struct_declaration_list struct_declaration");
	}
	;

struct_declaration
	: specifier_qualifier_list struct_declarator_list ';' {
		if ( $1 ) {
			s_node& node = Get($1);
			node.next = $2;
			$$ = $1;
		} else	{
			$$ = $2;
		}
		dump($$,"specifier_qualifier_list struct_declarator_list ';'");
	}
	;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list {
		if ( $1 ) {
			if ( $2 ) {
				s_node& node = Get($1);
				node.list.push_back($2);
			}
			$$ = $1;
		} else	{
			$$ = $2;
		}
		dump($$,"type_specifier specifier_qualifier_list");
	}
	| type_specifier
	| type_qualifier specifier_qualifier_list {
		$$ = $2;
		dump($$,"type_qualifier specifier_qualifier_list");
	}
	| type_qualifier {
		$$ = 0;		// Ignore these
	}
	;

struct_declarator_list
	: struct_declarator
	| struct_declarator_list ',' struct_declarator
	;

struct_declarator
	: declarator
	| ':' constant_expression
	| declarator ':' constant_expression
	;

enum_specifier
	: ENUM '{' enumerator_list '}'
	| ENUM IDENTIFIER '{' enumerator_list '}'
	| ENUM '{' enumerator_list ',' '}'
	| ENUM IDENTIFIER '{' enumerator_list ',' '}'
	| ENUM IDENTIFIER
	;

enumerator_list
	: enumerator
	| enumerator_list ',' enumerator
	;

enumerator
	: IDENTIFIER
	| IDENTIFIER '=' constant_expression
	;

type_qualifier
	: CONST {
		$$ = 0;
	}
	| RESTRICT {
		$$ = 0;
	}
	| VOLATILE {
		$$ = 0;
	}
	;

function_specifier
	: INLINE {
		$$ = 0;
	}
	;

declarator
	: pointer direct_declarator {
		s_node& node = Get($1);
		++node.ptr;
		$$ = $2;
		dump($$,"pointer direct_declarator");
	}
	| direct_declarator {
		$$ = $1;
		dump($$,"direct_declarator");
	}
	;

direct_declarator
	: IDENTIFIER {
		s_node node;
		node.type = Ident;
		node.symbol = $1;
		$$ = Node(node);
		dump($$,"Identifier");
	}
	| '(' declarator ')' {
		$$ = $2;
		dump($$,"(declarator)");
	}
	| direct_declarator '[' type_qualifier_list assignment_expression ']'
	| direct_declarator '[' type_qualifier_list ']'
	| direct_declarator '[' assignment_expression ']'
	| direct_declarator '[' STATIC type_qualifier_list assignment_expression ']'
	| direct_declarator '[' type_qualifier_list STATIC assignment_expression ']'
	| direct_declarator '[' type_qualifier_list '*' ']'
	| direct_declarator '[' '*' ']'
	| direct_declarator '[' ']'
	| direct_declarator '(' parameter_type_list ')'
	| direct_declarator '(' identifier_list ')' {
		dump($$,"direct_declarator '(' identifier_list ')'");
	}
	| direct_declarator '(' ')' {
		$$ = $1;
		dump($$,"direct_declarator '(' ')'");
	}
	;

pointer
	: '*'
	| '*' type_qualifier_list
	| '*' pointer
	| '*' type_qualifier_list pointer
	;

type_qualifier_list
	: type_qualifier
	| type_qualifier_list type_qualifier
	;

parameter_type_list
	: parameter_list
	| parameter_list ',' ELLIPSIS
	;

parameter_list
	: parameter_declaration
	| parameter_list ',' parameter_declaration
	;

parameter_declaration
	: declaration_specifiers declarator
	| declaration_specifiers abstract_declarator
	| declaration_specifiers
	;

identifier_list
	: IDENTIFIER
	| identifier_list ',' IDENTIFIER
	;

type_name
	: specifier_qualifier_list
	| specifier_qualifier_list abstract_declarator
	;

abstract_declarator
	: pointer
	| direct_abstract_declarator
	| pointer direct_abstract_declarator
	;

direct_abstract_declarator
	: '(' abstract_declarator ')'
	| '[' ']'
	| '[' assignment_expression ']'
	| direct_abstract_declarator '[' ']'
	| direct_abstract_declarator '[' assignment_expression ']'
	| '[' '*' ']'
	| direct_abstract_declarator '[' '*' ']'
	| '(' ')'
	| '(' parameter_type_list ')'
	| direct_abstract_declarator '(' ')'
	| direct_abstract_declarator '(' parameter_type_list ')'
	;

initializer
	: assignment_expression
	| '{' initializer_list '}'
	| '{' initializer_list ',' '}'
	;

initializer_list
	: initializer
	| designation initializer
	| initializer_list ',' initializer
	| initializer_list ',' designation initializer
	;

designation
	: designator_list '='
	;

designator_list
	: designator
	| designator_list designator
	;

designator
	: '[' constant_expression ']'
	| '.' IDENTIFIER
	;

statement
	: labeled_statement
	| compound_statement
	| expression_statement
	| selection_statement
	| iteration_statement
	| jump_statement
	;

labeled_statement
	: IDENTIFIER ':' statement
	| CASE constant_expression ':' statement
	| DEFAULT ':' statement
	;

compound_statement
	: '{' '}'
	| '{' block_item_list '}'
	;

block_item_list
	: block_item
	| block_item_list block_item
	;

block_item
	: declaration
	| statement
	;

expression_statement
	: ';'
	| expression ';'
	;

selection_statement
	: IF '(' expression ')' statement
	| IF '(' expression ')' statement ELSE statement
	| SWITCH '(' expression ')' statement
	;

iteration_statement
	: WHILE '(' expression ')' statement
	| DO statement WHILE '(' expression ')' ';'
	| FOR '(' expression_statement expression_statement ')' statement
	| FOR '(' expression_statement expression_statement expression ')' statement
	| FOR '(' declaration expression_statement ')' statement
	| FOR '(' declaration expression_statement expression ')' statement
	;

jump_statement
	: GOTO IDENTIFIER ';'
	| CONTINUE ';'
	| BREAK ';'
	| RETURN ';'
	| RETURN expression ';'
	;

translation_unit
	: external_declaration
	| translation_unit external_declaration
	;

external_declaration
	: function_definition
	| declaration
	;

function_definition
	: declaration_specifiers declarator declaration_list compound_statement
	| declaration_specifiers declarator compound_statement
	;

declaration_list
	: declaration
	| declaration_list declaration
	;

%%
#include <stdio.h>
#include "glue.hpp"

extern char yytext[];
extern int column;

void
yyerror(char const *s) {

	std::cerr << "Error in line " << lex_lineno() << ": " << s << "\n";
	exit(13);
}

static std::unordered_map<int,s_node> nodemap;
static unsigned nodeno = 0;

void
parser_reset() {
	nodeno = 0;
	nodemap.clear();
	yytarget.clear();
	yytarget_struct = 0;
}

static int
Node(s_node& node) {
	nodemap[++nodeno] = node;
	return nodeno;
}

s_node&
Get(int nno) {
	auto it = nodemap.find(nno);
	assert(it != nodemap.end());
	return it->second;
}

static int
Append(int tonode,int nodeno) {

	assert(tonode > 0);

	for (;;) {
		s_node& node = Get(tonode);
		if ( node.next == 0 ) {
			node.next = nodeno;
			break;
		}
		tonode = node.next;
	}

	return tonode;			// Returns node that it was added to
}

std::string
indent(int level) {
	std::string s;

	s.append(level*2,' ');
	return s;
}

static void
dump(int lval,const char *desc) {
	if ( lval <= 0 ) {
		std::cout << "DUMP of node (" << (desc ? desc : "") << "):  null ("
			<< lval << ");\n";
	} else	{
		s_node& node = Get(lval);
		dump(node,desc,0);
	}
}

static void
dump(s_node& node,const char *desc,int level) {

	if ( desc )
		std::cout << indent(level) << "DUMP of node (" << desc << "):\n";
	else	std::cout << indent(level) << "DUMP of node:\n";

	std::cout 	<< indent(level) << "node.type = " << node.type << " ("
			<< to_string(node.type) << ") {\n"
			<< indent(level) << "  .symbol = " << node.symbol;
			
	if ( node.symbol > 0 ) {
		std::string symbol = lex_revsym(node.symbol);
		std::cout << " '" << symbol << "'\n";
	} else	std::cout << "\n";

	for ( auto it=node.list.begin(); it != node.list.end(); ++it ) {
		s_node& lnode = Get(*it);

		dump(lnode,0,level+1);
	}

	if ( node.next > 0 ) {
		s_node& next = Get(node.next);
		dump(next,"next",level+1);
	}

	std::cout << indent(level) << "}\n";
}

static const char *
to_string(e_ntype type) {

	switch ( type ) {
	case None :
		return "None";
	case Ident :
		return "Ident";
	case Typedef :
		return "Typedef";
	case Type :
		return "Type";
	case Struct :
		return "Struct";
	case Union :
		return "Union";
	case List :
		return "List";
	default :
		;
	}
	return "??";
}

/* End ansi-c.yacc */
