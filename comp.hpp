//////////////////////////////////////////////////////////////////////
// comp.hpp -- Compile Routines
// Date: Fri Nov 29 20:31:11 2013   (C) datablocks.net
///////////////////////////////////////////////////////////////////////

#ifndef COMP_HPP
#define COMP_HPP

#include <fstream>
#include <vector>

enum e_ntype {
	None = 0,
	Token,		// Lexical token (.ltoken)
	Ident,		// Identifier
	Constant,	// Constant
	StringLit,	// String literal
	Typedef,	// Typedef
	Type,		// Type name
	Struct,		// struct
	Union,		// union
	ArrayRef,	// [ ] ref
	List		// List
};

struct s_node {
	e_ntype		type;		// Node type
	int		symbol;		// Symbol ref
	int		ltoken;		// Lexical token or 0
	unsigned	ptr;		// Pointer levels

	std::vector<int> list;		// List 

	int		next;		// Next node in chain
	int		next2;
	int		next3;

	s_node() { 
		type = None;
		symbol = 0;
		ltoken = 0;
		next = next2 = next3 = 0;
		ptr = 0;
	}
};

extern std::string yytarget;
extern int yytarget_struct;

unsigned lex_lineno();
int lex_token();
void register_builtin(const std::string& type);
void register_type(int symid);
void lexer_reset();
const std::string& lex_revsym(int symid);

void parser_reset();
s_node& Get(int nno);

bool gcc_open(std::fstream& fs,int genset,const std::string& suffix=".c");
bool lex_open(int genset,const std::string& suffix);

bool gcc_compile(std::fstream& fs,int genset);
bool gcc_precompile(std::fstream& fs,int genset,const std::string& variation="");
bool gcc_precomplex(int genset,const std::string& variation="");

void parse(std::vector<std::string>& svec,const std::string s,const std::string delim="|");

extern int yyparse();

#endif // COMP_HPP

// End comp.hpp
