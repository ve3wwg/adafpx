-- t0016.adb - Sun Jan  5 16:20:25 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0016 is
   use Ada.Text_IO;    

   Path :      constant String := "Makefile";
   Now :       constant time_t := Time;
   Times :     s_utimbuf;
   Error :     errno_t;
   S :         s_stat;
   T :         s_timeval_array2;
begin

   Put_Line("Test 0016 - UTime/UTimes/Stat");

   Times.actime  := Now;
   Times.modtime := Now;
   UTime(Path,Times,Error);
   pragma Assert(Error = 0);

   Stat(Path,S,Error);
   pragma Assert(Error = 0);

#if POSIX_FAMILY = "Darwin"
   pragma Assert(S.st_atimespec.tv_sec = Times.actime);
   pragma Assert(S.st_mtimespec.tv_sec = Times.modtime);
#end if;

#if POSIX_FAMILY = "Linux"
#if POSIX_MACHINE = "x86_64"
   pragma Assert(S.st_atim.tv_sec = Times.actime);
   pragma Assert(S.st_mtim.tv_sec = Times.modtime);
#else
   pragma Assert(S.st_atime = Times.actime);
   pragma Assert(S.st_mtime = Times.modtime);
#end if;   
#end if;

#if POSIX_FAMILY = "FreeBSD"
#if POSIX_MACHINE = "amd64"
   pragma Assert(S.st_atim.tv_sec = Times.actime);
   pragma Assert(S.st_mtim.tv_sec = Times.modtime);
#else
   pragma Assert(S.st_atime = Times.actime);
   pragma Assert(S.st_mtime = Times.modtime);
#end if;
#end if;

   T(1).tv_sec := Now + 1;
   T(1).tv_usec := 0;
   T(2).tv_sec := Now + 1;
   T(2).tv_usec := 0;

   UTimes(Path,T,Error);
   pragma Assert(Error = 0);

   Stat(Path,S,Error);
   pragma Assert(Error = 0);

#if POSIX_FAMILY = "Darwin"
   pragma Assert(S.st_atimespec.tv_sec = Now+1);
   pragma Assert(S.st_mtimespec.tv_sec = Now+1);
#end if;

#if POSIX_FAMILY = "Linux"
#if POSIX_MACHINE = "x86_64"
   pragma Assert(S.st_atim.tv_sec = Times.actime + 1);
   pragma Assert(S.st_mtim.tv_sec = Times.modtime + 1);
#else
   pragma Assert(S.st_atime = Times.actime + 1);
   pragma Assert(S.st_mtime = Times.modtime + 1);
#end if;   
#end if;

#if POSIX_FAMILY = "FreeBSD"
#if POSIX_MACHINE = "amd64"
   pragma Assert(S.st_atim.tv_sec = Times.actime + 1);
   pragma Assert(S.st_mtim.tv_sec = Times.modtime + 1);
#else
   pragma Assert(S.st_atime = Times.actime + 1);
   pragma Assert(S.st_mtime = Times.modtime + 1);
#end if;
#end if;

   Put_Line("Test 0016 Passed.");

end T0016;
