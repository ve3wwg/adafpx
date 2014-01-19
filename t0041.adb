-- t0041.adb - Sat Jan 18 18:43:54 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- $Id$
--
-- Protected under the GNU GENERAL PUBLIC LICENSE v2, June 1991

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0041 is
   use Ada.Text_IO;    

   Info :   s_sysinfo;
   Error :  errno_t;
begin

   Put_Line("Test 0041 - Sysinfo");

   Sysinfo(Info,Error);
   pragma Assert(Error = 0);

   Put_Line("uptime: " & int64_t'Image(Info.uptime));
   Put_Line("Loads: "
      & uint64_t'Image(Info.loads(0)) & ", "
      & uint64_t'Image(Info.loads(1)) & ", "
      & uint64_t'Image(Info.loads(2))
   );
   Put_Line("totalram:  " & uint64_t'Image(Info.totalram) & " bytes");
   Put_Line("freeram:   " & uint64_t'Image(Info.freeram) & " bytes");
   Put_Line("sharedram: " & uint64_t'Image(Info.sharedram) & " bytes");
   Put_Line("bufferram: " & uint64_t'Image(Info.bufferram) & " bytes");
   Put_Line("totalswap: " & uint64_t'Image(Info.totalswap) & " bytes");
   Put_Line("freeswap:  " &  uint64_t'Image(Info.freeswap) & " bytes");
   Put_Line("procs:     " & uint16_t'Image(Info.procs));
   Put_Line("totalhigh: " & uint64_t'Image(Info.totalhigh) & " bytes");
   Put_Line("freehigh:  " & uint64_t'Image(Info.freehigh)  & " bytes");
   Put_Line("mem_unit:  " & uint32_t'Image(Info.mem_unit) & " bytes");

   Put_Line("Test 0041 Passed.");

end T0041;
