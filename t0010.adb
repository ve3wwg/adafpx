-- t0010.adb - Sat Jan  4 10:48:31 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0010 is
   use Ada.Text_IO;    

   Path1 :        constant String := "Makefile";
   Path2 :        constant String := ".Test_0010";
   Error :        errno_t;
begin

   Put_Line("Test 0010 - Readlink/Symlink");

   -------------------------------------------------------------------
   -- Symlink Makefile to .Test_0010
   -------------------------------------------------------------------

   Unlink(Path2,Error);             -- Ignore errors here

   Symlink(Path1,Path2,Error);      -- ln -s Makefile .Test_0010
   pragma Assert(Error = 0);

   -------------------------------------------------------------------
   -- Read the link for Test_0010
   -------------------------------------------------------------------

   declare
      Buffer : String(1..MAXPATHLEN);
      Last :   Natural := 0;
   begin
      Readlink(Path2,Buffer,Last,Error);
      pragma Assert(Error = 0);
      Put_Line("Read Link Info '" & Buffer(1..Last) & "'");
      pragma Assert(Buffer(1..Last) = "Makefile");
   end;

   Unlink(Path2,Error);
   pragma Assert(Error = 0);

   Put_Line("Test 0010 Passed.");

end T0010;
