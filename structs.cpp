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

	if ( !gcc_open(c,node.genset) )
		exit(2);

	for ( auto it=node.includes.begin(); it != node.includes.end(); ++it ) {
		const std::string& incl = *it;
		c << "#include<" << incl << ">\n";
	}

	c.close();

	if ( !gcc_precomplex(node.genset) )
		exit(2);

	yyparse();
}

void
emit_structs() {

	for ( auto it=config.structs.structvec.begin(); it != config.structs.structvec.end(); ++it ) {
		s_config::s_structs::s_struct& node = *it;
		emit_struct(node);
	}
}

// End structs.cpp
