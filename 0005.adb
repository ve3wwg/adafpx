----------------------------------------------------------------------
-- Ada for POSIX (AdaFPX)
----------------------------------------------------------------------
-- Warren W. Gay VE3WWG     Tue Dec  3 18:49:48 2013
--
-- This is generated source code. Edit at your own risk.

with Ada.Characters.Latin_1;
with Ada.Unchecked_Conversion;

package body Posix is
   
   function Error_Pointer return System.Address is
      function UX_c_error_ptr return System.Address;
      pragma Import(C,UX_c_error_ptr,"c_error_ptr");
   begin
      return UX_c_error_ptr;
   end Error_Pointer;

   pragma Inline(Error_Pointer);

   function Strlen(C_Ptr : System.Address) return Natural is
      function UX_strlen(cstr : System.Address) return uint_t;
      pragma Import(C,UX_strlen,"c_strlen");
   begin
      return Natural(UX_strlen(C_Ptr));
   end Strlen;

   pragma Inline(Strlen);

   function Strerror(Error : errno_t) return String is
      function UX_strerror(err : errno_t) return System.Address;
      pragma Import(C,UX_strerror,"strerror");

      C_Msg : constant System.Address := UX_strerror(Error);
      Len :   constant Natural := Strlen(C_Msg);
      Msg :   String(1..Len);
      for Msg'Address use C_Msg;
   begin
      return Msg;
   end Strerror;

   function "="(L,R : DIR) return Boolean is
      use System;
   begin
      return System.Address(L) = System.Address(R);
   end "=";

   function C_Last(C_String: String) return Natural is
   begin
      for X in C_String'Range loop
         if Character'Pos(C_String(X)) = 0 then
            return Natural(X-1);
         end if;
      end loop;
      return C_String'Last;
   end C_Last;

   function To_Count(Status: ssize_t) return Natural is
   begin
      if Status <= 0 then
         return 0;
      else
         return Natural(Status);
      end if;
   end To_Count;

   pragma Inline(To_Count);

   function To_Count(Status: int_t) return Natural is
   begin
      if Status <= 0 then
         return 0;
      else
         return Natural(Status);
      end if;
   end To_Count;

   pragma Inline(To_Count);

   function C_Error(Ret_Val: int_t) return errno_t is
      function c_errno return errno_t;
      pragma Import(C,c_errno,"c_errno");
   begin
      if Ret_Val >= 0 then
         return 0;
      else
         return c_errno;
      end if;
   end C_Error;

   function C_Error(Ret_Val: long_t) return errno_t is
      function c_errno return errno_t;
      pragma Import(C,c_errno,"c_errno");
   begin
      if Ret_Val >= 0 then
         return 0;
      else
         return c_errno;
      end if;
   end C_Error;

   pragma Inline(C_Error);

   function C_Error(Ret_Val: ssize_t) return errno_t is
      function c_errno return errno_t;
      pragma Import(C,c_errno,"c_errno");
   begin
      if Ret_Val >= 0 then
         return 0;
      else
         return c_errno;
      end if;
   end C_Error;

   pragma Inline(C_Error);

   function C_Error(PID: pid_t) return errno_t is
      function c_errno return errno_t;
      pragma Import(C,c_errno,"c_errno");
   begin
      if PID /= -1 then
         return 0;
      else
         return c_errno;
      end if;
   end C_Error;

   pragma Inline(C_Error);

   function C_Error(Ret_Val: clock_t) return errno_t is
      function c_errno return errno_t;
      pragma Import(C,c_errno,"c_errno");
   begin
      pragma Warnings(Off);
      if Ret_Val < 0 or  else Ret_Val = clock_t'Last then
         return c_errno;
      else
         return 0;
      end if;
      pragma Warnings(On);
   end C_Error;

   function C_Error(Ret_Val: sig_t) return errno_t is
      function c_errno return errno_t;
      pragma Import(C,c_errno,"c_errno");
   begin
      if Ret_Val = SIG_ERR then
         return c_errno;
      else
         return 0;
      end if;
   end C_Error;

   function C_Error(Ret_Val: mode_t) return errno_t is
      function c_errno return errno_t;
      pragma Import(C,c_errno,"c_errno");
   begin
      pragma Warnings(Off);
      if Ret_Val < 0 or else Ret_Val = mode_t'Last then
         return c_errno;
      else
         return 0;
      end if;
      pragma Warnings(On);
   end C_Error;

   function C_Error(Ret_Val: DIR) return errno_t is
      function c_errno return errno_t;
      pragma Import(C,c_errno,"c_errno");
   begin
      if Ret_Val /= Null_DIR then
         return 0;
      else
         return c_errno;
      end if;
   end C_Error;

   function C_Error(Ret_Val: off_t) return errno_t is
      function c_errno return errno_t;
      pragma Import(C,c_errno,"c_errno");
   begin
      if Ret_Val >= 0 then
         return 0;
      else
         return c_errno;
      end if;
   end C_Error;

   function C_Error(Ret_Val: System.Address) return errno_t is
      use System;
      function c_errno return errno_t;
      pragma Import(C,c_errno,"c_errno");
   begin
      if Ret_Val /= Null_Address then
         return 0;
      else
         return c_errno;
      end if;
   end C_Error;

   function C_Error_Ptr(Ret_Val: System.Address) return errno_t is
      use System;
      function c_errno return errno_t;
      pragma Import(C,c_errno,"c_errno");
   begin
      if Ret_Val /= Error_Pointer then
         return 0;
      else
         return c_errno;
      end if;
   end C_Error_Ptr;

   pragma Inline(C_Error_Ptr);

   function C_String(Ada_String: String) return String is
      T : String(Ada_String'First..Ada_String'Last+1);
   begin
      T(T'First..T'Last-1) := Ada_String;
      T(T'Last) := Character'Val(0);
      return T;
   end C_String;

   function Ada_String(C_String: String) return String is
   begin
      for X in C_String'Range loop
         if Character'Pos(C_String(X)) = 0 then
            return C_String(C_String'First..X-1);
         end if;
      end loop;
      return C_String;
   end Ada_String;

   function Ada_String(C_String: uchar_array) return String is
      C : constant String(1..C_String'Length) := To_String(C_String);
   begin
      return Ada_String(C);
   end Ada_String;

   function Ada_String(C_String: System.Address) return String is
      use System;
   begin
      if C_String = Null_Address then
         return "";
      end if;

      declare
         Len : constant Natural := Strlen(C_String);
         Str : String(1..Len);
         for Str'Address use C_String;
      begin
         return Str;
      end;

   end Ada_String;

   function Pos_PID(Status: int_t) return pid_t is
   begin
      if Status >= 0 then
         return pid_t(Status);
      else
         return 0;
      end if;
   end Pos_PID;

   pragma Inline(Pos_PID);

   function Pos_PID(Status: pid_t) return pid_t is
   begin
      if Status >= 0 then
         return Status;
      else
         return 0;
      end if;
   end Pos_PID;

   pragma Inline(Pos_PID);

   function Neg_PID(Status: int_t) return pid_t is
   begin
      if Status < 0 then
         return pid_t(-Status);
      else
         return 0;
      end if;
   end Neg_PID;

   pragma Inline(Neg_PID);

   function Pos_Natural(Status: int_t) return Natural is
   begin
      if Status >= 0 then
         return Natural(Status);
      else
         return 0;
      end if;
   end Pos_Natural;

   pragma Inline(Pos_Natural);

   function Pos_Natural(Status: ssize_t) return Natural is
   begin
      if Status >= 0 then
         return Natural(Status);
      else
         return 0;
      end if;
   end Pos_Natural;

   pragma Inline(Pos_Natural);

   function Argv_Length(Argvs: String) return Natural is
      Count : Natural := 0;   
   begin
      for X in Argvs'Range loop
         if Character'Pos(Argvs(x)) = 0 then
            Count := Count + 1;
         end if;
      end loop;
      return Count + 1;
   end Argv_Length;

   function Argv_Length(Argv: argv_array) return Natural is
      use System;
   begin
      for X in Argv'Range loop
         if Argv(X) = System.Null_Address then
            return X - Argv'First;
         end if;
      end loop;
      return Argv'Length;
   end Argv_Length;

   procedure Find_Nul(S: String; X: out Natural; Found: out Boolean) is
   begin
      for Y in S'Range loop
         if Character'Pos(S(Y)) = 0 then
            X := Y;
            Found := True;
         end if;
      end loop;
      X := S'Last;
      Found := False;
   end Find_Nul;

   function To_Argv(Argvs: String) return argv_array is
      Count : constant Natural := Argv_Length(Argvs);
      X :     Natural := Argvs'First;
      Y :     Natural;
      Found : Boolean;
   begin
      declare
         Argv :  argv_array(0..Count-1);
         Arg_X : Natural := Argv'First;
      begin
         while X <= Argvs'Last loop
            Find_Nul(Argvs(X..Argv'Last),Y,Found);
            exit when not Found;
            Argv(Arg_X) := Argvs(X)'Address;
            Arg_X       := Arg_X + 1;
            X           := Y + 1;
         end loop;
         Argv(Arg_X) := System.Null_Address;
         return Argv;
      end;
   end To_Argv;

   procedure To_Argv(Argvs: String; Argv: out argv_array) is
      Count : Natural := Argv_Length(Argvs);
      Arg_X : Natural := Argv'First;
      C :     Natural := 0;
      X :     Natural := Argvs'First;
      Y :     Natural;
      Found : Boolean;
   begin
      pragma Assert(Argv'Length>1);

      if Count > Argv'Length then
         Count := Argv'Length - 1;
      end if;

      while C < Count and X <= Argvs'Last loop
          Find_Nul(Argvs(X..Argv'Last),Y,Found);
          exit when not Found;
          Argv(Arg_X) := Argvs(X)'Address;
          Arg_X       := Arg_X + 1;
          X           := Y + 1;
          C           := C + 1;
      end loop;

      Argv(Arg_X) := System.Null_Address;

   end To_Argv;

   function To_Clock(Ticks: clock_t) return clock_t is
   begin
        pragma Warnings(Off);
        if Ticks < 0 or else Ticks = clock_t'Last then
            return 0;
        else
            return Ticks;
        end if;
        pragma Warnings(On);
   end To_Clock;

   function To_String(A : uchar_array) return String is
      subtype uc_array is uchar_array(A'Range);
      subtype uc_string is String(1..A'Length);
      function To_String is new
         Ada.Unchecked_Conversion(Source => uc_array,Target => uc_string);
   begin
      return To_String(A);
   end To_String;

   function To_uchar_array(S : String) return uchar_array is
      subtype uc_string is String(S'Range);
      subtype uc_array is uchar_array(S'Range);
      function To_Array is new
         Ada.Unchecked_Conversion(Target => uc_array,Source => uc_string);
   begin
      return To_Array(S);
   end To_uchar_array;

   procedure Put_Cmsg(
      Control_Msg_Buf : in     uchar_array;     -- Control message buffer
      Cur_Len :         in out uint64_t;        -- Current control message content length
      Cmsg_Level :      in     int_t;           -- Required message level
      Cmsg_Type :       in     int_t;           -- Required message type
      Data :            in     System.Address;  -- Source data to put into control message buffer
      Data_Length :     in     uint64_t;        -- Source data length (bytes)
      Accepted :        out    Boolean          -- Value was accepted
   ) is

      function UX_Put_Cmsg(buf : System.Address; buflen, curlen : uint64_t; cmsg, data : System.Address;
         datalen : uint64_t) return uint64_t;
      pragma import(C,UX_Put_Cmsg,"c_put_cmsg");

      Cmsg :   s_cmsghdr;
      
   begin

      Cmsg.cmsg_level := Cmsg_Level;
      Cmsg.cmsg_type  := Cmsg_Type;

      Cur_Len := UX_Put_Cmsg(
         buf    => Control_Msg_Buf'Address,
         buflen => uint64_t(Control_Msg_Buf'Length),
         curlen => Cur_Len,
         cmsg   => Cmsg'Address,
         data   => Data,
         datalen => Data_Length
      );

      Accepted := Cur_Len > 0;

   end Put_Cmsg;

   procedure Put_Cmsg(
      Control_Msg_Buf : in     uchar_array;     -- Control message buffer
      Cur_Len :         in out uint64_t;        -- Current control message content length
      Fds :             in     fd_array_t;      -- Array of file descriptors
      Accepted :        out    Boolean          -- Value was accepted
   ) is
   begin
      Put_Cmsg(Control_Msg_Buf,Cur_Len,SOL_SOCKET,SCM_RIGHTS,Fds'Address,Fds'Size/8,Accepted);
   end Put_Cmsg;

   procedure Get_Cmsg(
      Control_Msg_Buf : in     uchar_array;     -- Control message buffer
      Offset :          in     uint64_t;        -- Current control message offset
      Cmsg_Level :      out    int_t;           -- Returned message level
      Cmsg_Type :       out    int_t;           -- Returned message type
      Received :        out    Boolean          -- True when a message was received
   ) is
      function UX_Get_Cmsg(buf : System.Address; buflen, offset : uint64_t; cmsg, data : System.Address;
         datalen : uint64_t) return uint64_t;
      pragma import(C,UX_Get_Cmsg,"c_get_cmsg");

      Cmsg :         s_cmsghdr;
      New_Offset :   uint64_t;
      
   begin

      New_Offset := UX_Get_Cmsg(
         buf    => Control_Msg_Buf'Address,
         buflen => uint64_t(Control_Msg_Buf'Length),
         offset => Offset,
         cmsg   => Cmsg'Address,
         data   => System.Null_Address,
         datalen => 0
      );

      Cmsg_Level := Cmsg.cmsg_level;
      Cmsg_Type  := Cmsg.cmsg_type;

      Received := New_Offset /= 0;

   end Get_Cmsg;

   procedure Get_Cmsg(
      Control_Msg_Buf : in     uchar_array;     -- Control message buffer
      Offset :          in out uint64_t;        -- Current control message offset
      Data :            in     System.Address;  -- Data destination address
      Data_Length :     in out uint64_t;        -- Data destinaton length (bytes)
      Received :        out    Boolean          -- True when a message was received
   ) is

      function UX_Get_Cmsg(buf : System.Address; buflen, offset : uint64_t; cmsg, data : System.Address;
         datalen : uint64_t) return uint64_t;
      pragma import(C,UX_Get_Cmsg,"c_get_cmsg");

      Cmsg :   s_cmsghdr;
      
   begin

      Offset := UX_Get_Cmsg(
         buf    => Control_Msg_Buf'Address,
         buflen => uint64_t(Control_Msg_Buf'Length),
         offset => Offset,
         cmsg   => Cmsg'Address,
         data   => Data,
         datalen => Data_Length
      );

      Received := Offset /= 0;
      if Received then
         Data_Length := Cmsg.cmsg_len;
      else
         Data_Length := 0;
      end if;

   end Get_Cmsg;

   procedure Get_Cmsg(
      Control_Msg_Buf : in     uchar_array;     -- Control message buffer
      Offset :          in out uint64_t;        -- Current control message offset
      Fds :             out    fd_array_t;      -- Returned File descriptors
      Count :           out    Natural;         -- Number of returned File descriptors
      Received :        out    Boolean          -- True when a message was received
   ) is

      function UX_Get_Cmsg(buf : System.Address; buflen, offset : uint64_t; cmsg, data : System.Address;
         datalen : uint64_t) return uint64_t;
      pragma import(C,UX_Get_Cmsg,"c_get_cmsg");

      Cmsg :      s_cmsghdr;
      Cmsg_Size : constant Natural := (Cmsg.cmsg_level'Size + Cmsg.cmsg_type'Size + Cmsg.cmsg_len'Size)/8;
      Unit_Size : constant Natural := Fds(Fds'First)'Size / 8;
      
   begin

      Offset := UX_Get_Cmsg(
         buf    => Control_Msg_Buf'Address,
         buflen => uint64_t(Control_Msg_Buf'Length),
         offset => Offset,
         cmsg   => Cmsg'Address,
         data   => Fds'Address,
         datalen => uint64_t(Fds'Length) * uint64_t(Unit_Size)
      );

      Count := (Natural(Cmsg.cmsg_len) - Cmsg_Size) / Unit_Size;
      Received := Offset /= 0;

   end Get_Cmsg;

