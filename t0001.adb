with Ada.Text_IO;

with Posix;
use Posix;

procedure T0001 is
   use Ada.Text_IO;    

   Path1 :  constant String := "This_File_Does_Not_Exist";
   Path2 :  constant String := "Makefile";
   Fd :     fd_t := 0;
   Error :  errno_t;
begin

   Put_Line("Test 0001");
   Put_Line("Testing open of non-existant file " & Path1);

   Open(Path1,O_RDONLY,Fd,Error);
   pragma Assert(Fd = -1);
   pragma Assert(Error = ENOENT);

   declare
      Error_Message : constant String := Strerror(Error);
   begin
      Put("Got: " & Error_Message & ": path " & Path1);
      pragma Assert(Error_Message = "No such file or directory");
      Put_Line(" as expected.");
   end;

   Open(Path2,O_RDONLY,Fd,Error);
   pragma Assert(Fd >= 0);
   pragma Assert(Error = 0);

   Close(Fd,Error);
   pragma Assert(Error = 0);

   Put_Line("Test 0001 Passed.");

end T0001;
