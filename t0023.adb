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

   Path :            constant String := "Makefile";
   Fd :              fd_t := -1;
   S :               s_flock;
   Error :           errno_t;
   -- <case name="F_GETLK"/>
   -- <case name="F_SETLK"/>
   -- <case name="F_SETLKW"/>
begin

   Put_Line("Test 0023 - Fcntl(F_GET/SETFD/F_GET/SETFL)");

   Open(Path,O_RDONLY,Fd,Error);
   pragma Assert(Error = 0);
   pragma Assert(Fd >= 0);
   
   Fcntl(Fd,F_GETLK,S,Error);
   pragma Assert(Error = 0);
   pragma Assert(S.l_type = F_UNLCK);

   S.l_type := F_WRLCK;                -- Write lock
   S.l_start := 1;                     -- Starting at 1
   S.l_len := 0;                       -- To end file
   S.l_whence := short_t(SEEK_SET);    -- Use absolute offsets

   Fcntl(Fd,F_SETLK,S,Error);
   pragma Assert(Error = 0);

   S.l_type := F_UNLCK;
   S.l_start := 0;
   S.l_len := 99;

   Fcntl(Fd,F_GETLK,S,Error);
   pragma Assert(Error = 0);
   pragma Assert(S.l_type = F_WRLCK);

   Close(Fd,Error);
   pragma Assert(Error = 0);

   Put_Line("Test 0023 Passed.");

end T0023;
