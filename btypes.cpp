//////////////////////////////////////////////////////////////////////
// btypes.cpp -- Emit Basic Types
// Date: Tue Dec  3 18:52:38 2013
///////////////////////////////////////////////////////////////////////

#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <assert.h>

#include <iostream>
#include <sstream>

#include "glue.hpp"
#include "comp.hpp"
#include "config.hpp"

void
emit_basic_types() {
	char sgenset[32];
	std::fstream ads, adb;

	sprintf(sgenset,"%04d",config.basic_types.genset);

	std::cout << "Genset " << sgenset << " emit basic types\n";
	
	if ( !gcc_open(ads,config.basic_types.genset,".ads") )
		exit(3);

	ads << "\n";

	for ( auto it=config.basic_types.info.begin(); it != config.basic_types.info.end(); ++it ) {
		const std::string& name = it->first;
		s_config::s_basic_types::s_basic_type& node = it->second;

		if ( name != "char" ) {
			ads 	<< "    type "
				<< node.ada << " is range -2**" << (node.size*8 - 1)
				<< " .. "
				<< "2**" << (node.size*8 - 1) << "-1;\n";
		} else	{
			ads 	<< "    type "
				<< node.ada << " is range 0"
				<< " .. "
				<< "2**" << (node.size*8) << "-1;\n";
		}
	}

	for ( auto it=config.basic_types.info.begin(); it != config.basic_types.info.end(); ++it ) {
		const std::string& name = it->first;
		s_config::s_basic_types::s_basic_type& node = it->second;

		if ( name != "char" ) {
			ads 	<< "    type u"
				<< node.ada << " is mod 2**" << (node.size*8)
				<< ";\n";
		}
	}
}

// End btypes.cpp
