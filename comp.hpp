//////////////////////////////////////////////////////////////////////
// comp.hpp -- Compile Routines
// Date: Fri Nov 29 20:31:11 2013   (C) datablocks.net
///////////////////////////////////////////////////////////////////////

#ifndef COMP_HPP
#define COMP_HPP

#include <fstream>

unsigned lex_lineno();
int lex_token();
void register_builtin(const std::string& type);
void lexer_reset();
const std::string& lex_revsym(int symid);

bool gcc_open(std::fstream& fs,int genset,const std::string& suffix=".c");
bool lex_open(int genset,const std::string& suffix);

bool gcc_compile(std::fstream& fs,int genset);
bool gcc_precompile(std::fstream& fs,int genset,const std::string& variation="");
bool gcc_precomplex(int genset,const std::string& variation="");

extern int yyparse();

#endif // COMP_HPP

// End comp.hpp
