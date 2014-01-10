-- t0020.adb - Thu Jan  9 22:12:07 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- $Id$
--
-- Protected under the GNU GENERAL PUBLIC LICENSE v2, June 1991

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0020 is
   use Ada.Text_IO;    

   Path :      constant String := "Test_0020";
   S :         s_stat;
   Error :     errno_t;
begin

   Put_Line("Test 0020 - Mknod");

   pragma Warnings(Off);
   Unlink(Path,Error);           -- Ignore errors
   pragma Warnings(On);

   Mknod(Path,8#700# or S_IFIFO,0,Error);
   pragma Assert(Error = 0);

   Stat(Path,S,Error);
   pragma Assert(Error = 0);
   pragma Assert(S_ISFIFO(S.st_mode));
   pragma Assert((S.st_mode and S_IRWXU) = 8#700#);

   Unlink(Path,Error);
   pragma Assert(Error = 0);

   Put_Line("Test 0020 Passed.");

end T0020;
