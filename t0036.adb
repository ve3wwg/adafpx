-- t0036.adb - Wed Jan 15 20:34:25 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;
with System;

with Posix;
use Posix;

procedure T0036 is
   use Ada.Text_IO;    

   Path1 :     constant String := "Makefile";
   Fd :        fd_t := -1;
   Page_Size : long_t := -1;
   Addr :      System.Address := System.Null_Address;
   Error :     errno_t;
begin

   Put_Line("Test 0036 - Mmap/Munmap");

   Sysconf(SC_PAGESIZE,Page_Size,Error);
   pragma Assert(Error = 0);
   pragma Assert(Page_Size >= 1024);

   Open(Path1,O_RDONLY,Fd,Error);
   pragma Assert(Error = 0);
   pragma Assert(Fd >= 0);
   
   MMap(Addr,size_t(Page_Size),PROT_READ,MAP_FILE or MAP_PRIVATE,Fd,0,Error);
   pragma Assert(Error = 0);

   declare
      Buf :    uchar_array(1..Natural(Page_Size));
      Last :   Natural := 0;
   begin
      Read(Fd,Buf,Last,Error);
      pragma Assert(Error = 0);
      pragma Assert(Last > 0);

      if Last > Natural(Page_Size) then
         Last := Natural(Page_Size);
      end if;

      declare
         Mapped : uchar_array(1..Last);
         for Mapped'Address use Addr;
      begin
         pragma Assert(Mapped = Buf(1..Last));
         null;
      end;
   end;

   MUnmap(Addr,size_t(Page_Size),Error);
   pragma Assert(Error = 0);

   Put_Line("Test 0036 Passed.");

end T0036;
