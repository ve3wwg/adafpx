-- t0040.adb - Fri Jan 17 20:36:08 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0040 is
   use Ada.Text_IO;    

   Names :  s_utsname;
   Error :  errno_t;
begin

   Put_Line("Test 0040 - Uname");

   UName(Names,Error);
   pragma Assert(Error = 0);

   Put_Line("Sysname:  '" & Ada_String(Names.sysname) & "'");
   Put_Line("Nodename: '" & Ada_String(Names.Nodename) & "'");
   Put_Line("Release:  '" & Ada_String(Names.Release) & "'");
   Put_Line("Version:  '" & Ada_String(Names.Version) & "'");
   Put_Line("Machine:  '" & Ada_String(Names.Machine) & "'");

   Put_Line("Test 0040 Passed.");

end T0040;
