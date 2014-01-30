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
#include <sstream>
#include <unordered_map>

#include "config.hpp"
#include "comp.hpp"
#include "glue.hpp"

static std::unordered_map<std::string,std::string> c_ada_map;

bool
use_preferred_type(unsigned size,bool is_unsigned,const std::string pref_type) {
	{
		auto pit = config.sys_types.info.find(pref_type);
		if ( pit != config.sys_types.info.end() ) {
			const s_config::s_sys_types::s_sys_type& stype = pit->second;
			if ( size == stype.size /* && is_unsigned == stype.is_unsigned */ )
				return true;
		}
	}

	// Try for a basic type
	{
		auto pit = config.basic_types.a2cmap.find(pref_type);
		if ( pit == config.basic_types.a2cmap.end() )
			return false;
		const std::string& c_name = pit->second;
		const s_config::s_basic_types::s_basic_type& btype = config.basic_types.info[c_name];
		return btype.size == size;
	}
}

const std::string
std_type(unsigned bytes,bool is_signed,unsigned array) {
	std::stringstream s;

	if ( !is_signed )
		s << "u";
	if ( bytes <= 1 ) {
		s << "char";
	} else	{
		bytes /= (array < 1 ? 1 : array);
		if ( bytes <= 1 ) {
			s << "char";
		} else	{
			s << "int" << bytes * 8;
		}
	}

	if ( array < 1 ) {
		s << "_t";
	} else	{
		s << "_array(0.." << array-1 << ")";
	}

	return s.str();
}

