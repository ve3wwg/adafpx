
   type errno_t is new int_t;
   type fcntl_t is new int_t;
   type whence_t is new int_t;
   type mntflags_t is new int_t;
   type amode_t is new uint_t;
   type ptrace_t is new int_t;
   type rlimkind_t is new int_t;
   type rwho_t is new int_t;
   type mprot_t is new uint_t;
   type mmap_t is new uint_t;
   type sysc_t is new int_t;    
   type logopt_t is new uint_t;
   type logfac_t is new uint_t;
   type itim_t is new uint_t;
   type ipccmd_t is new int_t;
   type sigpmop_t is new int_t;
   type prio_t is new int_t;

   type short_array is array(Natural range <>) of short_t;
   type int_array is array(Natural range <>) of int_t;
   type long_array is array(Natural range <>) of long_t;
   type llong_array is array(Natural range <>) of llong_t;

   type ushort_array is array(Natural range <>) of ushort_t;
   type uint_array is array(Natural range <>) of uint_t;
   type ulong_array is array(Natural range <>) of ulong_t;
   type ullong_array is array(Natural range <>) of ullong_t;

   type DIR is new System.Address;
   Null_DIR : constant DIR := DIR(System.Null_Address);
   function "="(L,R : DIR) return Boolean;

