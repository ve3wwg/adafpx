-- t0031.adb - Mon Jan 13 20:54:00 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0031 is
   use Ada.Text_IO;    

   RLimit :       s_rlimit;
   RLimit2 :      s_rlimit;
   Error :        errno_t;
begin

   Put_Line("Test 0031 - Getrlimit/Setrlimit");

   Getrlimit(RLIMIT_NOFILE,RLimit,Error);
   pragma Assert(Error = 0);
   pragma Assert(RLimit.rlim_cur <= RLimit.rlim_max);

   RLimit.rlim_cur := RLimit.rlim_cur - 1;      -- Reduction does not require root
   Setrlimit(RLIMIT_NOFILE,RLimit,Error);
   pragma Assert(Error = 0);

   Getrlimit(RLIMIT_NOFILE,RLimit2,Error);
   pragma Assert(Error = 0);
   pragma Assert(RLimit2.rlim_cur = RLimit.rlim_cur);

   Put_Line("Test 0031 Passed.");

end T0031;
