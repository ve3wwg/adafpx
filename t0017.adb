-- t0017.adb - Tue Jan  7 19:31:46 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0017 is
   use Ada.Text_IO;    

   Path :      constant String := "Test_0017";
   Fd :        fd_t;
   Old_Mask :  mode_t;
   S :         s_stat;
   Error :     errno_t;
begin

   Put_Line("Test 0017 - Chmod/FChmod");

   pragma Warnings(Off);
   Unlink(Path,Error);           -- Ignore errors
   pragma Warnings(On);

   UMask(8#111#,Old_Mask,Error);
   pragma Assert(Error = 0);

   Create(Path,8#777#,Fd,Error);
   pragma Assert(Error = 0);
   pragma Assert(Fd >= 0);

   Stat(Path,S,Error);
   pragma Assert(Error = 0);
   pragma Assert((S.st_mode and 8#777#) = 8#666#);

   Chmod(Path,8#440#,Error);
   pragma Assert(Error = 0);
   
   Stat(Path,S,Error);
   pragma Assert(Error = 0);
   pragma Assert((S.st_mode and 8#777#) = 8#440#);

   FChmod(Fd,8#600#,Error);
   pragma Assert(Error = 0);

   Stat(Path,S,Error);
   pragma Assert(Error = 0);
   pragma Assert((S.st_mode and 8#777#) = 8#600#);

   UMask(Old_Mask,Old_Mask,Error);
   pragma Assert(Error = 0);
   pragma Assert(Old_Mask = 8#111#);

   Close(Fd,Error);
   pragma Assert(Error = 0);

   Unlink(Path,Error);
   pragma Assert(Error = 0);

   Put_Line("Test 0017 Passed.");

end T0017;
