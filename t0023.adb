-- t0023.adb - Sat Jan 11 16:58:34 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0023 is
   use Ada.Text_IO;    

   Path :            constant String := "Test_0023";
   Fd :              fd_t := -1;
   S :               s_flock;
   PID :             constant pid_t := Getpid;
   Child :           pid_t := -1;
   Count :           Natural := 0;
   Error :           errno_t;
begin

   Put_Line("Test 0023 - Fcntl(F_GET/SETFD/F_GET/SETFL)");

   pragma Warnings(Off);
   Unlink(Path,Error);     -- Ignore error
   pragma Warnings(On);

   Create(Path,8#660#,Fd,Error);
   pragma Assert(Error = 0);
   pragma Assert(Fd >= 0);
   
   Write(Fd,To_uchar_array(Path),Count,Error);
   pragma Assert(Error = 0);
   pragma Assert(Count = Path'Length);

   S.l_type := F_WRLCK;
   S.l_whence := 0;
   S.l_start := 0;
   S.l_len := 0;     

   Fcntl(Fd,F_GETLK,S,Error);
   pragma Assert(Error = 0);
   pragma Assert(S.l_type = F_UNLCK);

   Fork(Child,Error);
   pragma Assert(Error = 0);

   if Child = 0 then
      -- Child process

      S.l_type := F_WRLCK;                -- Read lock
      S.l_start := 1;                     -- Starting at 1
      S.l_len := 0;                       -- To end file
      S.l_whence := short_t(SEEK_SET);    -- Use absolute offsets
      S.l_pid := Getpid;

      Fcntl(Fd,F_SETLK,S,Error);
      pragma Assert(Error = 0);

      loop
         Kill(PID,0,Error);
         exit when Error = ESRCH;
         delay 1.0;
      end loop;

      Close(Fd,Error);
      pragma Assert(Error = 0);

      Sys_Exit(0);
   end if;

   -------------------------------------------------------------------
   -- Parent process
   -------------------------------------------------------------------

   delay 2.0;

   S.l_type := F_WRLCK;                -- Read lock
   S.l_start := 0;
   S.l_len := 0;                       -- To end file
   S.l_whence := short_t(SEEK_SET);    -- Use absolute offsets
   S.l_pid := 0;

   Fcntl(Fd,F_GETLK,S,Error);
   pragma Assert(Error = 0);
   pragma Assert(S.l_type = F_WRLCK);
   pragma Assert(S.l_start = 1);
   pragma Assert(S.l_len = 0);
   pragma Assert(S.l_whence = short_t(SEEK_SET));
   pragma Assert(S.l_pid = Child);

   Close(Fd,Error);
   pragma Assert(Error = 0);

   Unlink(Path,Error);
   pragma Assert(Error = 0);

   Put_Line("Test 0023 Passed.");

end T0023;
