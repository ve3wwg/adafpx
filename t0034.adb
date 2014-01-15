-- t0034.adb - Tue Jan 14 21:24:17 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0034 is
   use Ada.Text_IO;    

   Groups :          gid_array(1..32) := ( 0, others => 0 );
   Groups2 :         gid_array(1..32) := ( 1, others => 1 );
   Count, Count2 :   Natural := 0;
   Error :           errno_t;
   Verified :        Boolean := false;
begin

   Put_Line("Test 0034 - Getgroups/Setgroups");

   Getgroups(Groups,Count,Error);
   pragma Assert(Error = 0);
   pragma Assert(Count > 0);

   if Count > 1 then
      Count := Count - 1;
   end if;
   Setgroups(Groups(1..Count),Error);
   if Error = EPERM then
      Put_Line("Run as root to verify Setgroups.");
   else
      Getgroups(Groups2,Count2,Error);
      pragma Assert(Error = 0);
      pragma Assert(Count2 > 0);
      pragma Assert(Count2 = Count);
      pragma Assert(Groups2(1..Count2) = Groups(1..Count));
      Verified := true;
   end if;

   if Verified then
      Put_Line("Test 0034 Passed (including Setgroups).");
   else
      Put_Line("Test 0034 Passed (Getgroups only).");
   end if;

end T0034;
