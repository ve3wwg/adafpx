-- t0035.adb - Tue Jan 14 21:39:20 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0035 is
   use Ada.Text_IO;    

   Path1 :        String := "Makefile";
   Path2 :        String := ".";
   D :            DIR;
   Error :        errno_t;
begin

   Put_Line("Test 0035 - Dir functions");

   Opendir(Path1,D,Error);
   

   Put_Line("Test 0035 Passed.");

end T0035;
