//////////////////////////////////////////////////////////////////////
// utils.hpp -- Utility Subroutines
// Date: Thu Nov 28 21:12:55 2013   (C) datablocks.net
///////////////////////////////////////////////////////////////////////

#ifndef UTILS_HPP
#define UTILS_HPP

#include <string>
#include <vector>

const char *uts_platform();
const char *uts_release();
const char *uts_version();
const char *uts_machine();

void split(std::vector<std::string>& vec,const std::string s,char sep='|');
bool match(const std::string pattern,const std::string s,bool caseless=true);

#endif // UTILS_HPP

// End utils.hpp
