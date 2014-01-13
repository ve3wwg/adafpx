-- t0027.adb - Sun Jan 12 20:35:55 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0027 is
   use Ada.Text_IO;    

   PID :       constant pid_t := Getpid;
   SID :       pid_t := -1;
   SID2 :      pid_t := -1;
   Error :     errno_t;
begin

   Put_Line("Test 0027 - Setuid/Setgid/Seteuid/Setegid/Setsid");

   Getsid(PID,SID,Error);
   pragma Assert(Error = 0);
   pragma Assert(SID /= PID);
   
   SID2 := Setsid;
   pragma Assert(SID2 = PID);

   Setuid(0,Error);
   if Error = 0 then
      pragma Assert(Getuid = 0);

      Setgid(1,Error);
      pragma Assert(Error = 0);
      pragma Assert(Getgid = 1);

      Seteuid(0,Error);
      pragma Assert(Error = 0);
      pragma Assert(Geteuid = 0);

      Setegid(2,Error);
      pragma Assert(Error = 0);
      pragma Assert(Getegid = 2);
   else
      pragma Assert(Error = EPERM);
      Put_Line("Run test as root to confirm Setuid/Setgid/Seteuid/Setegid.");
      Put_Line("Setsid/Getsid passed however.");
   end if;

   Put_Line("Test 0027 Passed.");

end T0027;
