-- t0001.adb - Wed Jan  1 09:21:23 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0001 is
   use Ada.Text_IO;    

   Path1 :  constant String := "This_File_Does_Not_Exist";
   Path2 :  constant String := "Makefile";
   Path3 :  constant String := ".Test_File";
   Fd, Fd2 : fd_t := 0;
   Error :  errno_t;
begin

   Put_Line("Test 0001");

   -------------------------------------------------------------------
   -- Perform an Open attempt on a non-existant file
   -------------------------------------------------------------------

   Open(Path1,O_RDONLY,Fd,Error);   -- This should fail with ENOENT
   pragma Assert(Fd = -1);          -- No Fd should be returned
   pragma Assert(Error = ENOENT);   -- Expected error

   -------------------------------------------------------------------
   -- Strerror(3) test
   -------------------------------------------------------------------

   declare
      Error_Message : constant String := Strerror(Error);
   begin
      pragma Assert(Error_Message = "No such file or directory");
      null;
   end;

   -------------------------------------------------------------------
   -- Open Makefile for reading
   -------------------------------------------------------------------

   Open(Path2,O_RDONLY,Fd,Error);   -- Makefile should exist
   pragma Assert(Fd >= 0);          -- Expect a valid fd returned
   pragma Assert(Error = 0);        -- Expect success

   -------------------------------------------------------------------
   -- Open .Test_File for Writing
   -------------------------------------------------------------------

   Unlink(Path3,Error);             -- Ignore errors here

   Open(Path3,O_WRONLY or O_CREAT,8#770#,Fd2,Error);
   pragma Assert(Fd >= 0);          -- Expect a valid fd returned
   pragma Assert(Error = 0);        -- Expect success

   -------------------------------------------------------------------
   -- Now copy Makefile to .Test_File
   -------------------------------------------------------------------

   declare
      Buffer :  uchar_array(1..512);
      Last :    Natural := 0;
      Count :   Natural := 0;
      Offset :  off_t := 0;
   begin

      loop
         -------------------------------------------------------------
         -- Read a block in from the input file
         -------------------------------------------------------------

         Read(Fd,Buffer,Last,Error);
         if Error /= 0 then
            Put_Line(Strerror(Error) & ": Reading " & Path2);
         end if;

         pragma Assert(Error = 0);
         exit when Last = 0;
      
         -------------------------------------------------------------
         -- Write block out to output file
         -------------------------------------------------------------

         Write(Fd2,Buffer(Buffer'First..Last),Count,Error);
         if Error /= 0 then
            Put_Line(Strerror(Error) & ": Writing " & Path3);
         end if;

         pragma Assert(Error = 0);
         pragma Assert(Count = Last);

         -------------------------------------------------------------
         -- Compute offset in output file
         -------------------------------------------------------------

         Offset := Offset + off_t(Count);

         -------------------------------------------------------------
         -- Test LSeek and Check that current offset agrees
         -------------------------------------------------------------

         declare
            Check_Offset : off_t := 0;
         begin
            LSeek(Fd2,Check_Offset,SEEK_CUR,Error);
            pragma Assert(Check_Offset = Offset);
         end;
      end loop;

      Truncate(Fd2,Offset,Error);
      pragma Assert(Error = 0);
   end;

   -------------------------------------------------------------------
   -- Close files
   -------------------------------------------------------------------

   Close(Fd,Error);
   pragma Assert(Error = 0);

   Close(Fd2,Error);
   pragma Assert(Error = 0);

   -------------------------------------------------------------------
   -- Compare files
   -------------------------------------------------------------------

   Open(Path2,O_RDONLY,Fd,Error);
   pragma Assert(Fd >= 0);
   pragma Assert(Error = 0);        -- Expect success

   Open(Path3,O_RDONLY,Fd2,Error);
   pragma Assert(Fd >= 0);          -- Expect a valid fd returned
   pragma Assert(Error = 0);        -- Expect success

   declare
      Buffer :       uchar_array(1..300);
      Buf2 :         uchar_array(1..300);
      Last, Last2 :  Natural := 0;
   begin

      loop
         -------------------------------------------------------------
         -- Read a block in from the input file
         -------------------------------------------------------------

         Read(Fd,Buffer,Last,Error);
         pragma Assert(Error = 0);
         exit when Last = 0;

         -------------------------------------------------------------
         -- Read a block from the other file
         -------------------------------------------------------------

         Read(Fd2,Buf2,Last2,Error);
         pragma Assert(Error = 0);
         pragma Assert(Last2 = Last);
         pragma Assert(Buf2(1..Last2) = Buffer(1..Last));
      end loop;
   end;

   Close(Fd,Error);
   pragma Assert(Error = 0);

   Close(Fd2,Error);
   pragma Assert(Error = 0);

   -------------------------------------------------------------------
   -- Delete the output file
   -------------------------------------------------------------------

   Truncate(Path3,0,Error);         -- Test truncate by pathname
   pragma Assert(Error = 0);

   Unlink(Path3,Error);
   pragma Assert(Error = 0);

   -------------------------------------------------------------------
   -- Check that the output file is gone
   -------------------------------------------------------------------

   Open(Path3,O_RDONLY,Fd,Error);
   pragma Assert(Fd = -1);          -- Expect failure
   pragma Assert(Error = ENOENT);   -- Expect "file not found"

   Put_Line("Test 0001 Passed.");

end T0001;
