-- t0039.adb - Wed Jan 15 21:49:10 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0039 is
   use Ada.Text_IO;    

   Value :  s_itimerval;
   Error :  errno_t;
begin

   Put_Line("Test 0039 - Getitimer");

   Getitimer(ITIMER_REAL,Value,Error);
   pragma Assert(Error = 0);

   Put_Line("Test 0039 Passed.");

end T0039;
