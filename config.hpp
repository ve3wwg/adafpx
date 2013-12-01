//////////////////////////////////////////////////////////////////////
// config.hpp -- XML Config Data
// Date: Thu Nov 28 08:04:02 2013   (C) datablocks.net
///////////////////////////////////////////////////////////////////////

#ifndef CONFIG_HPP
#define CONFIG_HPP

#include <string>
#include <vector>
#include <unordered_map>

struct s_config {
	struct s_macro_set {
		int				genset;
		std::string			type;
		std::string			format;
		std::vector<std::string>	includes;
		std::vector<std::string> 	macros;
		std::unordered_map<std::string,std::string> alternates;
		std::unordered_map<std::string,long> values;
	};
	std::vector<s_macro_set> macro_sets;

	struct s_basic_types {
		struct s_basic_type {
			unsigned		size;		// Size in bytes of the type
		};
		int				genset;
		std::unordered_map<std::string,s_basic_type> info;
	} basic_types;

	struct s_sys_types {
		struct s_sys_type {
			unsigned		size;		// Size in bytes of the type
			bool			is_unsigned;	// True if the type is unsigned
		};
		int				genset;
		std::vector<std::string>	includes;
		std::unordered_map<std::string,s_sys_type> info;
	} sys_types;

	struct s_section2 {
		int				genset;		

		struct s_func {
			std::string			c_name;		// name=
			std::string			alt_name;	// Alternate Ada name (internal)
			std::string			ada_name;	// ada_name=
			std::string			rname;		// rname=
			std::string			type;		// type="procedure"
			std::string			returns;	// returns=
			bool				finline;	// inline=
			std::vector<std::string>	includes;

			struct s_carg {
				std::string		name;		// name=
				std::string		type;		// type=
				std::string		from;		// src=
			};
			struct s_aarg {
				std::string		name;		// name=
				std::string		type;		// type=
				std::string		io;		// io={in|out|inout}
				std::string		temp;		// temp= (temp var name)
				std::string		tempval;	// tempval= (temp val expression)
				std::string		from;		// from=
				unsigned		argno;
			};
			struct s_temp {
				std::string		name;		// name=
				std::string		type;		// type=
				std::string		init;		// init=
			};
			std::vector<s_carg>		cargs;
			std::vector<s_aarg>		aargs;
			std::vector<s_temp>		temps;
		};
		std::vector<s_func>		funcs;
	} section2;
};

extern s_config config;

#endif // CONFIG_HPP

// End config.hpp
