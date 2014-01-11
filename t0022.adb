-- t0022.adb - Thu Jan  9 22:41:28 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0022 is
   use Ada.Text_IO;    

   Path :            constant String := "Makefile";
   Fd, Fd2, Fd3 :    fd_t := -1;
   Error :           errno_t;
   Flags1, Flags2 :  uint_t := 0;
begin

   Put_Line("Test 0022 - Fcntl(F_GET/SETFD/F_GET/SETFL)");

   Open(Path,O_RDONLY,Fd,Error);
   pragma Assert(Error = 0);
   pragma Assert(Fd >= 0);
   
   Fd2 := Fd + 10;
   Fcntl(Fd,F_DUPFD,Fd2,Error);
   pragma Assert(Error = 0);

   Fd3 := Fd + 11;
   Fcntl(Fd,F_DUPFD_CLOEXEC,Fd3,Error);
   pragma Assert(Error = 0);

   -------------------------------------------------------------------
   -- Test F_SETFD/F_GETFD
   -------------------------------------------------------------------

   Fcntl(Fd2,F_GETFD,Flags1,Error);
   pragma Assert(Error = 0);
   pragma Assert((Flags1 and FD_CLOEXEC) = 0);

   Fcntl(Fd3,F_GETFD,Flags2,Error);
   pragma Assert(Error = 0);
   pragma Assert((Flags2 and FD_CLOEXEC) /= 0);

   Fcntl_Set(Fd3,F_SETFD,0,Error);
   pragma Assert(Error = 0);

   Flags2 := 16#FFFF#;
   Fcntl(Fd3,F_GETFD,Flags2,Error);
   pragma Assert(Error = 0);
   pragma Assert((Flags2 and FD_CLOEXEC) = 0);

   Fcntl_Set(Fd3,F_SETFD,FD_CLOEXEC,Error);
   pragma Assert(Error = 0);

   Flags2 := 16#FFFF#;
   Fcntl(Fd3,F_GETFD,Flags2,Error);
   pragma Assert(Error = 0);
   pragma Assert((Flags2 and FD_CLOEXEC) /= 0);

   -------------------------------------------------------------------
   -- Test F_SETFL/F_GETFL
   -------------------------------------------------------------------

   Fcntl(Fd3,F_GETFL,Flags2,Error);
   pragma Assert(Error = 0);
   pragma Assert((Flags2 and O_NONBLOCK) = 0);
   
   Fcntl_Set(Fd3,F_SETFL,O_NONBLOCK,Error);
   pragma Assert(Error = 0);

   Fcntl(Fd3,F_GETFL,Flags2,Error);
   pragma Assert(Error = 0);
   pragma Assert((Flags2 and O_NONBLOCK) /= 0);

   -------------------------------------------------------------------
   -- Close
   -------------------------------------------------------------------

   Close(Fd,Error);
   pragma Assert(Error = 0);

   Close(Fd2,Error);
   pragma Assert(Error = 0);

   Close(Fd3,Error);
   pragma Assert(Error = 0);

   Put_Line("Test 0022 Passed.");

end T0022;
