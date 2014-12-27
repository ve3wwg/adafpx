-- t0019.adb - Tue Jan  7 21:02:47 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0019 is
   use Ada.Text_IO;    

   Path0 :     constant String := "Makefile";
   Path :      constant String := "Test_0019";
   My_Uid :    constant uid_t := Geteuid;
   S :         s_stat;
   Error :     errno_t;
   Confirms :  Natural := 0;
begin

   Put_Line("Test 0019 - LChown/LStat");

   pragma Warnings(Off);
   Unlink(Path,Error);           -- Ignore errors
   pragma Warnings(On);

   Symlink(Path0,Path,Error);
   pragma Assert(Error = 0);

   LStat(Path,S,Error);
   pragma Assert(Error = 0);
   pragma Assert(S.st_uid = My_Uid);

   LChown(Path,1,2,Error);
   if Error = 0 then
      LStat(Path,S,Error);
      pragma Assert(Error = 0);
      pragma Assert(S.st_uid = 1);
      pragma Assert(S.st_gid = 2);
      Confirms := Confirms + 1;
   else
      pragma Assert(Error = EPERM);
      null;
   end if;   

   Unlink(Path,Error);
   pragma Assert(Error = 0);

   Put("Test 0019 Passed");

   if Confirms = 1 then
      Put_Line(" and confirmed.");
   else
      Put_Line(" but must run as root to confirm.");
   end if;

end T0019;
