//////////////////////////////////////////////////////////////////////
// systypes.cpp -- Emit System Types (excluding structures)
// Date: Tue Dec  3 19:15:39 2013
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
emit_sys_types() {
	char sgenset[32];
	std::fstream ads, adb;

	sprintf(sgenset,"%04d",config.sys_types.genset);

	std::cout << "Genset " << sgenset << " emit sys types\n";
	
	if ( !gcc_open(ads,config.sys_types.genset,".ads") )
		exit(3);

	ads << "\n";

	for ( auto it=config.sys_types.info.begin(); it != config.sys_types.info.end(); ++it ) {
		const std::string& name = it->first;
		s_config::s_sys_types::s_sys_type& node = it->second;

		if ( node.is_unsigned ) {
			ads 	<< "    type "
				<< name << " is mod 2**" << node.size*8 << ";\n";
		} else	{
			ads 	<< "    type "
				<< name << " is range -2**" << (node.size*8-1) << " .. "
				<< "2**" << (node.size*8-1) << "-1;\n";
		}
	}
}

// End systypes.cpp