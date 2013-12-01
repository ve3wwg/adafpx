//////////////////////////////////////////////////////////////////////
// macros.cpp -- Process Macro Values
// Date: Fri Nov 29 21:40:13 2013
///////////////////////////////////////////////////////////////////////

#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <assert.h>

#include <iostream>

#include "utils.hpp"
#include "comp.hpp"
#include "config.hpp"

static void
comp_macro_set(s_config::s_macro_set& mset) {
	char sgenset[32];
	std::fstream fs;

	sprintf(sgenset,"%04d",mset.genset);

	std::cout << "Genset " << sgenset << " macro set\n";

	if ( !gcc_open(fs,mset.genset) )
		exit(3);

	fs 	<< "#include <stdio.h>\n\n";

	for ( auto it=mset.includes.begin(); it != mset.includes.end(); ++it ) {
		const std::string& incl_file = *it;

		fs << "#include <" << incl_file << ">\n";
	}
	
	fs	<< "\nstatic struct {\n"
		<< "\tconst char\t*name;\n"
		<< "\tlong\t\tvalue;\n"
		<< "} macros[] = {\n";

	for ( auto it=mset.macros.begin(); it != mset.macros.end(); ++it ) {
		const std::string& name = *it;

		fs	<< "#ifdef " << name << "\n"
			<< "\t{ \"" << name << "\", " << name << " },\n";
		
		auto ait = mset.alternates.find(name);
		if ( ait != mset.alternates.end() ) {
			const std::string& alt = mset.alternates[name];

			fs	<< "#else\n"
				<< "#ifdef " << alt << "\n"
				<< "\t{ \"" << name << "\", " << alt << " },\n"
				<< "#endif\n";
		}		
		fs	<< "#endif\n";
	}

	fs	<< "\t{ 0, 0 }\n"
		<< "};\n"
		<< "\nint main() {\n"
		<< "\tint x;\n\n"
		<< "\tfor ( x=0; macros[x].name != 0; ++x )\n"
		<< "\t\tprintf(\"%s|%ld\\n\",macros[x].name,macros[x].value);\n"
		<< "\treturn 0;\n"
		<< "}\n";
	fs.close();

	if ( !gcc_compile(fs,mset.genset) )
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
		long mvalue = stol(value);

		mset.values[name] = mvalue;
	}		

	fs.close();
}

void
comp_macros() {

	for ( auto it=config.macro_sets.begin(); it != config.macro_sets.end(); ++it ) {
		s_config::s_macro_set& mset = *it;
		comp_macro_set(mset);
	}
}

// End macros.cpp
