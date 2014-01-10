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

   Path :         constant String := "Makefile";
   Fd, Fd2, Fd3 : fd_t := -1;
   Error :        errno_t;
begin

   Put_Line("Test 0022 - Fcntl(F_DUPFD/F_DUPFD_CLOEXEC)");

   Open(Path,O_RDONLY,Fd,Error);
   pragma Assert(Error = 0);
   pragma Assert(Fd >= 0);
   
   Fcntl(Fd,F_DUPFD,Fd2,Error);
   pragma Assert(Error = 0);
   pragma Assert(Fd2 > Fd);

   Fcntl(Fd,F_DUPFD_CLOEXEC,Fd3,Error);
   pragma Assert(Error = 0);
   pragma Assert(Fd3 > Fd2);

   Close(Fd,Error);
   pragma Assert(Error = 0);

   Close(Fd2,Error);
   pragma Assert(Error = 0);

   Close(Fd3,Error);
   pragma Assert(Error = 0);

   Put_Line("Test 0022 Passed.");

end T0022;
