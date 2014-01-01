
   function Strerror(Error: errno_t) return String;

   function Ada_String(C_String: String) return String;
   function C_String(Ada_String: String) return String;

   function Argv_Length(Argvs: String) return Natural;
   function Argv_Length(Argv: argv_array) return Natural;

   procedure Find_Nul(S: String; X: out Natural; Found: out Boolean);
   function To_Argv(Argvs: String) return argv_array;
   procedure To_Argv(Argvs: String; Argv: out argv_array);