static void
emit_struct(s_config::s_structs::s_struct& node) {
	std::fstream c, ads;
	int genset = node.genset;
	bool as_typedef = false;

	std::cout << "Genset ";
	std::cout.width(4);
	std::cout.fill('0');
	std::cout << genset << " struct " << node.c_name << "\n";

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

	if ( yacc_dump )
		std::cerr << "GOT STRUCT '" << yytarget << "' ID := " << yytarget_struct << "\n";

	if ( yytarget_struct <= 0 ) {
		auto it = typedefs.find(yytarget);
		if ( it == typedefs.end() ) {
			std::cerr << "struct " << yytarget << " is unknown? (Genset " << genset << ")\n";
			exit(3);
		}
		int nodeno = it->second;
		s_node& node = Get(nodeno);
		yytarget_struct = node.next;
		s_node& snode = Get(node.next);
		if ( snode.type != Struct ) {
			std::cerr << "struct " << yytarget << " is unknown? (Genset " << genset << ")\n";
			exit(3);
		}
		as_typedef = true;		// Do not name this as struct <whatever>
		if ( yacc_dump ) {
			std::cerr << "Found defn of " << yytarget << " as node " << nodeno << "\n";
			dump(nodeno,yytarget.c_str());
		}
	}

	if ( !gcc_open(c,++genset) )
		exit(2);

	c << "#include <stdio.h>\n"
	  << "#include <stdlib.h>\n"
	  << "#include <string.h>\n";

	std::unordered_map<std::string,std::string> typemap;

	for ( auto it=node.includes.begin(); it != node.includes.end(); ++it ) {
		const std::string& incl = *it;
		if ( incl[0] != '.' )
			c << "#include <" << incl << ">\n";
		else	c << "#include \"" << incl << "\"\n";
	}

	c	<< "\n"
		<< "#define offsetof(member) (unsigned) (((char*)&test_struct.member) - ((char*)&test_struct))\n"
	 	<< "\n";

	if ( !as_typedef )
		c << "static struct " << yytarget << " test_struct;\n\n";
	else	c << "static " << yytarget << " test_struct;\n\n";

	c	<< "int main(int argc,char **argv) {\n"
		<< "\n"
		<< "\tmemset(&test_struct,0xFF,sizeof test_struct);\n\n";

	s_node& snode = Get(yytarget_struct);
	s_node& node2 = Get(snode.next);	

	assert(node2.type == List);

	c	<< "\tprintf(\"%u\\n\",(unsigned)(sizeof(test_struct))"
		<< ");\n";

	for ( auto it=node2.list.begin(); it != node2.list.end(); ++it ) {
		s_node& znode = Get(*it);
		std::string member;
		unsigned ptr = 0;
		bool struct_member = znode.type == Struct;
		bool array_ref = false;

		switch ( znode.type ) {
		case Ident :
			member = lex_revsym(znode.symbol);
			ptr = znode.ptr;
			break;
		case ArrayRef :
			{
				s_node& anode = Get(znode.next);
				assert(anode.type == Ident);
				member = lex_revsym(anode.symbol);
			}
			array_ref = true;
			break;
		case Struct :
			{
				s_node& nnode = Get(znode.next);
				assert(nnode.type == Ident);
				member = lex_revsym(nnode.symbol);

				auto it = node.override_type.find(member);
				if ( it != node.override_type.end() ) {
					typemap[member] = it->second;
				} else	{
					typemap[member] = lex_revsym(znode.symbol);
					ptr = znode.ptr;
				}
			}
			break;
		case Union :
			{
				s_node& nnode = Get(znode.next);
				assert(nnode.type == Ident);
				member = lex_revsym(nnode.symbol);

				auto it = node.override_type.find(member);
				if ( it != node.override_type.end() ) {
					typemap[member] = it->second;
				} else	{
					assert(0);
				}
			}
			break;
		case Type :
			// (lldb) p nnode
			// (s_node) $0 = {
			// 	type = ArrayRef
			// 	symbol = 0
			// 	ltoken = 0
			// 	ptr = 0
			// 	list = size=0 {}
			// 	next = 652
			// 	next2 = 653
			// 	next3 = 0
			// }
			{
				s_node& nnode = Get(znode.next);
				switch ( nnode.type ) {
				case Ident :
					{
						member = lex_revsym(nnode.symbol);

						auto it = node.override_type.find(member);
						if ( it != node.override_type.end() ) {
							typemap[member] = it->second;
						} else	{
							ptr = znode.ptr;
						}
					}
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
		case AnonMember :	// Anonymous member with bitfield specification
			continue;	// Skip this one
		default :
			assert(0);
		}

		if ( node.is_struct.find(member) != node.is_struct.end() ) {
			struct_member = node.is_struct[member];
		}                

		if ( !array_ref ) {
			c	<< "\tprintf(\"" << member << "|%lu|" << int(struct_member) << "|%u|%u|0|"
				<< ptr
				<< "|S\\n\",\n"
				<< "\t\t(unsigned long)sizeof test_struct." << member << ",\n"
				<< "\t\toffsetof(" << member << "),\n";
			if ( !struct_member )
				c << "\t\ttest_struct." << member << " <= 0 ? 1 : 0);\n";
			else	c << "\t\t0);\n";
		} else	{
			c	<< "\tprintf(\"" << member << "|%lu|" << int(struct_member) << "|%u|%u|%u|0|A\\n\",\n"
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
		char *ep = 0;
		node.size = strtoul(recd.c_str(),&ep,10);

		while ( getline(c,recd) ) {
			std::vector<std::string> fields;
			parse(fields,recd);
			s_config::s_structs::s_member mem;
			bool is_array = false;
			char *ep = 0;

			mem.name = fields[0];
			mem.a_name = to_ada_name(mem.name);
			mem.msize = strtoul(fields[1].c_str(),&ep,10);
			mem.union_struct = atoi(fields[2].c_str());
			mem.moffset = strtoul(fields[3].c_str(),&ep,10);
			mem.msigned = bool(atoi(fields[4].c_str()));
			mem.array = atoi(fields[5].c_str());
			mem.ptr = atoi(fields[6].c_str());
			is_array = fields[7] == "A";

			auto it = typemap.find(mem.name);
			if ( it != typemap.end() )
				mem.tname = it->second;	// Named type/struct/union
			else	mem.tname = "";

			if ( !is_array || (is_array && mem.array > 0 ) )
				node.members.push_back(mem);
		}
	}

	c.close();

	//////////////////////////////////////////////////////////////
	// Generate Ada Structure
	//////////////////////////////////////////////////////////////

	if ( !gcc_open(ads,genset,".ads") )
		exit(5);

	ads 	<< "\n"
		<< "   type " << node.a_name << " is\n"
		<< "      record\n";

	for ( auto it=node.members.begin(); it != node.members.end(); ++it ) {
		s_config::s_structs::s_member& member = *it;
		std::stringstream s;

		if ( node.is_struct.find(member.name) != node.is_struct.end() ) {
			member.union_struct = node.is_struct[member.name];
			if ( member.tname == "" ) {
				member.tname = node.prefs[member.name];
			}
		}

		auto im = node.nprefs.find(member.name);
		if ( im != node.nprefs.end() ) {
			const std::string pref_name = im->second;
			member.a_name = pref_name;			// Use config.xml name instead
		}

		s << member.a_name << " :";
		std::string fmt_name = s.str();
		
                ads << "         ";
       		ads.width(32);
		ads << std::left << fmt_name << " ";
	
		if ( !member.union_struct ) {
			std::string ada_type;
			bool subbed = false, prefs = false;

			auto mit = node.prefs.find(member.name);
			if ( mit != node.prefs.end() ) {
				const std::string& pref_type = mit->second;
				prefs = true;

				if ( use_preferred_type(member.msize,!member.msigned,pref_type) ) {
					ada_type = pref_type;
					subbed = true;
				}
			}
			if ( !member.ptr ) {
				if ( ada_type == "" )
					ada_type = std_type(member.msize,member.msigned,member.array);
			} else	{
				auto it = node.override_type.find(member.name);
				if ( it != node.override_type.end() ) {
					ada_type = it->second;	// eg. sigproc_t
				} else	{
					ada_type = "System.Address";
				}
			}

			// Process when=
			if ( prefs && !subbed ) {
				const std::string when = node.xlate[member.name];
				if ( when != "" && ada_type == when )
					ada_type = node.prefs[member.name];
			}

			ads << ada_type;
		} else	{
			auto cit = c_ada_map.find(member.tname); // Lookup C name
			if ( cit != c_ada_map.end() ) 
				ads << cit->second;		// Known Ada name
			else if ( member.union_struct == 2 )
				ads << member.tname;		// Cheat from config.xml
			else 	ads << "s_" << member.tname;	// Unknown
		}
		ads << ";\n";
	}

	ads	<< "      end record;\n\n"
		<< "   for " << node.a_name << "'Size use " << node.size << "*8;\n\n"
		<< "   for " << node.a_name << " use\n"
		<< "      record\n";

	for ( auto it=node.members.begin(); it != node.members.end(); ++it ) {
		const s_config::s_structs::s_member& member = *it;
		std::stringstream s;

		s << member.a_name;
		std::string fmt_name = s.str();
		
                ads << "         ";
       		ads.width(32);
		ads << std::left << fmt_name << " at " << member.moffset << " range 0.." << member.msize*8-1 << ";\n";
	}

        ads     << "      end record;\n";


	if ( node.array != "" ) {
		ads 	<< "\n"
			<< "   type " << node.a_name << "_array" << " is array(" << node.array
			<< ") of " << node.a_name << ";\n";
	}

	ads.close();
}

void
emit_structs() {

	for ( auto it=config.structs.structvec.begin(); it != config.structs.structvec.end(); ++it ) {
		s_config::s_structs::s_struct& node = *it;
		c_ada_map[node.c_name] = node.a_name;
	}

	for ( auto it=config.structs.structvec.begin(); it != config.structs.structvec.end(); ++it ) {
		s_config::s_structs::s_struct& node = *it;
		emit_struct(node);
	}
}

// End structs.cpp
