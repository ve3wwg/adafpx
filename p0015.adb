-- p0015.adb - Sat Jan  4 22:44:33 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Posix;
use Posix;

package body P0015 is

   procedure User1_Handler(Sig : sig_t);
   procedure User2_Handler(Sig : sig_t);
   procedure Alarm_Handler(Sig : sig_t);

   pragma Convention(C,User1_Handler);
   pragma Convention(C,User2_Handler);
   pragma Convention(C,Alarm_Handler);


   Sig_User1 :       Natural := 0;
   Sig_User2 :       Natural := 0;
   Alarm_Signaled :  Boolean := false;

   pragma Volatile(Sig_User1);
   pragma Volatile(Sig_User2);
   pragma Volatile(Alarm_Signaled);


   procedure User1_Handler(Sig : sig_t) is
      Prior :  sig_t;
      Error :  errno_t;
   begin
      pragma Assert(Sig = SIGUSR1);
      Sig_User1 := Sig_User1 + 1;
      Signal(Sig,User1_Handler'Access,Prior,Error);  -- This call signature returns Prior
      pragma Assert(Error = 0);
   end User1_Handler;

   procedure User2_Handler(Sig : sig_t) is
      Error :  errno_t;
   begin
      pragma Assert(Sig = SIGUSR2);
      Sig_User2 := Sig_User2 + 1;
      Signal(Sig,User1_Handler'Access,Error);        -- This is the old unreliable signal API
      pragma Assert(Error = 0);
   end User2_Handler;

   procedure Alarm_Handler(Sig : sig_t) is
      Error : errno_t;
   begin
      pragma Assert(Sig = SIGALRM);
      Alarm_Signaled := true;
      Signal(Sig,User1_Handler'Access,Error);        -- This is the old unreliable signal API
      pragma Assert(Error = 0);
   end Alarm_Handler;


   procedure Test is
      PID :    pid_t;
      Secs :   uint_t;
      Error :  errno_t;
   begin
      Getpid(PID);

      Signal(SIGUSR1,User1_Handler'Access,Error);
      pragma Assert(Error = 0);

      Signal(SIGUSR2,User2_Handler'Access,Error);
      pragma Assert(Error = 0);
      
      Signal(SIGALRM,Alarm_Handler'Access,Error);
      pragma Assert(Error = 0);

      Secs := 1;
      Alarm(Secs);

      Kill(PID,SIGUSR1,Error);
      pragma Assert(Error = 0);

      Kill(PID,SIGUSR2,Error);
      pragma Assert(Error = 0);

      Kill(PID,SIGUSR1,Error);
      pragma Assert(Error = 0);

      pragma Assert(Sig_User1 = 2);
      pragma Assert(Sig_User2 = 1);

      loop
         exit when Alarm_Signaled;
         Pause(Error);
         pragma Assert(Error = 0 or Error = EINTR);
      end loop;

      pragma Assert(Alarm_Signaled);

   end Test;

end P0015;
