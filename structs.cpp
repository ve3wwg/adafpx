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

	std::cerr << "GOT STRUCT '" << yytarget << "' ID := " << yytarget_struct << "\n";

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

	c	<< "\tprintf(\"%u\\n\",(unsigned)(sizeof(struct " << yytarget << "))"
		<< ");\n";

	for ( auto it=node2.list.begin(); it != node2.list.end(); ++it ) {
		s_node& node = Get(*it);
		std::string member;
		bool struct_member = node.type == Struct;
		bool array_ref = false;

		switch ( node.type ) {
		case Ident :
			member = lex_revsym(node.symbol);
			break;
		case ArrayRef :
			{
				s_node& anode = Get(node.next);
				assert(anode.type == Ident);
				member = lex_revsym(anode.symbol);
			}
			array_ref = true;
			break;
		case Struct :
			{
				s_node& nnode = Get(node.next);
				assert(nnode.type == Ident);
				member = lex_revsym(nnode.symbol);
			}
			break;
		case Type :
//		(lldb) p nnode
//		(s_node) $0 = {
//			type = ArrayRef
//			symbol = 0
//			ltoken = 0
//			ptr = 0
//			list = size=0 {}
//			next = 652
//			next2 = 653
//			next3 = 0
//		}
			{
				s_node& nnode = Get(node.next);
				switch ( nnode.type ) {
				case Ident :
					member = lex_revsym(nnode.symbol);
					break;
				case ArrayRef :
					{
					//	(s_node) a1 = {
					//	  type = Ident
					//	  symbol = 1463
					//	  ltoken = 0
					//	  ptr = 0
					//	  list = size=0 {}
					//	  next = 0
					//	  next2 = 0
					//	  next3 = 0
					//	}
						s_node& a1 = Get(nnode.next);
						
						assert(a1.type == Ident);
						member = lex_revsym(a1.symbol);
					}
					array_ref = true;
					break;
				default :
					assert(0);
				}
			}
			break;
		default :
			assert(0);
		}

		if ( !array_ref ) {
			c	<< "\tprintf(\"" << member << "|%lu|" << int(struct_member) << "|%u|%u|0\\n\",\n"
				<< "\t\t(unsigned long)sizeof test_struct." << member << ",\n"
				<< "\t\toffsetof(" << member << "),\n";
	
			if ( !struct_member )
				c << "\t\ttest_struct." << member << " <= 0 ? 1 : 0);\n";
			else	c << "\t\t0);\n";
		} else	{
			c	<< "\tprintf(\"" << member << "|%lu|" << int(struct_member) << "|%u|%u|%u\\n\",\n"
				<< "\t\t(unsigned long)sizeof test_struct." << member << ",\n"
				<< "\t\toffsetof(" << member << "),\n";
	
			if ( !struct_member )
				c << "\t\ttest_struct." << member << " <= 0 ? 1 : 0,\n";
			else	c << "\t\t0,\n";

			c 	<< "\t\t(unsigned)((sizeof test_struct." << member << ") / "
				<< "sizeof test_struct." << member << "[0]));\n";
		}
	}

	c	<< "\n\treturn 0;\n}\n";
	c.close();

	if ( !gcc_compile(c,genset) )
		exit(4);

	std::string recd;

	if ( getline(c,recd) ) {
		node.size = stoul(recd);

		while ( getline(c,recd) ) {
			std::vector<std::string> fields;
			parse(fields,recd);
			s_config::s_structs::s_member mem;

			mem.name = fields[0];
			mem.msize = stoul(fields[1]);
			mem.union_struct = stoi(fields[2]);
			mem.moffset = stoul(fields[3]);
			mem.msigned = bool(stoi(fields[4]));
			node.members.push_back(mem);
		}
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
