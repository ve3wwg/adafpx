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

#include <iostream>
#include <istream>

int
main(int argc,char **argv) {
	std::string platform, version, machine;
	int ltoken;

	platform = uts_platform();
	version = uts_version();
	machine = uts_machine();

	std::cout << "Platform: " << platform << "\n"
		<< "Machine:  " << machine << "\n"
		<< "Version:  " << version << "\n";

	loadconfig();

	system("rm -fr ./staging");
	mkdir("./staging",0777);
	system("cp 0005.ads ./staging/.");
	system("cp 0005.adb ./staging/.");
	system("cp 0060.ads ./staging/.");
	system("cp 9999.ads ./staging/.");
	system("cp 9999.adb ./staging/.");

	comp_macros();
	comp_types();
	comp_systypes();
//	comp_funcs();

	emit_basic_types();
	emit_sys_types();
	emit_macros();
	emit_structs();
	emit_section2();

	system("cat ./staging/????.ads >posix.ads");
	system("cat ./staging/????.adb >posix.adb");

exit(0);

	while ( (ltoken = yylex()) != 0 ) {
		unsigned lno = lex_lineno();
		int id = lex_token();
		std::string& token = revsym[id];

		printf("%06u : %3d '%s' (%d)\n",
			lno,
			ltoken,
			token.c_str(),
			id);
	}
}

// End main.cpp
