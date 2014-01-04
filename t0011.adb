-- t0011.adb - Sat Jan  4 11:30:24 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0011 is
   use Ada.Text_IO;    

   Subdir :    constant String := "Test_0011";
   Cwd1 :      String(1..MAXPATHLEN+1);
   Last1 :     Natural;
   Fd :        fd_t := -1;
   Error :     errno_t;
begin

   Put_Line("Test 0011 - Getcwd/Getwd/Chdir/FChdir/Mkdir/Rmdir");

   -------------------------------------------------------------------
   -- Determine current working directory
   -------------------------------------------------------------------

   Getcwd(Cwd1,Last1,Error);
   pragma Assert(Error = 0);
   pragma Assert(Last1 > 0);

   Put_Line("Cwd1 is '" & Cwd1(1..Last1) & "'");

   declare
      Cwd2 : constant String := Getwd;
   begin
      pragma Assert(Cwd2 = Cwd1(1..Last1));
      Put_Line("Cwd2 is '" & Cwd1(1..Last1) & "'");
   end;

   -------------------------------------------------------------------
   -- Make a test directory
   -------------------------------------------------------------------

   pragma Warnings(Off);
   Rmdir(Subdir,Error);       -- Ignore errors here
   pragma Warnings(On);

   Mkdir(Subdir,8#750#,Error);
   pragma Assert(Error = 0);

   -------------------------------------------------------------------
   -- Change to the test subdirectory
   -------------------------------------------------------------------

   Open(Subdir,O_RDONLY,Fd,Error);
   pragma Assert(Error = 0);

   Chdir(Subdir,Error);
   pragma Assert(Error = 0);
   
   declare
      Cwd2 : constant String := Getwd;
   begin
      Put_Line("Chdir to '" & Cwd2 & "'");
      pragma Assert(Cwd2 /= Cwd1(1..Last1));
   end;
   
   Chdir(Cwd1(1..Last1),Error);
   pragma Assert(Error = 0);
   pragma Assert(Getwd = Cwd1(1..Last1));

   -------------------------------------------------------------------
   -- Now test FChdir
   -------------------------------------------------------------------

   FChdir(Fd,Error);
   pragma Assert(Error = 0);
   pragma Assert(Getwd /= Cwd1(1..Last1));

   declare
      Cwd2 : constant String := Getwd;
   begin
      Put_Line("FChdir to '" & Cwd2 & "'");
      pragma Assert(Cwd2 /= Cwd1(1..Last1));
   end;

   Chdir(Cwd1(1..Last1),Error);
   pragma Assert(Error = 0);
   pragma Assert(Getwd = Cwd1(1..Last1));

   -------------------------------------------------------------------
   -- Now remove the test subdirectory
   -------------------------------------------------------------------

   Rmdir(Subdir,Error);
   pragma Assert(Error = 0);

   Put_Line("Test 0011 Passed.");

end T0011;
