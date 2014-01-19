//////////////////////////////////////////////////////////////////////
// config.cpp -- Load the Config.XML file
// Date: Thu Nov 28 07:52:07 2013
///////////////////////////////////////////////////////////////////////

#include <stdio.h>
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
#include <fstream>
#include <unordered_set>

s_config config;
std::fstream gnatprep;

static std::string platform;

static std::unordered_set<int> used_gensets;

//////////////////////////////////////////////////////////////////////
// Contribute gnatprep lines
//////////////////////////////////////////////////////////////////////

static void
gnatprep_defines(pugi::xml_node& gnode) {

	if ( !gnatprep.is_open() )
		return;

	for ( auto it=gnode.begin(); it != gnode.end(); ++it ) {
		pugi::xml_node& define = *it;

		if ( strcmp(define.name(),"define") != 0 )
			continue;

		const std::string& symbol = define.attribute("symbol").value();
		std::string value = define.attribute("value").value();
		bool is_string = false;

		if ( value == "" ) {
			const char *cp = define.attribute("string").value();
			is_string = cp != 0;
			if ( is_string )
				value = cp;
		}

		if ( symbol == "" )
			continue;

		// Check if there is a known substitution defined
		if ( value != "" && value[0] == '%' ) {
			auto sit = config.gnatprep.find(value);
			if ( sit != config.gnatprep.end() )
				value = sit->second;	// Substitute the defined value
		}

		if ( !is_string )
			gnatprep << symbol << " := " << value << "\n";
		else	gnatprep << symbol << " := \"" << value << "\"\n";
	}
}

static void
load_includes(std::vector<std::string>& vec,pugi::xml_node& inode) {
	std::unordered_set<std::string> inclset;
	bool load_default = true;

	for ( auto iit = inode.begin(); iit != inode.end(); ++iit ) {		
		pugi::xml_node & inclnode = *iit;
		std::string os = inclnode.attribute("os").value();
		const std::string inclfile = inclnode.attribute("file").value();
			
		if ( os == "" )
			os = "*";

		if ( inclset.find(inclfile) != inclset.end() )
			continue;		// Already have this one

		if ( match(os,platform) ) {
			vec.push_back(inclfile);
		} else if ( os == "default" && load_default ) {
			vec.push_back(inclfile);
		}
	}
}

