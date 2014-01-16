-- t0037.adb - Wed Jan 15 21:18:01 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0037 is
   use Ada.Text_IO;    

   Priority :  int_t := -1;
   Priority2 : int_t := -1;
   Error :     errno_t;
begin

   Put_Line("Test 0037 - Getpriority/Setpriority");

   Getpriority(PRIO_PROCESS,id_t(Getpid),Priority,Error);
   pragma Assert(Error = 0);

   Setpriority(PRIO_PROCESS,0,Priority+1,Error);
   pragma Assert(Error = 0);

   Getpriority(PRIO_PROCESS,0,Priority2,Error);
   pragma Assert(Error = 0);
   pragma Assert(Priority2 = Priority + 1);

   Put_Line("Test 0037 Passed.");

end T0037;
