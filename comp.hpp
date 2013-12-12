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
	Ident,		// Identifier
	Typedef,	// Typedef
	Type,		// Type name
	Struct,		// struct
	Union,		// union
	List		// List
};

struct s_node {
	e_ntype		type;		// Node type
	int		symbol;		// Symbol ref
	unsigned	ptr;		// Pointer levels

	std::vector<int> list;		// List 

	int		next;		// Next node in chain

	s_node() { 
		type = None;
		symbol = 0;
		next = 0;
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

extern int yyparse();

#endif // COMP_HPP

// End comp.hpp
