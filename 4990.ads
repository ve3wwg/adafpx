
   type s_iovec_array is array(size_t range <>) of s_iovec;
   type argv_array is array(Natural range <>) of System.Address;
   type fd_array is array(Natural range <>) of fd_t;
   type gid_array is array(Natural range <>) of gid_t;
   type s_timeval_array is array(Natural range <>) of s_timeval;
   type s_timeval_array2 is array(Natural range 1..2) of s_timeval;

   type u_sockaddr ( Discr : uint16_t := AF_UNSPEC ) is
      record
         case Discr is
            when AF_INET =>
               addr_in :      s_sockaddr_in;
            when AF_UNIX =>
               addr_un :      s_sockaddr_un;
            when others =>
               addr_sock :    s_sockaddr;
         end case;
      end record;

   pragma Unchecked_Union(u_sockaddr);
   pragma Convention(C,u_sockaddr);
