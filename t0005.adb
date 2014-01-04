-- t0005.adb - Fri Jan  3 23:28:34 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999
with Ada.Text_IO;

with Posix;
use Posix;

procedure T0005 is
   use Ada.Text_IO;
begin

   Put_Line("T0005 will exit with code 0");
   Sys_Exit2(0);
   Put_Line("*** T0005 Failed if you see this ***");

end T0005;
