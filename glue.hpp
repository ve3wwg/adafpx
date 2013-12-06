//////////////////////////////////////////////////////////////////////
// glue.hpp -- Glue Header
// Date: Wed Nov 27 19:20:33 2013   (C) datablocks.net
///////////////////////////////////////////////////////////////////////

#ifndef GLUE_HPP
#define GLUE_HPP

#include <string>
#include <unordered_map>

extern std::unordered_map<std::string,int> symmap;
extern std::unordered_map<int,std::string> revsym;

unsigned lex_lineno();
int lex_symbol();
const std::string& lex_revsym(int symid);
void register_type(int symid);

int yylex();

void loadconfig();
void comp_macros();
void comp_types();
void comp_systypes();

void emit_basic_types();
void emit_sys_types();
void emit_macros();
void emit_structs();
void emit_section2();

#endif // GLUE_HPP

// End glue.hpp
