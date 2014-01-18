-- t0039.adb - Wed Jan 15 21:49:10 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO, P0039;

procedure T0039 is
   use Ada.Text_IO;    
begin

   Put_Line("Test 0039 - Getitimer");

   P0039.Test;

   Put_Line("Test 0039 Passed.");

end T0039;
