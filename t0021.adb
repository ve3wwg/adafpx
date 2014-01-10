-- t0021.adb - Thu Jan  9 22:31:52 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the GNU GENERAL PUBLIC LICENSE v2, June 1991

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0021 is
   use Ada.Text_IO;    

   Path :      constant String := "Test_0021";
   S :         s_stat;
   Error :     errno_t;
   OMask :     mode_t;
begin

   Put_Line("Test 0021 - Mkfifo");

   pragma Warnings(Off);
   Unlink(Path,Error);           -- Ignore errors
   pragma Warnings(On);

   UMask(8#100#,OMask,Error);
   pragma Assert(Error = 0);
   
   Mkfifo(Path,8#700#,Error);
   pragma Assert(Error = 0);

   Stat(Path,S,Error);
   pragma Assert(Error = 0);
   pragma Assert(S_ISFIFO(S.st_mode));
   pragma Assert((S.st_mode and S_IRWXU) = 8#600#);

   Unlink(Path,Error);
   pragma Assert(Error = 0);

   UMask(OMask,OMask,Error);
   pragma Assert(Error = 0);
   pragma Assert(OMask = 8#100#);

   Put_Line("Test 0021 Passed.");

end T0021;
