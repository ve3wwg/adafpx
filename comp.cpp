//////////////////////////////////////////////////////////////////////
// comp.cpp -- Compile
// Date: Fri Nov 29 20:13:37 2013
///////////////////////////////////////////////////////////////////////

#include <stdarg.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <assert.h>

#include <iostream>
#include <string>
#include <sstream>

#include "comp.hpp"

bool
gcc_open(std::fstream& fs,int genset,const std::string& suffix) {
	char filename[32];
	std::string path;

	sprintf(filename,"%04d",genset);
	{
		std::stringstream s;

		s << "./staging/" << filename << suffix;
		path = s.str();
	}
	
	fs.open(path.c_str(),std::fstream::out);
	if ( fs.fail() ) {
		std::cerr << strerror(errno) << ": opening " << path << " for write.\n";
		return false;
	}

	return true;
}

bool
gcc_compile(std::fstream& fs,int genset) {
	char filename[32];
	std::string cmd, path;
	int rc;

	if ( fs.is_open() )
		fs.close();

	sprintf(filename,"%04d",genset);

	{
		std::stringstream s;
		s 	<< "gcc ./staging/" << filename << ".c -o ./staging/" << filename << ".xeq"
			<< " 2>./staging/" << filename << ".err ";
	
		cmd = s.str();
	}

	rc = system(cmd.c_str());	// Compile
	if ( rc ) {
		std::cerr << "Compile failed: " << cmd << "\n";
		return false;
	}

	{	
		std::stringstream s;

		s 	<< "./staging/" << filename << ".xeq "
			<< "1>./staging/" << filename << ".out "
			<< "2>./staging/" << filename << ".run";
		cmd = s.str();
	}	

	rc = system(cmd.c_str());	// Run compiled code
	if ( rc ) {
		std::cerr << "Run failed: " << cmd << "\n";
		return false;
	}

	{
		std::stringstream s;

		s	<< "./staging/" << filename << ".out";
		path = s.str();
	}

	fs.open(path.c_str(),std::fstream::in);
	if ( fs.fail() ) {
		std::cerr << strerror(errno) << ": opening " << path << " for read.\n";
		return false;
	}

	return true;
}

// End comp.cpp
