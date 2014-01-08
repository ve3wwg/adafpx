-- t0008.adb - Sat Jan  4 10:20:17 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0008 is
   use Ada.Text_IO;

   Parent : pid_t := -1;
   Child :  pid_t := -1;
   P_PID :  pid_t := -1;
   Error :  errno_t;
begin

   Put_Line("Test 0008 - Fork/Wait_Pid/Getpid/Getppid/Kill");

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
      Kill(Child,SIGINT,Error);
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

         Wait_Pid(Child,0,Status,Error);
         pragma Assert(Error = 0);
         pragma Assert(WIFSIGNALED(Status));

         Sig := WTERMSIG(Status);
         pragma Assert(Sig = SIGINT);

         Put_Line("Parent: My child process has been signaled with SIGINT");
      end;

   end if;

   Put_Line("Test 0008 Passed.");

end T0008;

