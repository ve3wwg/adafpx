-- t0006.adb - Fri Jan  3 23:37:11 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0006 is
   use Ada.Text_IO;

   Parent : pid_t := -1;
   Child :  pid_t := -1;
   P_PID :  pid_t := -1;
   Error :  errno_t;
begin

   Put_Line("Test 0006 - Fork/Wait/Getpid/Getppid");

   Parent := Getpid;

   Put_Line("Parent: My PID is " & pid_t'Image(Parent));

   Fork(Child,Error);

   pragma Assert(Error = 0);
   
   if Child = 0 then
      ----------------------------------------------------------------
      -- This is the child process running
      ----------------------------------------------------------------
      Child := Getpid;
      P_PID := Getppid;
      Put_Line("Child: My PID is " & pid_t'Image(Child) & " and my Parent is " & pid_t'Image(P_PID));
      pragma Assert(P_PID = Parent);
      Sys_Exit(1);
   else
      ----------------------------------------------------------------
      -- This is the parent process running
      ----------------------------------------------------------------
      Put_Line("Parent: My child PID is " & pid_t'Image(Child));

      declare
         Status : int_t := -1;
         Exit_Code : int_t := -1;
      begin
         Wait(Status,Error);
         pragma Assert(Error = 0);
         pragma Assert(WIFEXITED(Status));

         Exit_Code := WEXITSTATUS(Status);
         Put_Line("Parent: My child process has exited with code =" & int_t'Image(Exit_Code));
         pragma Assert(Exit_Code = 1);
      end;

   end if;

   Put_Line("Test 0006 Passed.");

end T0006;

