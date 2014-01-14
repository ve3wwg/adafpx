-- p0029.adb - Mon Jan 13 19:59:09 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Posix;
use Posix;

package body P0029 is

   procedure User1_Handler(Sig : sig_t);
   procedure Alarm_Handler(Sig : sig_t);

   pragma Convention(C,User1_Handler);
   pragma Convention(C,Alarm_Handler);

   Sig_User1 :       Boolean := false;
   Alarm_Signaled :  Boolean := false;

   pragma Volatile(Sig_User1);
   pragma Volatile(Alarm_Signaled);

   procedure User1_Handler(Sig : sig_t) is
      Prior :  sig_t;
      Error :  errno_t;
   begin
      pragma Assert(Sig = SIGUSR1);
      Sig_User1 := true;
      Signal(Sig,User1_Handler'Access,Prior,Error);   -- This call signature returns Prior
      pragma Assert(Error = 0);
   end User1_Handler;

   procedure Alarm_Handler(Sig : sig_t) is
      Error : errno_t;
   begin
      pragma Assert(Sig = SIGALRM);
      Alarm_Signaled := not Alarm_Signaled;           -- Toggle flag
      Signal(Sig,User1_Handler'Access,Error);         -- This is the old unreliable signal API
      pragma Assert(Error = 0);
   end Alarm_Handler;


   procedure Test is
      PID :    pid_t;
      Secs :   uint_t;
      Sigs :   sigset_t;
      Error :  errno_t;
   begin
      PID := Getpid;

      Signal(SIGUSR1,User1_Handler'Access,Error);
      pragma Assert(Error = 0);

      Signal(SIGALRM,Alarm_Handler'Access,Error);
      pragma Assert(Error = 0);
      
      Sigemptyset(Sigs);
      Sigaddset(Sigs,SIGUSR1);
      Sigaddset(Sigs,SIGALRM);

      Sigprocmask(SIG_BLOCK,Sigs,Error);
      pragma Assert(Error = 0);

      Kill(PID,SIGUSR1,Error);
      pragma Assert(Error = 0);
      pragma Assert(Sig_User1 = false);

      Sigemptyset(Sigs);
      Sigaddset(Sigs,SIGALRM);
      Sigsuspend(Sigs,Error);
      pragma Assert(Error = 0);
      pragma Assert(Alarm_Signaled);   -- Should be toggled true

      Kill(PID,SIGALRM,Error);
      pragma Assert(Error = 0);
      pragma Assert(Alarm_Signaled);   -- Should not be toggled

   end Test;

end P0029;
