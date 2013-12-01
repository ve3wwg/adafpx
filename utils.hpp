//////////////////////////////////////////////////////////////////////
// utils.hpp -- Utility Subroutines
// Date: Thu Nov 28 21:12:55 2013   (C) datablocks.net
///////////////////////////////////////////////////////////////////////

#ifndef UTILS_HPP
#define UTILS_HPP

const char *uts_platform();
const char *uts_release();
const char *uts_version();
const char *uts_machine();

bool match(const std::string pattern,const std::string s,bool caseless=true);

#endif // UTILS_HPP

// End utils.hpp
