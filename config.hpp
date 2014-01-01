//////////////////////////////////////////////////////////////////////
// config.hpp -- XML Config Data
// Date: Thu Nov 28 08:04:02 2013   (C) datablocks.net
///////////////////////////////////////////////////////////////////////

#ifndef CONFIG_HPP
#define CONFIG_HPP

#include <string>
#include <vector>
#include <unordered_map>
#include <set>
#include <unordered_set>

struct s_config {
	bool					debug;		// Show debug info
	std::string				gcc_options;
	std::set<int>				tests;		// Tests to perform

	std::unordered_set<std::string>		copies;		// Files to be copied
	std::unordered_set<std::string>		builtins;	// Builtin types

	struct s_macro_set {
		int				genset;
		std::string			type;
		std::string			format;
		std::vector<std::string>	includes;
		std::vector<std::string> 	macros;
		std::unordered_map<std::string,std::string> ada_name;
		std::unordered_map<std::string,std::string> alternates;
		std::unordered_map<std::string,long> values;
	};
	std::vector<s_macro_set> macro_sets;

	struct s_basic_types {
		struct s_basic_type {
			unsigned		size;		// Size in bytes of the type
			std::string		ada;		// Ada name for the type
		};
		int				genset;
		std::unordered_map<std::string,s_basic_type> info;
		std::unordered_map<std::string,std::string> a2cmap;
		std::unordered_map<int,std::string> sizemap;
	} basic_types;

	struct s_sys_types {
		struct s_sys_type {
			unsigned		size;		// Size in bytes of the type
			bool			is_unsigned;	// True if the type is unsigned
			std::string		subtype;	// Use this subtype
		};
		int				genset;
		std::vector<std::string>	includes;
		std::unordered_map<std::string,s_sys_type> info;
	} sys_types;

	struct s_ada_types {
		struct s_ada_type {
			std::string	name;
			std::string	type;
			std::string	subtype;
			std::string	range;
		};
		int			genset;
		std::vector<s_ada_type> adavec;
	} ada_types;

	struct s_section2 {
		int				genset;		

		struct s_func {
			std::string			c_name;		// name=
			std::string			alt_name;	// Alternate Ada name (internal)
			std::string			ada_name;	// ada_name=
			std::string			rname;		// rname=
			std::string			type;		// type="procedure"
			std::string			returns;	// returns= (C function)
			std::string			ada_return;	// ada_return=
			std::string			ada_rfrom;	// ada_return_from=
			bool				finline;	// inline=
			std::string			bind_prefix;	// "UX_" or prefix=
			std::string			macro;		// macro= if any
			std::vector<std::string>	includes;
			std::vector<std::string>	use_clauses;

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
			struct s_cases {
				std::string		on_error;
				std::vector<std::string> casevec;
			};
			std::vector<std::string>	decls;
			std::vector<std::string> 	prechecks;
			std::string			on_error;
			std::unordered_map<std::string,s_cases> cases;
		};
		std::vector<s_func>		funcs;
	} section2;
	
	struct s_structs {
		struct s_member {
			std::string		tname;			// Type name (if any)
			std::string		name;			// Member name
			std::string		a_name;			// Ada member name
			unsigned		msize;			// Member size
			int			union_struct;		// 1==struct
			unsigned		moffset;		// Member offset
			bool			msigned;		// Member is signed
			unsigned		array;			// Member is array [n]
			unsigned		ptr;			// Pointer count
		};
		struct s_struct {
			int			genset;			// Struct genset #
			std::string		c_name;			// C structure name
			std::string		a_name;			// Name to use in Ada
			std::vector<std::string> includes;
			unsigned		size;			// Struct size in bytes
			std::vector<s_member>	members;
			std::unordered_map<std::string,std::string> prefs; // Preferred type name
			std::unordered_map<std::string,int> is_struct;  // Treat member as a struct
		};
		std::vector<s_struct>		structvec;
	} structs;

	std::unordered_set<std::string> declared_macros;		// Known macro constants
};

extern s_config config;

#endif // CONFIG_HPP

// End config.hpp
