//////////////////////////////////////////////////////////////////////
// utils.cpp -- Utility Subroutines
// Date: Thu Nov 28 21:13:09 2013
///////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <fnmatch.h>
#include <assert.h>

#include <sys/utsname.h>

#include "utils.hpp"

static bool uts_init = false;
static struct utsname uts_name;
static std::string platform;	// Darwin 10.x

static void
uts_populate() {
	if ( !uts_init ) {
		uname(&uts_name);
		uts_init = true;
		platform = uts_name.sysname;
		platform += " ";
		platform += uts_name.release;
	}		
}

const char *
uts_platform() {
	uts_populate();
	return platform.c_str();
}

const char *
uts_release() {
	uts_populate();
	return uts_name.release;
}

const char *
uts_version() {
	uts_populate();
	return uts_name.version;
}

const char *
uts_machine() {
	uts_populate();
	return uts_name.machine;
}

//////////////////////////////////////////////////////////////////////
// Parse s into vec, based upon separator sep
//////////////////////////////////////////////////////////////////////

void
split(std::vector<std::string>& vec,const std::string s,char sep) {
	size_t spos = 0;

	vec.clear();
	while ( spos < s.size() ) {
		size_t p = s.find_first_of(sep,spos);
		if ( p == std::string::npos ) {
			if ( spos < s.size() )
				vec.push_back(s.substr(spos));
			break;
		}
		const std::string sub = s.substr(spos,p-spos);
		vec.push_back(sub);
		spos = p + 1;
	}
}

bool
match(const std::string pattern,const std::string s,bool caseless) {
	int flags = caseless ? FNM_CASEFOLD : 0;
	std::vector<std::string> mvec;

	split(mvec,pattern);

	for ( auto it=mvec.begin(); it != mvec.end(); ++it ) {
		const std::string& pat = *it;

		if ( !fnmatch(pat.c_str(),s.c_str(),flags) )
			return true;
	}

	return false;
}

// End utils.cpp
