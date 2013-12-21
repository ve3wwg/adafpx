//////////////////////////////////////////////////////////////////////
// types.cpp -- Basic C Types
// Date: Sat Nov 30 07:50:36 2013
///////////////////////////////////////////////////////////////////////

#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <assert.h>

#include <iostream>

#include "glue.hpp"
#include "comp.hpp"
#include "config.hpp"

void
comp_types() {
	char sgenset[32];
	std::fstream fs;

	sprintf(sgenset,"%04d",config.basic_types.genset);

	std::cout << "Genset " << sgenset << " basic types\n";
	
	if ( !gcc_open(fs,config.basic_types.genset) )
		exit(3);

	fs <<	"#include <stdio.h>\n"
		"#include <stdlib.h>\n"
		"#include <unistd.h>\n"
		"\n"
		"int main() {\n"
		"\n";

	for ( auto it=config.basic_types.info.begin(); it != config.basic_types.info.end(); ++it ) {
		const std::string& name = it->first;

		fs 	<<	"\tprintf(\"%s|%u\\n\","
			<<	'"' << name << "\",(unsigned)sizeof(" << name << "));\n";
	}

	fs 	<< "\treturn 0;\n"
		<< "}\n";
	fs.close();

	if ( !gcc_compile(fs,config.basic_types.genset) )
		exit(2);

	std::string line;

	while ( fs.good() ) {
		std::getline(fs,line);
		if ( fs.eof() )
			break;

		size_t pos = line.find_first_of('|');
		assert(pos != std::string::npos);
		
		std::string name = line.substr(0,pos);
		std::string value = line.substr(pos+1);
		long tsize = stol(value);

		s_config::s_basic_types::s_basic_type& node = config.basic_types.info[name];
		node.size = tsize;

		auto it = config.basic_types.sizemap.find(node.size);
		if ( it == config.basic_types.sizemap.end() ) {
			if ( name == "long long" )
				config.basic_types.sizemap[node.size] = "llong";
			else	config.basic_types.sizemap[node.size] = name;
		}
	}		

	fs.close();
}

void
comp_systypes() {
	char sgenset[32];
	std::fstream fs;

	sprintf(sgenset,"%04d",config.sys_types.genset);
	std::cout << "Genset " << sgenset << " sys types\n";
	
	if ( !gcc_open(fs,config.sys_types.genset) )
		exit(3);

	fs <<	"#include <stdio.h>\n";

	for ( auto it=config.sys_types.includes.begin(); it != config.sys_types.includes.end(); ++it ) {
		const std::string& incl_file = *it;

		fs << "#include <" << incl_file << ">\n";
	}

	fs <<	"\n"
		"int main() {\n"
		"\n";

	for ( auto it=config.sys_types.info.begin(); it != config.sys_types.info.end(); ++it ) {
		const std::string& name = it->first;

		assert(name.size()>0);

		fs 	<< "\tprintf(\"%s|%u|%d\\n\","
			<< '"' << name << "\",(unsigned)sizeof(" << name << "),"
			<< "((" << name << ")(-1))<0?0:1);\n";
	}

	fs 	<< "\treturn 0;\n"
		<< "}\n";
	fs.close();

	if ( !gcc_compile(fs,config.sys_types.genset) )
		exit(2);

	std::string line;

	while ( fs.good() ) {
		std::getline(fs,line);
		if ( fs.eof() )
			break;

		size_t pos = line.find_first_of('|');
		assert(pos != std::string::npos);
		
		std::string name = line.substr(0,pos);
		
		size_t pos2 = line.find_first_of('|',pos+1);
		std::string value = line.substr(pos+1,pos2-pos-1);
		long tsize = stol(value);
		std::string is_unsigned = line.substr(pos2+1);

		s_config::s_sys_types::s_sys_type& node = config.sys_types.info[name];
		node.size = tsize;
		node.is_unsigned = stoi(is_unsigned);

		auto i = config.basic_types.sizemap.find(node.size);
		if ( i != config.basic_types.sizemap.end() ) {
			const std::string name = i->second;
			if ( !node.is_unsigned )
				node.subtype = name;
			else	{
				node.subtype = "u";
				node.subtype += name;
			}
			node.subtype += "_t";
		}
	}		

	fs.close();
}

// End types.cpp
