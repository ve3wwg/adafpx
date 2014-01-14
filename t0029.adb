-- t0029.adb - Mon Jan 13 19:56:37 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;
with P0029;

procedure T0029 is
   use Ada.Text_IO;
begin

   Put_Line("Test 0029 - Sigsuspend/Sigprocmask");
   P0029.Test;
   Put_Line("Test 0029 Passed.");

end T0029;
