-- t0018.adb - Tue Jan  7 20:05:48 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0018 is
   use Ada.Text_IO;    

   Path :      constant String := "Test_0018";
   My_Uid :    constant uid_t := Geteuid;
   My_Gid :    constant gid_t := Getegid;
   Fd :        fd_t;
   S :         s_stat;
   Error :     errno_t;
   Confirms :  Natural := 0;
begin

   Put_Line("Test 0018 - Chown/FChown");

   pragma Warnings(Off);
   Unlink(Path,Error);           -- Ignore errors
   pragma Warnings(On);

   Create(Path,8#777#,Fd,Error);
   pragma Assert(Error = 0);
   pragma Assert(Fd >= 0);

   Close(Fd,Error);
   pragma Assert(Error = 0);

   Stat(Path,S,Error);
   pragma Assert(Error = 0);
   pragma Assert(S.st_uid = My_Uid);
   pragma Assert(S.st_gid = My_Gid);

   Chown(Path,1,2,Error);
   if Error = 0 then
      Stat(Path,S,Error);
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

   Create(Path,8#777#,Fd,Error);
   pragma Assert(Error = 0);
   pragma Assert(Fd >= 0);

   FChown(Fd,2,3,Error);

   if Error = 0 then
      Stat(Path,S,Error);
      pragma Assert(Error = 0);
      pragma Assert(S.st_uid = 2);
      pragma Assert(S.st_gid = 3);
      Confirms := Confirms + 1;
   else
      pragma Assert(Error = EPERM);
      null;
   end if;

   Close(Fd,Error);
   pragma Assert(Error = 0);

   Unlink(Path,Error);
   pragma Assert(Error = 0);
   
   Put("Test 0018 Passed");

   if Confirms = 2 then
      Put_Line(" and confirmed.");
   else
      Put_Line(" but must run as root to confirm.");
   end if;

end T0018;
