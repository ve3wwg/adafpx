-- t0030.adb - Mon Jan 13 20:45:39 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0030 is
   use Ada.Text_IO;    

   Host_Name :    String(1..MAXPATHLEN);
   Last :         Natural;
   Error :        errno_t;
begin

   Put_Line("Test 0030 - Gethostname");

   Gethostname(Host_Name,Last,Error);
   pragma Assert(Error = 0);
   pragma Assert(Last > Host_Name'First);

   Put_Line("Host name is '" & Host_Name(1..Last) & "'");

   Put_Line("Test 0030 appears to have passed.");

end T0030;
