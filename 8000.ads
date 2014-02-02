
   function Strerror(Error: errno_t) return String;

   function Ada_String(C_String: String) return String;
   function Ada_String(C_String: uchar_array) return String;
   function C_String(Ada_String: String) return String;

   function Argv_Length(Argvs: String) return Natural;
   function Argv_Length(Argv: argv_array) return Natural;

   procedure Find_Nul(S: String; X: out Natural; Found: out Boolean);
   function To_Argv(Argvs: String) return argv_array;
   procedure To_Argv(Argvs: String; Argv: out argv_array);

   function To_String(A : uchar_array) return String;
   function To_uchar_array(S : String) return uchar_array;

   function Error_Pointer return System.Address;

   -------------------------------------------------------------------
   -- See test program t0047.adb for an example of use:
   -------------------------------------------------------------------

   procedure Put_Cmsg(
      Control_Msg_Buf : in     uchar_array;     -- Control message buffer
      Cur_Len :         in out uint64_t;        -- Current control message content length
      Cmsg_Level :      in     int_t;           -- Required message level
      Cmsg_Type :       in     int_t;           -- Required message type
      Data :            in     System.Address;  -- Source data to put into control message buffer
      Data_Length :     in     uint64_t;        -- Source data length (bytes)
      Accepted :        out    Boolean          -- True when value was accepted
   );

   procedure Put_Cmsg(                          -- Send file descriptors
      Control_Msg_Buf : in     uchar_array;     -- Control message buffer
      Cur_Len :         in out uint64_t;        -- Current control message content length
      Fds :             in     fd_array_t;      -- Array of file descriptors
      Accepted :        out    Boolean          -- Value was accepted
   );

   procedure Get_Cmsg(
      Control_Msg_Buf : in     uchar_array;     -- Control message buffer
      Offset :          in out uint64_t;        -- Current control message offset
      Cmsg_Level :      out    int_t;           -- Returned message level
      Cmsg_Type :       out    int_t;           -- Returned message type
      Data :            in     System.Address;  -- Data destination address
      Data_Length :     in     uint64_t;        -- Data destinaton length (bytes)
      Received :        out    Boolean          -- True when a message is received
   );