static void
load_use_clauses(std::vector<std::string>& vec,pugi::xml_node& inode) {
	std::unordered_set<std::string> useset;
	bool load_default = true;

	for ( auto iit = inode.begin(); iit != inode.end(); ++iit ) {		
		pugi::xml_node & usenode = *iit;
		std::string os = usenode.attribute("os").value();
		const std::string use_clause = usenode.attribute("name").value();
			
		if ( os == "" )
			os = "*";

		if ( useset.find(use_clause) != useset.end() )
			continue;		// Already have this one

		if ( match(os,platform) ) {
			vec.push_back(use_clause);
		} else if ( os == "default" && load_default ) {
			vec.push_back(use_clause);
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

	{
		pugi::xml_node bnode = doc.child("entities").child("copies");
		for ( auto it=bnode.begin(); it != bnode.end(); ++it ) {
			pugi::xml_node& builtin = *it;
			if ( strcmp(builtin.name(),"copy") != 0 )
				continue;
			const std::string filename = builtin.attribute("name").value();
			std::string os   = builtin.attribute("os").value();
			if ( os == "" )
				os = "*";
			if ( match(os,platform) )
				config.copies.insert(filename);
		}
	}

	{
		pugi::xml_node gnode = doc.child("entities").child("gnatprep");
		const std::string filename = gnode.attribute("file").value();

		if ( filename != "" ) {
			gnatprep.open(filename.c_str(),std::fstream::out);
			if ( gnatprep.fail() ) {
				std::cerr << strerror(errno) << ": opening " << filename << " for write.\n";
				exit(3);
			}
		}

		gnatprep_defines(gnode);
	}

	{
		pugi::xml_node bnode = doc.child("entities").child("builtin_types");
		for ( auto it=bnode.begin(); it != bnode.end(); ++it ) {
			pugi::xml_node& builtin = *it;
			if ( strcmp(builtin.name(),"builtin") != 0 )
				continue;
			const std::string type = builtin.attribute("type").value();
			std::string os   = builtin.attribute("os").value();
			if ( os == "" )
				os = "*";
			if ( match(os,platform) )
				config.builtins.insert(type);
		}
	}

	pugi::xml_node bnode = doc.child("entities").child("macro_constants");
	for ( auto sit = bnode.begin(); sit != bnode.end(); ++sit ) {
		pugi::xml_node& snode = *sit;
		const std::string nname = snode.name();

		if ( nname != "set" )
			continue;

		const std::string os = snode.attribute("os").value();

		if ( os != "" && !match(os,platform) )
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

			const std::string macro_name = mnode.attribute("name").value();
			const std::string ada_name = mnode.attribute("ada_name").value();
			mset.macros.push_back(macro_name);

			if ( ada_name != "" )
				mset.ada_name[macro_name] = ada_name;

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

	// Build Ada to C name lookup map
	for ( auto it=config.basic_types.info.begin(); it != config.basic_types.info.end(); ++it ) {
		const std::string& c_name = it->first;
		const s_config::s_basic_types::s_basic_type& btype = it->second;
		config.basic_types.a2cmap[btype.ada] = c_name;
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
			std::string os   = tnode.attribute("os").value();

			if ( os == "" )
				os = "*";

			if ( !match(os,platform) )
				continue;

			s_config::s_sys_types::s_sys_type stype;
			stype.size = 0;				// Unknown at this time
			stype.is_unsigned = false;		// Filled in later

			config.sys_types.info[name] = stype;
		}
	}

	//////////////////////////////////////////////////////////////
	// Ada Types
	//////////////////////////////////////////////////////////////
	{
		pugi::xml_node anode = doc.child("entities").child("ada_types");

		config.ada_types.genset = anode.attribute("genset").as_int();
		assert(config.ada_types.genset > 0);

		for ( auto it=anode.begin(); it != anode.end(); ++it ) {
			const pugi::xml_node& tnode = *it;

			if ( strcmp(tnode.name(),"type") != 0 )
				continue;

			const std::string os = tnode.attribute("os").value();

			if ( os !=  "" && !match(os,platform) )
				continue;

			s_config::s_ada_types::s_ada_type decl;
			decl.name    = tnode.attribute("name").value();
			decl.subtype = tnode.attribute("subtype").value();
			decl.type    = tnode.attribute("type").value();
			decl.range   = tnode.attribute("range").value();

			config.ada_types.adavec.push_back(decl);
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

			int testno = func.attribute("test").as_int();

			if ( testno > 0 )
				config.tests.insert(testno);

			s_config::s_section2::s_func funcent;

			funcent.c_name = func.attribute("name").value();
			funcent.alt_name = func.attribute("altname").value();
			funcent.ada_name = func.attribute("ada_name").value();
			funcent.type     = func.attribute("ada_type").value();
			if ( funcent.type == "" )
				funcent.type = "procedure";

			if ( funcent.ada_name == "" )
				funcent.ada_name = funcent.c_name;

			funcent.rname = func.attribute("rname").value();
			funcent.finline = func.attribute("inline").as_int();
			funcent.returns = func.attribute("return").value();
			funcent.type = func.attribute("ada_type").value();
			funcent.ada_return = func.attribute("ada_return").value();
			funcent.ada_rfrom  = func.attribute("ada_return_from").value();
			funcent.bind_prefix = func.attribute("prefix").value();
			funcent.macro = func.attribute("macro").value();
			{
				pugi::xml_node inode = func.child("includes");
				load_includes(funcent.includes,inode);
			}

			{
				pugi::xml_node unode = func.child("use_clauses");
				load_use_clauses(funcent.use_clauses,unode);
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
				} else if ( nname == "declare" ) {
					funcent.decls.push_back(anode.attribute("text").value());
				}
			}
				
			//////////////////////////////////////////////
			// Load optional pre-checks
			//////////////////////////////////////////////
			{
				pugi::xml_node prechecks = func.child("prechecks");

				if ( !strcmp(prechecks.name(),"prechecks") ) {
					funcent.on_error = prechecks.attribute("on_error").value();
					for ( auto pit=prechecks.begin(); pit != prechecks.end(); ++pit ) {
						const pugi::xml_node& pnode = *pit;
						if ( !strcmp(pnode.name(),"precheck") ) {
							const std::string& cond = pnode.attribute("cond").value();
							funcent.prechecks.push_back(cond);
						}
					}
				}
			}

			//////////////////////////////////////////////
			// Load up optional case values
			//////////////////////////////////////////////

			pugi::xml_node cases = func.child("cases");
			const std::string cases_name = cases.attribute("name").value();
			const std::string on_error = cases.attribute("on_error").value();

			if ( cases_name != "" ) {
				s_config::s_section2::s_func::s_cases& centry = funcent.cases[cases_name];
			
				centry.on_error = on_error;
				for ( auto cit=cases.begin(); cit != cases.end(); ++cit ) {
					const pugi::xml_node& cnode = *cit;
					if ( !strcmp(cnode.name(),"case") ) {
						const std::string& the_case = cnode.attribute("name").value();
						centry.casevec.push_back(the_case);
					}
				}
			}

			config.section2.funcs.push_back(funcent);
		}
	}

	//////////////////////////////////////////////////////////////
	// structure types
	//////////////////////////////////////////////////////////////
	{
		pugi::xml_node node = doc.child("entities").child("structs");

		for ( auto it=node.begin(); it != node.end(); ++it ) {
			pugi::xml_node& snode = *it;

			if ( strcmp(snode.name(),"struct") != 0 )
				continue;

			const std::string os = snode.attribute("os").value();
			if ( os != "" && !match(os,platform) )
				continue;		// Not this platform

			s_config::s_structs::s_struct stype;

			stype.genset = snode.attribute("genset").as_int();
			assert(stype.genset > 0);
			
			stype.c_name = snode.attribute("name").value();
			stype.a_name = snode.attribute("ada").value();
			stype.array  = snode.attribute("array").value();

			{
				pugi::xml_node inode = snode.child("includes");
				load_includes(stype.includes,inode);
			}

			{
				pugi::xml_node pnode = snode.child("members");
				// <member name="l_pid" pref="pid_t"/>

				for ( auto pit=pnode.begin(); pit != pnode.end(); ++pit ) {
					pugi::xml_node& mnode = *pit;
					const std::string ntype = mnode.name();
		
					if ( ntype == "member" ) {
						const std::string& member = mnode.attribute("name").value();
						const std::string& pref   = mnode.attribute("pref").value();
						const std::string& stru   = mnode.attribute("struct").value();

						if ( stru != "" )
							stype.is_struct[member] = atoi(stru.c_str());
						stype.prefs[member] = pref;
					} else if ( ntype == "struct" ) {
						const std::string& member = mnode.attribute("name").value();
						const std::string& mem_os = mnode.attribute("os").value();

						if ( mem_os == "" || match(mem_os,platform) )
							stype.is_struct[member] = 1;
					} else if ( ntype == "override" ) {
						const std::string& member = mnode.attribute("name").value();
						const std::string& ada_name = mnode.attribute("ada").value();
						const std::string& mem_os = mnode.attribute("os").value();

						if ( mem_os == "" || match(mem_os,platform) ) {
							const std::string type = mnode.attribute("type").value();
							stype.override_type[member] = type;
	
							const std::string& stru   = mnode.attribute("struct").value();
							if ( stru != "" )
								stype.is_struct[member] = atoi(stru.c_str());
							if ( ada_name != "" )
								stype.nprefs[member] = ada_name;
						}
					}
				}
			}

			config.structs.structvec.push_back(stype);
		}
	}
}

// End config.cpp
