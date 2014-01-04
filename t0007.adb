-- t0007.adb - Fri Jan  3 23:37:11 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0007 is
   use Ada.Text_IO;

   Parent : pid_t := -1;
   Child :  pid_t := -1;
   P_PID :  pid_t := -1;
   Error :  errno_t;
begin

   Put_Line("Test 0007 - Fork/Wait/Getpid/Getppid/Kill");

   Getpid(Parent);

   Put_Line("Parent: My PID is " & pid_t'Image(Parent));

   Fork(Child,Error);

   pragma Assert(Error = 0);
   
   if Child = 0 then
      ----------------------------------------------------------------
      -- This is the child process running
      ----------------------------------------------------------------
      Getpid(Child);
      Getppid(P_PID);
      Put_Line("Child: My PID is " & pid_t'Image(Child) & " and my Parent is " & pid_t'Image(P_PID));
      pragma Assert(P_PID = Parent);
      Kill(Child,SIGTERM,Error);
      pragma Assert(Error = 0);
      loop
         P_PID := Child;   -- Loop until terminated
      end loop;
   else
      ----------------------------------------------------------------
      -- This is the parent process running
      ----------------------------------------------------------------
      Put_Line("Parent: My child PID is " & pid_t'Image(Child));

      declare
         Status : int_t := -1;
         Sig :    sig_t := -1;
      begin
         Wait(Status,Error);
         pragma Assert(Error = 0);
         pragma Assert(WIFSIGNALED(Status) = True);

         Sig := WTERMSIG(Status);
         pragma Assert(Sig = SIGTERM);

         Put_Line("Parent: My child process has been signaled with SIGTERM");
      end;

   end if;

   Put_Line("Test 0007 Passed.");

end T0007;

