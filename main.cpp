//////////////////////////////////////////////////////////////////////
// main.cpp -- Test Main
// Date: Wed Nov 27 23:07:19 2013
///////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <assert.h>

#include <sys/stat.h>

#include "glue.hpp"
#include "utils.hpp"
#include "ansi-c-yacc.hpp"
#include "comp.hpp"
#include "config.hpp"

#include <iostream>
#include <istream>
#include <sstream>

extern char *optarg;
extern int optind;
extern int optopt;
extern int opterr;
extern int optreset;

static void
usage(const char *cmd) {
	std::cout
		<< "Usage: " << cmd << "[-d] [-g opt] [-Ddefine] [-I path] [-p] [-h]\n"
		<< "where:\n"
		<< "  -d            Enables lexical/yacc debug output\n"
		<< "  -y            Enable dump of yacc nodes\n"
		<< "  -g opt        Pass 'opt' to gcc\n"
		<< "  -D define     gcc macro declare option\n"
		<< "  -I path       gcc include path\n"
		<< "  -p            Just show platform details and exit\n"
		<< "  -G gcc	    Name of gcc (e.g. gnatgcc)\n"
		<< "  -h            This help info and exit.\n";
}

int
main(int argc,char **argv) {
	std::stringstream opt_gcc;
	std::string family, platform, version, machine;
	bool opt_show_platform = false;
	char optch;
	extern int yydebug;

	config.debug = false;

	config.gcc = "gcc";

	while ( (optch = getopt(argc,argv,"dyI:D:g:pP:G:h")) != -1) {
		switch ( optch ) {
		case 'd' :
			yydebug = 1;
			config.debug = true;
			break;
		case 'y' :
			yacc_dump = 1;
			break;
		case 'g' :
			opt_gcc << optarg << " ";
			break;
		case 'D' :
			opt_gcc << "-D" << optarg << " ";
			break;
		case 'I' :
			opt_gcc << "-I" << optarg << " ";
			break;
		case 'p' :
			opt_show_platform = true;
			break;
		case 'G' :
			config.gcc = optarg;
			break;
		case 'h' :
		default:
			usage(argv[0]);
			exit(optch == 'h' ? 0 : 1);
		}
        }

        config.gcc_options = opt_gcc.str();

	platform = uts_platform();
	version = uts_version();
	machine = uts_machine();

	{
		std::vector<std::string> vec;
		split(vec,platform,' ');
		family = vec[0];
	}

	std::cout
		<< "Platform:    " << platform << "\n"
		<< "Machine:     " << machine << "\n"
		<< "Version:     " << version << "\n"
		<< "gcc options: " << config.gcc_options << "\n";

	if ( opt_show_platform )
		exit(0);

	config.gnatprep["%family"]   = family;
	config.gnatprep["%platform"] = platform;
	config.gnatprep["%machine"]  = machine;
	config.gnatprep["%version"]  = version;

	loadconfig();

	system("rm -fr ./staging");
	mkdir("./staging",0777);

	//////////////////////////////////////////////////////////////
	// Copy out canned portions of code to staging directory
	//////////////////////////////////////////////////////////////
	{
		for ( auto it=config.copies.begin(); it != config.copies.end(); ++it ) {
			const std::string filename = *it;
			std::stringstream ss;

			ss << "cp " << filename << " ./staging/.";
			const std::string cmd = ss.str();
			system(cmd.c_str());
		}
	}

	comp_macros();
	comp_types();
	comp_systypes();

	emit_basic_types();
	emit_sys_types();
	emit_macros();
	emit_structs();
	emit_section2();

	system("cat ./staging/????.ads >posix.ads");
	system("cat ./staging/????.adb >posix.adb");

	{
		std::fstream mktests;
		int count = 0;

		mktests.open("Makefile.tests",std::fstream::out);

		mktests << "# Makefile.tests - generated file\n\n"
			<< "test:\ttests\n"
			<< "tests:\t";

		for ( auto it=config.tests.begin(); it != config.tests.end(); ++it ) {
			int testno = *it;
		
			mktests << "t";
			mktests.width(4);
			mktests.fill('0');
			mktests << testno << " ";
			if ( ++count % 10 == 0 )
				mktests << "\\\n";
		}

		mktests << "\n";

		for ( auto it=config.tests.begin(); it != config.tests.end(); ++it ) {
			int testno = *it;
		
			mktests << "\t./t";
			mktests.width(4);
			mktests.fill('0');
			mktests << testno << "\n";
		}
	}
}

// End main.cpp
