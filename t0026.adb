-- t0026.adb - Sat Jan 11 23:18:41 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0026 is
   use Ada.Text_IO;    

   Child :     pid_t := -1;
   Resource :  s_rusage;
   Status :    int_t := 0;
   Error :     errno_t;
   pragma Volatile(Error);
begin

   Put_Line("Test 0026 - Wait3");

   Fork(Child,Error);
   pragma Assert(Error = 0);

   if Child = 0 then
      -- Child fork
      for Count in Natural(0)..10000000 loop
         Error := 0;
      end loop;         

      Sys_Exit(42);
   end if;

   Wait3(Child,0,Status,Resource,Error);
   pragma Assert(Error = 0);
   pragma Assert(WIFEXITED(Status));
   pragma Assert(WEXITSTATUS(Status) = 42);
   pragma Assert(Resource.ru_utime.tv_usec > 0);
   pragma Assert(Resource.ru_stime.tv_usec > 0);

   Put_Line("Test 0026 Passed.");

end T0026;
