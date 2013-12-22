----------------------------------------------------------------------
-- Ada for POSIX (AdaFPX)
----------------------------------------------------------------------
-- Warren W. Gay VE3WWG     Tue Dec  3 18:49:48 2013
--
-- This is generated source code. Edit at your own risk.

package body Posix is
   
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

   function Pos_PID(Status: int_t) return pid_t is
   begin
      if Status >= 0 then
         return pid_t(Status);
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
