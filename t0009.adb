-- t0009.adb - Sat Jan  4 10:26:43 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0009 is
   use Ada.Text_IO;    

   Path1 :        constant String := "Makefile";
   Stat1, Stat3 : s_stat;
   Path2 :        constant String := ".Test_0009";
   Stat2 :        s_stat;
   Fd, Fd2, Fd3 : fd_t := -1;
   Stat4, Stat5 : s_stat;
   Error :        errno_t;
begin

   Put_Line("Test 0009 - Link/Stat/Fstat/Dup/Dup2");

   -------------------------------------------------------------------
   -- Open .Test_File for Writing
   -------------------------------------------------------------------

   Unlink(Path2,Error);             -- Ignore errors here

   Link(Path1,Path2,Error);

   pragma Assert(Error = 0);

   -------------------------------------------------------------------
   -- Get stat info
   -------------------------------------------------------------------

   Stat(Path1,Stat1,Error);
   pragma Assert(Error = 0);

   Stat(Path2,Stat2,Error);
   pragma Assert(Error = 0);

   pragma Assert(Stat1.st_dev = Stat2.st_dev);
   pragma Assert(Stat1.st_mode = Stat2.st_mode);
   pragma Assert(Stat1.st_nlink = Stat2.st_nlink);
   pragma Assert(Stat1.st_ino = Stat2.st_ino);
   pragma Assert(Stat1.st_uid = Stat2.st_uid);
   pragma Assert(Stat1.st_gid = Stat2.st_gid);
   pragma Assert(Stat1.st_rdev = Stat2.st_rdev);
   pragma Assert(Stat1.st_mtimespec = Stat2.st_mtimespec);
   pragma Assert(Stat1.st_ctimespec = Stat2.st_ctimespec);
   pragma Assert(Stat1.st_size = Stat2.st_size);
   pragma Assert(Stat1.st_blocks = Stat2.st_blocks);
   pragma Assert(Stat1.st_blksize = Stat2.st_blksize);
   pragma Assert(Stat1.st_flags = Stat2.st_flags);

   -------------------------------------------------------------------
   -- Open Makefile for reading
   -------------------------------------------------------------------

   Open(Path1,O_RDONLY,Fd,Error);   -- Makefile should exist
   pragma Assert(Fd >= 0);          -- Expect a valid fd returned
   pragma Assert(Error = 0);        -- Expect success

   FStat(Fd,Stat3,Error);
   pragma Assert(Error = 0);

   pragma Assert(Stat1.st_dev = Stat3.st_dev);
   pragma Assert(Stat1.st_mode = Stat3.st_mode);
   pragma Assert(Stat1.st_nlink = Stat3.st_nlink);
   pragma Assert(Stat1.st_ino = Stat3.st_ino);
   pragma Assert(Stat1.st_uid = Stat3.st_uid);
   pragma Assert(Stat1.st_gid = Stat3.st_gid);
   pragma Assert(Stat1.st_rdev = Stat3.st_rdev);
   pragma Assert(Stat1.st_mtimespec = Stat3.st_mtimespec);
   pragma Assert(Stat1.st_ctimespec = Stat3.st_ctimespec);
   pragma Assert(Stat1.st_size = Stat3.st_size);
   pragma Assert(Stat1.st_blocks = Stat3.st_blocks);
   pragma Assert(Stat1.st_blksize = Stat3.st_blksize);
   pragma Assert(Stat1.st_flags = Stat3.st_flags);

   -------------------------------------------------------------------
   -- Now test Dup(2) and Dup2(2)
   -------------------------------------------------------------------

   Dup(Fd,Fd2,Error);
   pragma Assert(Error = 0);

   Fd3 := 50;
   Dup2(Fd,Fd3,Error);
   pragma Assert(Error = 0);

   -------------------------------------------------------------------
   -- Use fstat(2) to confirm Dup/Dup2 results
   -------------------------------------------------------------------

   FStat(Fd2,Stat4,Error);
   pragma Assert(Error = 0);
   FStat(Fd3,Stat5,Error);
   pragma Assert(Error = 0);

   -------------------------------------------------------------------
   -- Compare results
   -------------------------------------------------------------------

   pragma Assert(Stat1.st_dev = Stat4.st_dev);
   pragma Assert(Stat1.st_mode = Stat4.st_mode);
   pragma Assert(Stat1.st_nlink = Stat4.st_nlink);
   pragma Assert(Stat1.st_ino = Stat4.st_ino);
   pragma Assert(Stat1.st_uid = Stat4.st_uid);
   pragma Assert(Stat1.st_gid = Stat4.st_gid);
   pragma Assert(Stat1.st_rdev = Stat4.st_rdev);
   pragma Assert(Stat1.st_mtimespec = Stat4.st_mtimespec);
   pragma Assert(Stat1.st_ctimespec = Stat4.st_ctimespec);
   pragma Assert(Stat1.st_size = Stat4.st_size);
   pragma Assert(Stat1.st_blocks = Stat4.st_blocks);
   pragma Assert(Stat1.st_blksize = Stat4.st_blksize);
   pragma Assert(Stat1.st_flags = Stat4.st_flags);

   Close(Fd2,Error);
   pragma Assert(Error = 0);

   pragma Assert(Stat1.st_dev = Stat5.st_dev);
   pragma Assert(Stat1.st_mode = Stat5.st_mode);
   pragma Assert(Stat1.st_nlink = Stat5.st_nlink);
   pragma Assert(Stat1.st_ino = Stat5.st_ino);
   pragma Assert(Stat1.st_uid = Stat5.st_uid);
   pragma Assert(Stat1.st_gid = Stat5.st_gid);
   pragma Assert(Stat1.st_rdev = Stat5.st_rdev);
   pragma Assert(Stat1.st_mtimespec = Stat5.st_mtimespec);
   pragma Assert(Stat1.st_ctimespec = Stat5.st_ctimespec);
   pragma Assert(Stat1.st_size = Stat5.st_size);
   pragma Assert(Stat1.st_blocks = Stat5.st_blocks);
   pragma Assert(Stat1.st_blksize = Stat5.st_blksize);
   pragma Assert(Stat1.st_flags = Stat5.st_flags);

   Close(Fd3,Error);
   pragma Assert(Error = 0);

   -------------------------------------------------------------------
   -- Delete the output file
   -------------------------------------------------------------------

   Unlink(Path2,Error);
   pragma Assert(Error = 0);

   Close(Fd,Error);
   pragma Assert(Error = 0);

   -------------------------------------------------------------------
   -- Check that the output file is gone
   -------------------------------------------------------------------

   Open(Path2,O_RDONLY,Fd,Error);
   pragma Assert(Fd = -1);          -- Expect failure
   pragma Assert(Error = ENOENT);   -- Expect "file not found"

   Put_Line("Test 0009 Passed.");

end T0009;
