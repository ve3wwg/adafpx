//////////////////////////////////////////////////////////////////////
// config.cpp -- Load the Config.XML file
// Date: Thu Nov 28 07:52:07 2013
///////////////////////////////////////////////////////////////////////

#include <stdarg.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <assert.h>

#include "pugixml.hpp"

#include "utils.hpp"
#include "config.hpp"

#include <iostream>
#include <unordered_set>

s_config config;

static std::string platform;

static std::unordered_set<int> used_gensets;

static void
load_includes(std::vector<std::string>& vec,pugi::xml_node& inode) {
	std::unordered_set<std::string> inclset;
	bool load_default = true;

	for ( auto iit = inode.begin(); iit != inode.end(); ++iit ) {		
		pugi::xml_node & inclnode = *iit;
		const std::string os = inclnode.attribute("os").value();
		const std::string inclfile = inclnode.attribute("file").value();
			
		if ( inclset.find(inclfile) != inclset.end() )
			continue;		// Already have this one

		if ( match(os,platform) ) {
			vec.push_back(inclfile);
		} else if ( os == "default" && load_default ) {
			vec.push_back(inclfile);
		}
	}
}

void
loadconfig() {
	pugi::xml_document doc;
	pugi::xml_parse_result xml = doc.load_file("config.xml");

	platform = uts_platform();

	if ( !xml ) {
		fprintf(stderr,"Unable to load config.xml: %s\n",xml.description());
		fprintf(stderr,"Error offset: %ld\n",xml.offset);
		exit(1);
	}

	pugi::xml_node bnode = doc.child("entities").child("macro_constants");
	for ( auto sit = bnode.begin(); sit != bnode.end(); ++sit ) {
		pugi::xml_node& snode = *sit;
		const std::string nname = snode.name();

		if ( nname != "set" )
			continue;

		s_config::s_macro_set mset;

		mset.genset = snode.attribute("genset").as_int();
		mset.type = snode.attribute("type").value();
		mset.format = snode.attribute("format").value();
		if ( mset.format.size() <= 0 )
			mset.format = "%ld";

		if ( used_gensets.find(mset.genset) != used_gensets.end() ) {
			std::cerr << "Duplicate: genset: " << mset.genset << "\n";
			exit(3);
		}

		used_gensets.insert(mset.genset);

		{
			pugi::xml_node inode = snode.child("includes");
			load_includes(mset.includes,inode);
		}

		for ( auto mit = snode.begin(); mit != snode.end(); ++mit ) {
			pugi::xml_node mnode = *mit;

			if ( strcmp(mnode.name(),"macro") != 0 )
				continue;

			std::string macro_name = mnode.attribute("name").value();
			mset.macros.push_back(macro_name);

			const std::string alt = mnode.attribute("alt").value();
			if ( alt != "" )
				mset.alternates[macro_name] = alt;
		}

		config.macro_sets.push_back(mset);
	}

	printf("%6ld macro sets loaded.\n",long(config.macro_sets.size()));

	//////////////////////////////////////////////////////////////
	// basic_types
	//////////////////////////////////////////////////////////////
	{
		pugi::xml_node node = doc.child("entities").child("basic_types");

		config.basic_types.genset = node.attribute("genset").as_int();
		assert(config.basic_types.genset > 0);

		for ( auto it=node.begin(); it != node.end(); ++it ) {
			pugi::xml_node& tnode = *it;
			s_config::s_basic_types::s_basic_type btype;
			std::string name = tnode.attribute("name").value();
			
			btype.size = 0;				// Unknown at this time
			btype.ada  = tnode.attribute("ada").value();
			config.basic_types.info[name] = btype;
		}
	}

	//////////////////////////////////////////////////////////////
	// sys_types
	//////////////////////////////////////////////////////////////
	{
		pugi::xml_node snode = doc.child("entities").child("posix_types");

		config.sys_types.genset = snode.attribute("genset").as_int();
		assert(config.sys_types.genset > 0);

		{
			pugi::xml_node inode = snode.child("includes");
			load_includes(config.sys_types.includes,inode);
		}

		for ( auto it=snode.begin(); it != snode.end(); ++it ) {
			const pugi::xml_node& tnode = *it;

			if ( strcmp(tnode.name(),"type") != 0 )
				continue;

			const std::string name = tnode.attribute("name").value();
			const std::string os   = tnode.attribute("os").value();

			if ( os !=  "" && !match(os,platform) )
				continue;

			s_config::s_sys_types::s_sys_type stype;
			stype.size = 0;				// Unknown at this time
			stype.is_unsigned = false;		// Filled in later

			config.sys_types.info[name] = stype;
		}
	}

	//////////////////////////////////////////////////////////////
	// section2
	//////////////////////////////////////////////////////////////
	{
		pugi::xml_node sect2 = doc.child("entities").child("section2");
		config.section2.genset = sect2.attribute("genset").as_int();
		assert(config.section2.genset > 0);

		for ( auto it=sect2.begin(); it != sect2.end(); ++it ) {
			const pugi::xml_node& func = *it;

			if ( strcmp(func.name(),"func") != 0 )
				continue;

			std::string os = func.attribute("os").value();
			if ( os == "" )
				os = "*";

			if ( !match(os,platform) )
				continue;

			s_config::s_section2::s_func funcent;

			funcent.c_name = func.attribute("name").value();
			funcent.alt_name = func.attribute("altname").value();
			funcent.ada_name = func.attribute("ada_name").value();

			if ( funcent.ada_name == "" )
				funcent.ada_name = funcent.c_name;

			funcent.rname = func.attribute("rname").value();
			funcent.finline = func.attribute("inline").as_int();
			funcent.type = func.attribute("type").value();
			funcent.returns = func.attribute("return").value();

			{
				pugi::xml_node inode = func.child("includes");
				load_includes(funcent.includes,inode);
			}

			unsigned acnt = 0;

			for ( auto ait=func.begin(); ait != func.end(); ++ait ) {
				pugi::xml_node anode = *ait;
				std::string nname = anode.name();

				if ( nname == "c_arg" ) {
					s_config::s_section2::s_func::s_carg carg;

					carg.name = anode.attribute("name").value();
					carg.type = anode.attribute("type").value();
					carg.from  = anode.attribute("from").value();
					funcent.cargs.push_back(carg);

				} else if ( nname == "ada_arg" ) {
					s_config::s_section2::s_func::s_aarg aarg;

					aarg.name = anode.attribute("name").value();
					aarg.type = anode.attribute("type").value();
					aarg.io   = anode.attribute("io").value();
					aarg.temp = anode.attribute("temp").value();
					aarg.tempval = anode.attribute("tempval").value();
					aarg.from = anode.attribute("from").value();
					aarg.argno = ++acnt;
					funcent.aargs.push_back(aarg);
				} else if ( nname == "temp" ) {
					s_config::s_section2::s_func::s_temp temp;

					temp.name = anode.attribute("name").value();
					temp.type = anode.attribute("type").value();
					temp.init = anode.attribute("init").value();
					funcent.temps.push_back(temp);
				}
			}
				
			config.section2.funcs.push_back(funcent);
		}
	}
}

// End config.cpp
