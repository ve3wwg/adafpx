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

#include <string>

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

bool
match(const std::string pattern,const std::string s,bool caseless) {
	int flags = caseless ? FNM_CASEFOLD : 0;

	return !fnmatch(pattern.c_str(),s.c_str(),flags);
}

// End utils.cpp
