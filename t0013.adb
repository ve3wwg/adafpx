-- t0013.adb - Sat Jan  4 17:04:59 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0013 is
   use Ada.Text_IO;    

   Test_Pat :  constant String := "ABC012";
   RFd, WFd :  fd_t := -1;
   Count :     Natural;
   Error :     errno_t;
begin

   Put_Line("Test 0013 - Pipe");

   Pipe2(0,RFd,WFd,Error);
   pragma Assert(Error = 0);
   pragma Assert(RFd >= 0);
   pragma Assert(WFd >= 0);

   Write(WFd,To_uchar_array(Test_Pat),Count,Error);
   pragma Assert(Error = 0);
   pragma Assert(Count = Test_Pat'Length);

   declare
      Buf :    uchar_array(Test_Pat'Range);
      Last :   Natural := 0;
   begin
      Read(RFd,Buf,Last,Error);
      pragma Assert(Error = 0);
      pragma Assert(Last = Buf'Last);
      pragma Assert(To_String(Buf) = Test_Pat);
   end;

   Close(RFd,Error);
   pragma Assert(Error = 0);

   Close(WFd,Error);
   pragma Assert(Error = 0);

   Put_Line("Test 0013 Passed.");

end T0013;
