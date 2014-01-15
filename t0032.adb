-- t0032.adb - Tue Jan 14 20:20:46 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0032 is
   use Ada.Text_IO;    

   Res :          s_rusage;
   Error :        errno_t;
   pragma Volatile(Error);
begin

   Put_Line("Test 0032 - Getrlimit/Setrlimit");

   Error := 0;

   for X in 0..999999 loop
      if Error < 32000 then
         Error := Error + 1;
      else
         Error := 0;
      end if;
   end loop;

   Getrusage(RUSAGE_SELF,Res,Error);
   pragma Assert(Error = 0);
   pragma Assert(Res.ru_utime.tv_sec >= 0);
   pragma Assert(Res.ru_utime.tv_usec > 0 or else Res.ru_utime.tv_sec > 0);

   Put_Line("Test 0032 Passed.");

end T0032;
