-- t0003.adb - Fri Jan  3 23:22:31 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0003 is
   use Ada.Text_IO;    

   Path1 :  constant String := "Makefile";
   Path2 :  constant String := ".Test_0003";
   Fd, Fd2 : fd_t := 0;
   Error :  errno_t;
begin

   Put_Line("Test 0003");

   -------------------------------------------------------------------
   -- Open Makefile for reading
   -------------------------------------------------------------------

   Open(Path1,O_RDONLY,Fd,Error);   -- Makefile should exist
   pragma Assert(Fd >= 0);          -- Expect a valid fd returned
   pragma Assert(Error = 0);        -- Expect success

   -------------------------------------------------------------------
   -- Open .Test_File for Writing
   -------------------------------------------------------------------

   Unlink(Path2,Error);             -- Ignore errors here

   Create(Path2,8#770#,Fd2,Error);
   pragma Assert(Fd >= 0);          -- Expect a valid fd returned
   pragma Assert(Error = 0);        -- Expect success

   -------------------------------------------------------------------
   -- Now copy Makefile to .Test_File
   -------------------------------------------------------------------

   declare
      Buffer :  uchar_array(1..535);
      Last :    Natural := 0;
      Count :   Natural := 0;
      Offset :  off_t := 0;
   begin

      loop
         -------------------------------------------------------------
         -- Read a block in from the input file
         -------------------------------------------------------------

         PRead(Fd,Buffer,Offset,Last,Error);
         if Error /= 0 then
            Put_Line(Strerror(Error) & ": Reading " & Path1);
         end if;

         pragma Assert(Error = 0);
         exit when Last = 0;
      
         -------------------------------------------------------------
         -- Write block out to output file
         -------------------------------------------------------------

         PWrite(Fd2,Buffer(Buffer'First..Last),Offset,Count,Error);
         if Error /= 0 then
            Put_Line(Strerror(Error) & ": Writing " & Path2);
         end if;

         pragma Assert(Error = 0);
         pragma Assert(Count = Last);

         -------------------------------------------------------------
         -- Compute offset in output file
         -------------------------------------------------------------

         Offset := Offset + off_t(Count);
      end loop;
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

   Open(Path1,O_RDONLY,Fd,Error);
   pragma Assert(Fd >= 0);
   pragma Assert(Error = 0);        -- Expect success

   Open(Path2,O_RDONLY,Fd2,Error);
   pragma Assert(Fd >= 0);          -- Expect a valid fd returned
   pragma Assert(Error = 0);        -- Expect success

   declare
      Buffer :       uchar_array(1..233);
      Buf2 :         uchar_array(1..233);
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

   Unlink(Path2,Error);
   pragma Assert(Error = 0);

   -------------------------------------------------------------------
   -- Check that the output file is gone
   -------------------------------------------------------------------

   Open(Path2,O_RDONLY,Fd,Error);
   pragma Assert(Fd = -1);          -- Expect failure
   pragma Assert(Error = ENOENT);   -- Expect "file not found"

   Put_Line("Test 0003 Passed.");

end T0003;
