//////////////////////////////////////////////////////////////////////
// comp.hpp -- Compile Routines
// Date: Fri Nov 29 20:31:11 2013   (C) datablocks.net
///////////////////////////////////////////////////////////////////////

#ifndef COMP_HPP
#define COMP_HPP

#include <fstream>

bool gcc_open(std::fstream& fs,int genset,const std::string& suffix=".c");
bool gcc_compile(std::fstream& fs,int genset);

#endif // COMP_HPP

// End comp.hpp
