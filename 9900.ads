
private

   function C_Last(C_String: String) return Natural;
   function To_Count(Status: ssize_t) return Natural;
   function To_Count(Status: int_t) return Natural;
   function C_Error(Ret_Val: int_t) return errno_t;
   function C_Error(Ret_Val: ssize_t) return errno_t;
   function C_Error(PID: pid_t) return errno_t;
   function C_Error(Ret_Val: sig_t) return errno_t;
   function C_Error(Ret_Val: mode_t) return errno_t;
   function Pos_PID(Status: int_t) return pid_t;
   function Neg_PID(Status: int_t) return pid_t;
   function To_Clock(Ticks: clock_t) return clock_t;
   function C_Error_Ptr(Ret_Val: System.Address) return errno_t;

   pragma Inline(To_Count);
   pragma Inline(C_Error);
   pragma Inline(Pos_PID);
   pragma Inline(Neg_PID);
   pragma Inline(To_Clock);
