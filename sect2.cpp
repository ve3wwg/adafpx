//////////////////////////////////////////////////////////////////////
// sect2.cpp -- Emit the Section2 Procedures
// Date: Sat Nov 30 13:50:35 2013
///////////////////////////////////////////////////////////////////////

#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <assert.h>

#include <iostream>
#include <sstream>
#include <unordered_set>

#include "glue.hpp"
#include "comp.hpp"
#include "config.hpp"

void
emit_section2() {
	char sgenset[32];
	std::fstream ads, adb, cc;
	std::unordered_set<std::string> inclset;

	sprintf(sgenset,"%04d",config.section2.genset);

	std::cout << "Genset " << sgenset << " emit section2\n";
	
	if ( !gcc_open(ads,config.section2.genset,".ads") )
		exit(3);

	if ( !gcc_open(adb,config.section2.genset,".adb") )
		exit(3);

	ads << "\n";

	for ( auto it=config.section2.funcs.begin(); it != config.section2.funcs.end(); ++it ) {
		s_config::s_section2::s_func& func = *it;
		std::stringstream proto;
		std::string binding_name = "UX_";
		std::vector<std::string> macros_used;
		bool skip = false;

		if ( func.cases.size() > 0 ) {
			skip = true;		// For now

			for ( auto cit=func.cases.cbegin(); cit != func.cases.cend(); ++cit ) {
				const std::string varname = cit->first;
				const s_config::s_section2::s_func::s_cases& centry = cit->second;

				if ( centry.casevec.size() > 0 ) {
					for ( auto vit=centry.casevec.cbegin(); vit != centry.casevec.cend(); ++vit ) {
						const std::string& the_case = *vit;

						auto mit = config.declared_macros.find(the_case);
						if ( mit != config.declared_macros.end() ) {
							skip = false;
							macros_used.push_back(the_case);
						}
					}
				}
			}
		}

		if ( skip )
			continue;			// No cases are define macro names

		binding_name += func.c_name;		// Default internal c binding name

		if ( func.alt_name != "" )
			binding_name = func.alt_name;

		proto << func.type << " " << func.ada_name;

		if ( func.aargs.size() > 0 ) {
			proto << "(";

			bool f=true;

			for ( auto ait=func.aargs.begin(); ait != func.aargs.end(); ++ait ) {
				s_config::s_section2::s_func::s_aarg& arg = *ait;

				if ( !f ) {
					proto << "; ";
				} else	{
					f = false;
				}
				proto << arg.name << ": ";
				if ( arg.io != "in" )
					proto << arg.io << " ";
				proto << arg.type;
			}
			proto << ")";
			if ( func.type == "function" )
				proto << " return " << func.ada_return;
		}

		//////////////////////////////////////////////////////
		// Generate the prototype in the Spec
		//////////////////////////////////////////////////////

		for ( auto mit = macros_used.begin(); mit != macros_used.end(); ++mit ) {
			const std::string macro_name = *mit;
			ads << "   -- " << macro_name << "\n";
		}

		ads << "   " << proto.str() << ";\n";
		if ( func.finline )
			ads << "   pragma Inline(" << func.ada_name << ");\n\n";

		//////////////////////////////////////////////////////
		// The body
		//////////////////////////////////////////////////////

		adb 	<< "   " << proto.str() << " is\n";

		// Use clauses
		for ( auto uit=func.use_clauses.begin(); uit != func.use_clauses.end(); ++uit ) {
			const std::string& use_clause = *uit;
			adb << "      use " << use_clause << ";\n";
		}

		// C Function Declaration
		if ( func.returns != "" )
			adb << "      function " << binding_name;
		else	adb << "      procedure " << binding_name;
		if ( func.cargs.size() > 0 ) {
			adb << "(";
			bool f = true;
			for ( auto cit=func.cargs.begin(); cit != func.cargs.end(); ++cit ) {
				const s_config::s_section2::s_func::s_carg& arg = *cit;
				if ( !f )
					adb << "; ";
				else	f = false;
				adb << arg.name << " : " << arg.type;
			}
			adb << ")";
		}

		if ( func.returns != "" )
			adb << " return " << func.returns << ";\n";
		else	adb << ";\n";

		//  pragma Import(C,UX_close,"close");
		adb << "      pragma Import(C," << binding_name << ",\""
                    << func.bind_prefix << func.c_name << "\");\n";

		// Temporaries
		for ( auto ait=func.aargs.begin(); ait != func.aargs.end(); ++ait ) {
			s_config::s_section2::s_func::s_aarg& arg = *ait;

			if ( arg.io == "in" && arg.temp != "" ) {
				std::stringstream s;
				std::string tempname;

				s << "T" << arg.argno;
				tempname = s.str();

				adb << "      " << tempname << " : " << arg.type
				    << " := " << arg.tempval << ";\n";
			}
		}

		// Temporary variables
		for ( auto t=func.temps.begin(); t != func.temps.end(); ++t ) {
			s_config::s_section2::s_func::s_temp& temp = *t;

			adb << "      " << temp.name << " : " << temp.type;
			if ( temp.init != "" )
				adb << " := " << temp.init;
			adb << ";\n";
		}

		// Return value:
		if ( func.rname != "" ) {
			adb << "      " << func.rname << " : " << func.returns << ";\n";
		}

		adb	<< "   begin\n";

		// Insert pre-checks
		if ( func.prechecks.size() > 0 ) {
			for ( auto pit=func.prechecks.cbegin(); pit != func.prechecks.cend(); ++pit ) {
				const std::string& cond = *pit;
				adb << "      if not ( " << cond << " ) then\n"
				    << "         " << func.on_error << ";\n"
				    << "         return;\n"
				    << "      end if;\n";
			}
		}

		// Insert case & when checks
		if ( func.cases.size() > 0 ) {
			for ( auto cit=func.cases.cbegin(); cit != func.cases.cend(); ++cit ) {
				const std::string varname = cit->first;
				const s_config::s_section2::s_func::s_cases& centry = cit->second;

				if ( centry.casevec.size() > 0 ) {
					std::vector<std::string> kvec;

					for ( auto vit=centry.casevec.cbegin(); vit != centry.casevec.cend(); ++vit ) {
						const std::string& the_case = *vit;

						auto mit = config.declared_macros.find(the_case);
						if ( mit != config.declared_macros.end() )
							kvec.push_back(the_case);
					}

					if ( kvec.size() > 0 ) {
						adb << "      case " << varname << " is\n";

						for ( auto vit=kvec.cbegin(); vit != kvec.cend(); ++vit ) {
							const std::string& the_case = *vit;
							adb << "         when " << the_case << "=>\n"
							    << "            null;\n";
						}
	
						adb << "         when others =>\n"
						    << "            Error := EINVAL;\n";

						if ( centry.on_error != "" )
							adb << "            " << centry.on_error << ";\n";

						adb << "            return;\n"
						    << "      end case;\n";
					}
				}
			}
		}

		if ( func.rname != "" ) {
			adb << "      " << func.rname << " := " << binding_name;
		} else	{
			adb << "      " << binding_name;
		}

		if ( func.cargs.size() > 0 ) {
			adb << "(";
			bool f = true;
			for ( auto fit=func.cargs.begin(); fit != func.cargs.end(); ++fit ) {
				s_config::s_section2::s_func::s_carg& arg = *fit;
				if ( f )
					f = false;
				else	adb << ",";
				adb << arg.from;
			}
			adb << ")";
		}
		adb 	<< ";\n";

		// Output values:
		for ( auto oit=func.aargs.begin(); oit != func.aargs.end(); ++oit ) {
			s_config::s_section2::s_func::s_aarg& arg = *oit;

			if ( arg.from != "implied" ) {
				if ( arg.io == "out" || arg.io == "in out" ) {
					adb << "      " << arg.name << " := "
					    << arg.from << ";\n";
				}
			}
		}

		// Function return value
		if ( func.type == "function" ) {
			adb << "      return " << func.ada_rfrom << ";\n";
		}

		adb	<< "   end " << func.ada_name << ";\n\n";

		//////////////////////////////////////////////////////
		// Check if a macro must be emitted
		//////////////////////////////////////////////////////

		if ( func.macro != "" ) {
			if ( !cc.is_open() && !gcc_open(cc,config.section2.genset,".cc") )
				exit(3);

			for ( auto it=func.includes.begin(); it != func.includes.end(); ++it ) {
				const std::string& incl = *it;

				if ( inclset.find(incl) == inclset.end() ) {
					if ( incl[0] != '.' )
						cc << "#include <" << incl << ">\n";
					else	cc << "#include \"" << incl << "\"\n";
					inclset.insert(incl);
				}
			}

			cc << "\n"
			   << func.macro << "\n\n";
		}

	}

	ads.close();
	adb.close();
	cc.close();
}

// End sect2.cpp
