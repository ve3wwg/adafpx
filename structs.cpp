///////////////////////////////////////////////////////////////////////
// structs.cpp -- Compile struct Definitions
// Date: Wed Dec  4 07:44:18 2013
///////////////////////////////////////////////////////////////////////

#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <assert.h>

#include <iostream>
#include <fstream>

#include "config.hpp"
#include "comp.hpp"
#include "glue.hpp"

static void
emit_struct(s_config::s_structs::s_struct& node) {
	std::fstream c;
	int genset = node.genset;

	if ( !gcc_open(c,node.genset) )
		exit(2);

	for ( auto it=node.includes.begin(); it != node.includes.end(); ++it ) {
		const std::string& incl = *it;
		if ( incl[0] != '.' )
			c << "#include <" << incl << ">\n";
		else	c << "#include \"" << incl << "\"\n";
	}

	c.close();

	if ( !gcc_precomplex(genset) )
		exit(2);

	parser_reset();
	yytarget = node.c_name;
	yytarget_struct = 0;
	yyparse();

	std::cout << "GOT STRUCT '" << yytarget << "' ID := " << yytarget_struct << "\n";

	if ( yytarget_struct <= 0 ) {
		std::cerr << "struct " << yytarget << " is unknown? (Genset " << genset << ")\n";
		exit(3);
	}

	if ( !gcc_open(c,++genset) )
		exit(2);

	c << "#include <stdio.h>\n"
	  << "#include <stdlib.h>\n"
	  << "#include <string.h>\n";

	for ( auto it=node.includes.begin(); it != node.includes.end(); ++it ) {
		const std::string& incl = *it;
		if ( incl[0] != '.' )
			c << "#include <" << incl << ">\n";
		else	c << "#include \"" << incl << "\"\n";
	}

	c	<< "\n"
		<< "#define offsetof(member) (unsigned) (((char*)&test_struct.member) - ((char*)&test_struct))\n"
	 	<< "\n"
		<< "static struct " << yytarget << " test_struct;\n\n"
		<< "int main(int argc,char **argv) {\n"
		<< "\n"
		<< "\tmemset(&test_struct,0xFF,sizeof test_struct);\n\n";

	s_node& snode = Get(yytarget_struct);
	s_node& node2 = Get(snode.next);	

	assert(node2.type == List);

	for ( auto it=node2.list.begin(); it != node2.list.end(); ++it ) {
		s_node& node = Get(*it);
		std::string member;
		bool struct_member = node.type == Struct;

		if ( node.type == Ident ) {
			member = lex_revsym(node.symbol);
		} else 	{
			s_node& nnode = Get(node.next);
			member = lex_revsym(nnode.symbol);
		}

		c	<< "\tprintf(\"" << member << "|%lu|" << int(struct_member) << "|%u|%u\\n\",\n"
			<< "\t\t(unsigned long)sizeof test_struct." << member << ",\n"
			<< "\t\toffsetof(" << member << "),\n";

		if ( !struct_member )
			c << "\t\ttest_struct." << member << " <= 0 ? 1 : 0);\n";
		else	c << "\t\t0);\n";
	}

	c	<< "\n\treturn 0;\n}\n";
	c.close();

	if ( !gcc_compile(c,genset) )
		exit(4);

	std::string recd;

	while ( getline(c,recd) ) {
		std::cout << "struct: " << yytarget << "." << recd << "\n";
	}

	c.close();
}

void
emit_structs() {

	for ( auto it=config.structs.structvec.begin(); it != config.structs.structvec.end(); ++it ) {
		s_config::s_structs::s_struct& node = *it;
		emit_struct(node);
	}
}

// End structs.cpp
