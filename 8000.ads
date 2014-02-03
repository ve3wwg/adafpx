
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

   -- Put array of file descriptors
   procedure Put_Cmsg(                          -- Send file descriptors
      Control_Msg_Buf : in     uchar_array;     -- Control message buffer
      Cur_Len :         in out uint64_t;        -- Current control message content length
      Fds :             in     fd_array_t;      -- Array of file descriptors
      Accepted :        out    Boolean          -- Value was accepted
   );

   -- Determine cmsg type
   procedure Get_Cmsg(
      Control_Msg_Buf : in     uchar_array;     -- Control message buffer
      Offset :          in     uint64_t;        -- Current control message offset
      Cmsg_Level :      out    int_t;           -- Returned message level
      Cmsg_Type :       out    int_t;           -- Returned message type
      Received :        out    Boolean          -- True when a message is received
   );

   -- Skip current message
   procedure Skip_Cmsg(
      Control_Msg_Buf : in     uchar_array;     -- Control message buffer
      Offset :          in out uint64_t;        -- Current control message offset
      Received :        out    Boolean          -- True when a message is received
   );

   -- Fetch cmsg data & advance offset
   procedure Get_Cmsg(
      Control_Msg_Buf : in     uchar_array;     -- Control message buffer
      Offset :          in out uint64_t;        -- Current control message offset
      Data :            in     System.Address;  -- Data destination address
      Data_Length :     in out uint64_t;        -- Data destinaton length (bytes)
      Received :        out    Boolean          -- True when a message is received
   );

   -- Fetch cmsg file descriptors & advance offset
   procedure Get_Cmsg(
      Control_Msg_Buf : in     uchar_array;     -- Control message buffer
      Offset :          in out uint64_t;        -- Current control message offset
      Fds :             out    fd_array_t;      -- Returned File descriptors
      Count :           out    Natural;         -- Number of returned File descriptors
      Received :        out    Boolean          -- True when a message was received
   );

