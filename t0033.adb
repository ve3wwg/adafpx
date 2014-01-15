-- t0033.adb - Tue Jan 14 20:44:57 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0033 is
   use Ada.Text_IO;    

   Time_Date :    s_timeval;
   Time_Zone :    s_timezone;
   Error :        errno_t;
begin

   Put_Line("Test 0033 - Gettimeofday");

   Gettimeofday(Time_Date,Time_Zone,Error);
   pragma Assert(Error = 0);
   pragma Assert(Time_Date.tv_sec >= 1389750474);

   Put_Line("Time Zone," & int64_t'Image(int64_t(Time_Zone.tz_minuteswest))& " minutes west");
   if Time_Zone.tz_dsttime /= 0 then
      Put_Line("Is currently observing daylight savings time.");
   else
      Put_Line("Is NOT currently observing daylight savings time.");
   end if;

   Put_Line("Test 0033 Passed.");

end T0033;
