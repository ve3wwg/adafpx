-- t0024.adb - Sat Jan 11 18:16:20 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0024 is
   use Ada.Text_IO;    

   Path :            constant String := "Makefile";
   Buffer :          String(1..MAXPATHLEN);
   Last :            Natural := 0;
   Fd :              fd_t := -1;
   Error :           errno_t;
   First :           Natural := 0;
begin

   Put_Line("Test 0024 - Fcntl(F_GETPATH)");

   Open(Path,O_RDONLY,Fd,Error);
   pragma Assert(Error = 0);
   pragma Assert(Fd >= 0);
   
   Fcntl(Fd,F_GETPATH,Buffer,Last,Error);
   pragma Assert(Error = 0);
   pragma Assert(Last > Buffer'First and Last <= Buffer'Last);
   pragma Assert(Buffer(Buffer'First) = '/');

   for X in reverse Buffer'Range loop
      if Buffer(X) = '/' then
         First := X + 1;
         exit;
      end if;
   end loop;

   pragma Assert(Buffer(First..Last) = Path);

   Put_Line("Test 0024 Passed.");

end T0024;
