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
		s_config::s_basic_types::s_basic_type& node = it->second;

		ads 	<< "   type "
			<< node.ada << " is range -2**" << (node.size*8 - 1)
			<< " .. "
			<< "2**" << (node.size*8 - 1) << "-1;\n";
	}

	ads << "\n";

	for ( auto it=config.basic_types.info.begin(); it != config.basic_types.info.end(); ++it ) {
		s_config::s_basic_types::s_basic_type& node = it->second;
		ads << "   for " << node.ada << "'Size use " << node.size*8 << ";\n";
	}

	ads << "\n";

	for ( auto it=config.basic_types.info.begin(); it != config.basic_types.info.end(); ++it ) {
		s_config::s_basic_types::s_basic_type& node = it->second;

		ads 	<< "   type u"
			<< node.ada << " is mod 2**" << (node.size*8)
			<< ";\n";
	}

	ads << "\n";

	for ( auto it=config.basic_types.info.begin(); it != config.basic_types.info.end(); ++it ) {
		s_config::s_basic_types::s_basic_type& node = it->second;
		ads << "   for u" << node.ada << "'Size use " << node.size*8 << ";\n";
	}

	//////////////////////////////////////////////////////////////
	// Emit the standard int types
	//////////////////////////////////////////////////////////////

	ads << "\n";

	std::unordered_set<unsigned> tset;

	for ( unsigned x=1; x<=8; x *= 2 ) {
		auto it = config.basic_types.sizemap.find(x);
		if ( it == config.basic_types.sizemap.end() ) {
			ads 	<< "   type int" << x*8 << "_t is range "
				<< "-2**" << (x*8-1) << "..2**" << (x*8-1) << "-1;\n";
			tset.insert(x);
		} else	{
			const std::string& subtype = it->second;
			ads	<< "   subtype int" << x*8 << "_t is " << subtype << "_t;\n";
		}
	}

	if ( tset.size() > 0 ) {
		ads << "\n";

		for ( unsigned x=1; x<=8; x *= 2 ) {
			if ( tset.find(x) != tset.end() ) 
				ads	<< "   for int" << x*8 << "_t'Size use " << x*8 << ";\n";
		}
	}

	ads << "\n";
	tset.clear();

	for ( unsigned x=1; x<=8; x *= 2 ) {
		auto it = config.basic_types.sizemap.find(x);
		if ( it == config.basic_types.sizemap.end() ) {
			ads 	<< "   type uint" << x*8 << "_t is mod 2**" << x*8 << ";\n";
			tset.insert(x);
		} else	{
			const std::string& subtype = it->second;
			ads	<< "   subtype uint" << x*8 << "_t is u" << subtype << "_t;\n";
		}
	}

	if ( tset.size() > 0 ) {
		ads << "\n";

		for ( unsigned x=1; x<=8; x *= 2 ) {
			if ( tset.find(x) != tset.end() ) 
				ads	<< "   for uint" << x*8 << "_t'Size use " << x*8 << ";\n";
		}
	}

	ads << "\n";

        ads << "   type uchar_array is array(uint_t range <>) of uchar_t;\n";

	ads << "\n";

	//////////////////////////////////////////////////////////////
	// Array types
	//////////////////////////////////////////////////////////////

	for ( size_t x=1; x<=8; x *= 2 ) {
		ads << "   type int" << x*8 << "_array is array(uint_t range <>) of int" << x*8 << "_t;\n";
		ads << "   type uint" << x*8 << "_array is array(uint_t range <>) of uint" << x*8 << "_t;\n";
	}
}

// End btypes.cpp
