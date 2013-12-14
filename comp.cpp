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
#include "config.hpp"

std::fstream lexstr;

static bool end_of_line = false;
static unsigned lno = 1;

unsigned
lex_lineno() {
	return lno;
}

static void
comp_input_reset() {

	//////////////////////////////////////////////////////////////
	// Reset the iostream for Reading
	//////////////////////////////////////////////////////////////

	end_of_line = false;
	lno = 1;
	if ( lexstr.is_open() )
		lexstr.close();

	lexer_reset();

	//////////////////////////////////////////////////////////////
	// Preload any builtin type definitions
	//////////////////////////////////////////////////////////////
	
	for ( auto it=config.builtins.begin(); it != config.builtins.end(); ++it ) {
		const std::string& type = *it;
		register_builtin(type);
	}
}

int
comp_input() {

	if ( end_of_line ) {
		++lno;
		end_of_line = false;
std::cerr << "Line # " << lno << "\n";
	}

	if ( !lexstr.is_open() ) {
std::cerr << "  returned EOF(1);\n";		
		return EOF;
	} else if ( !lexstr.good() ) {
		lexstr.close();
std::cerr << "  returned EOF(2);\n";		
		return EOF;
	}

	char ch = lexstr.get();

	if ( ch == '\n' )
		end_of_line = true;
	return ch;
}

bool
lex_open(int genset,const std::string& suffix) {
	comp_input_reset();
	return gcc_open(lexstr,genset,suffix);
}

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

bool
gcc_precompile(std::fstream& fs,int genset,const std::string& variation) {
	char filename[32];
	std::string cmd, path;
	int rc;

	if ( fs.is_open() )
		fs.close();

	sprintf(filename,"%04d",genset);

	{
		std::stringstream s;
		s << "./staging/" << filename << variation << ".c";
		path = s.str();
	}
	{
		std::stringstream s;
		s 	<< "gcc -P -E " << path
			<< " | sed '/^ *#.*$/d' "
			<< " > ./staging/" << filename << ".out"
			<< " 2>./staging/" << filename << ".err ";
		cmd = s.str();
	}

	rc = system(cmd.c_str());	// Compile
	if ( rc ) {
		std::cerr << "Precompile failed: " << cmd << "\n";
		return false;
	}

	std::string outpath;
	{
		std::stringstream s;
		s 	<< "./staging/" << filename << ".out";
		outpath = s.str();
	}

	fs.open(outpath.c_str(),std::fstream::in);
	if ( fs.fail() ) {
		std::cerr << strerror(errno) << ": opening " << path << " for read.\n";
		return false;
	}

std::cerr << "PARSING: " << outpath << "\n";
	return true;
}

bool
gcc_precomplex(int genset,const std::string& variation) {
	comp_input_reset();
	return gcc_precompile(lexstr,genset,variation);
}

void
parse(std::vector<std::string>& svec,const std::string s,const std::string delim) {
	size_t spos = 0, npos;

	svec.clear();
	for ( npos = s.find_first_of(delim,spos); npos != std::string::npos; npos = s.find_first_of(delim,spos) ) {
		size_t len = npos - spos;	// Length
		std::string subs = s.substr(spos,len);
		svec.push_back(subs);
		spos = npos + 1;
	}

	if ( spos < s.size() ) {
		std::string subs = s.substr(spos);
		svec.push_back(subs);
	}
}

// End comp.cpp
