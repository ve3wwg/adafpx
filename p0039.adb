-- p0039.adb - Thu Jan 16 07:58:55 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Posix, System;
use Posix;

package body P0039 is

   procedure Alarm_Handler(Sig : sig_t);
   pragma Convention(C,Alarm_Handler);

   Alarm_Count :     Natural := 0;
   pragma Volatile(Alarm_Count);

   procedure Alarm_Handler(Sig : sig_t) is
      Error : errno_t;
   begin
      pragma Assert(Error = 0);
      pragma Assert(Sig = SIGALRM);
      Alarm_Count := Alarm_Count + 1;
   end Alarm_Handler;

   procedure Test is
      Secs :      uint_t;
      Timer :     s_itimerval;
      Error :     errno_t;
      Sig_Act :   s_sigaction;
   begin

      Sig_Act.sa_handler := Alarm_Handler'Access;
      Sigemptyset(Sig_Act.sa_mask);
      Sig_Act.sa_flags := 0;

      Sigaction(SIGALRM,Sig_Act,Error);
      pragma Assert(Error = 0);

      Timer.it_value.tv_sec := 1;
      Timer.it_value.tv_usec := 1000;
      Timer.it_interval := Timer.it_value;

      Setitimer(ITIMER_REAL,Timer,Error);
      pragma Assert(Error = 0);

      loop
         Getitimer(ITIMER_REAL,Timer,Error);
         pragma Assert(Error = 0);
         exit when Alarm_Count = 2;
      end loop;

   end Test;

end P0039;
