-- t0025.adb - Sat Jan 11 22:40:20 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0025 is
   use Ada.Text_IO;    

   Path :            constant String := "Test_0025";
   Fd :              fd_t := -1;
   Str1 :            constant String := "[String One]";
   Str2 :            constant String := "[String Two]";
   Str3 :            constant String := "[String Three]";
   Write_Iov :       constant s_iovec_array(1..3) := (
         ( iov_base => Str1'Address, iov_len => Str1'Length ),
         ( iov_base => Str2'Address, iov_len => Str2'Length ),
         ( iov_base => Str3'Address, iov_len => Str3'Length )
      );   
   Buf1 :            String(Str1'Range);
   Buf2 :            String(Str2'Range);
   Buf3 :            String(Str3'Range);
   Read_Iov :        constant s_iovec_array(1..3) := (
         ( iov_base => Buf1'Address, iov_len => Buf1'Length ),
         ( iov_base => Buf2'Address, iov_len => Buf2'Length ),
         ( iov_base => Buf3'Address, iov_len => Buf3'Length )
      );
   Count :           Natural := 0;
   Error :           errno_t;
begin

   Put_Line("Test 0025 - Readv/Writev");

   pragma Warnings(Off);
   Unlink(Path,Error);     -- Ignore Error
   pragma Warnings(On);

   Create(Path,8#666#,Fd,Error);
   pragma Assert(Error = 0);
   pragma Assert(Fd >= 0);
   
   Writev(Fd,Write_Iov,Count,Error);   
   pragma Assert(Error = 0);
   pragma Assert(Count = Str1'Length + Str2'Length + Str3'Length);

   Close(Fd,Error);
   pragma Assert(Error = 0);

   Open(Path,O_RDONLY,Fd,Error);
   pragma Assert(Error = 0);
   pragma Assert(Fd >= 0);

   Readv(Fd,Read_Iov,Count,Error);
   pragma Assert(Error = 0);
   pragma Assert(Count = Str1'Length + Str2'Length + Str3'Length);
   pragma Assert(Buf1 = Str1);
   pragma Assert(Buf2 = Str2);
   pragma Assert(Buf3 = Str3);

   Close(Fd,Error);
   pragma Assert(Error = 0);

   Unlink(Path,Error);     -- Ignore Error
   pragma Assert(Error = 0);

   Put_Line("Test 0025 Passed.");

end T0025;
