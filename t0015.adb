-- t0015.adb - Sat Jan  4 22:42:55 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;
with P0015;

procedure T0015 is
   use Ada.Text_IO;
begin

   Put_Line("Test 0015 - Signal/Alarm/Pause");
   P0015.Test;
   Put_Line("Test 0015 Passed.");

end T0015;
