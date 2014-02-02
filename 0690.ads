
   type s_iovec_array is array(size_t range <>) of s_iovec;
   type argv_array is array(Natural range <>) of System.Address;
   type fd_array is array(Natural range <>) of fd_t;
   type gid_array is array(Natural range <>) of gid_t;
   type s_timeval_array is array(Natural range <>) of s_timeval;
   type s_timeval_array2 is array(Natural range 1..2) of s_timeval;
