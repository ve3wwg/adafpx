-- t0046.adb - Sat Jan 25 22:31:52 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- $Id$
--
-- Protected under the GNU GENERAL PUBLIC LICENSE v2, June 1991

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0046 is
   use Ada.Text_IO;

   Remain :    uint_t := uint_t'Last;
   T1, T2 :    s_timespec;
   Error :     errno_t;
begin

   Put_Line("Test 0046 - Sleep/Nanosleep");

   Sleep(1);
   Put_Line("Sleep(1) ok.");

   Sleep(1,Remain);
   pragma Assert(Remain <= 1);
   Put_Line("Sleep(1,Remain) ok.");
   
   T1.tv_sec := 1;   
   T1.tv_nsec := 5000;

   T2.tv_sec := time_t'Last;
   T2.tv_nsec := 0;

   Nanosleep(T1,T2,Error);
   pragma Assert(Error = 0);
   pragma Assert(T2.tv_sec = time_t'Last);   -- Only is returned when Error = EINTR
   pragma Assert(T2.tv_nsec = 0);            -- Ditto
   Put_Line("Nanosleep(T1,T2) ok.");

   Put_Line("Test 0046 Passed.");

end T0046;
