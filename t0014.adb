-- t0014.adb - Sat Jan  4 17:04:59 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0014 is
   use Ada.Text_IO;    

   Child :     pid_t := -1;
   Tms :       s_tms;
   Ticks :     clock_t := 0;
   Status :    int_t := 0;
   Error :     errno_t;
   pragma Volatile(Error);
begin

   Put_Line("Test 0014 - Times");

   Fork(Child,Error);
   pragma Assert(Error = 0);

   if Child = 0 then
      -- Child fork
      for Count in Natural(0)..10000000 loop
         Error := 0;
      end loop;         

      Sys_Exit(42);
   end if;

   -- Parent fork
   for Count in Natural(0)..30000000 loop
      Error := 0;
   end loop;

   Wait_Pid(Child,0,Status,Error);
   pragma Assert(Error = 0);
   pragma Assert(WIFEXITED(Status));
   pragma Assert(WEXITSTATUS(Status) = 42);

   Times(Tms,Ticks,Error);
   pragma Assert(Error = 0);

   Put_Line("Ticks =" & clock_t'Image(Ticks));
   Put_Line("Child: User:" & clock_t'Image(Tms.tms_cutime)
      & ", System:" & clock_t'Image(Tms.tms_cstime)
      & " ticks");

   Put_Line("Parent: User:" & clock_t'Image(Tms.tms_utime)
      & ", System:" & clock_t'Image(Tms.tms_stime)
      & " ticks");

   Put_Line("Test 0014 Passed.");

end T0014;
