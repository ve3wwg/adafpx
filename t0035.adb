-- t0035.adb - Tue Jan 14 21:39:20 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0035 is
   use Ada.Text_IO;    

   Path1 :              constant String := "Makefile";
   Path2 :              constant String := ".";
   D :                  DIR;
   Dirent :             s_dirent;
   Eof :                Boolean := False;
   Count1, Count2 :     Natural := 0;
   Dir_Pos, Dir_Pos2 :  long_t := -1;
   Error :              errno_t;
begin

   Put_Line("Test 0035 - Dir functions");

   Opendir(Path1,D,Error);
   pragma Assert(Error = ENOTDIR);
   
   Opendir(Path2,D,Error);
   pragma Assert(Error = 0);

   loop
      Readdir(D,Dirent,Eof,Error);
      pragma Assert(Error = 0);
      exit when Eof;
      if Dirent.d_type = DT_REG then
         Count1 := Count1 + 1;
         exit when Ada_String(Dirent.d_name) = Path1;
      end if;
   end loop;

   Rewinddir(D);

   loop
      Telldir(D,Dir_Pos,Error);
      pragma Assert(Error = 0);

      Readdir(D,Dirent,Eof,Error);
      pragma Assert(Error = 0);
      exit when Eof;

      pragma Assert(Dir_Pos >= 0);

      if Dirent.d_type = DT_REG then
         Count2 := Count2 + 1;
         exit when Ada_String(Dirent.d_name) = Path1;
      end if;
   end loop;

   pragma Assert(Count1 = Count2);

   Rewinddir(D);
   Seekdir(D,Dir_Pos,Error);
   pragma Assert(Error = 0);

   Telldir(D,Dir_Pos2,Error);
   pragma Assert(Error = 0);

#if not POSIX_FAMILY = "FreeBSD"
   pragma Assert(Dir_Pos = Dir_Pos2);
#end if;

   Readdir(D,Dirent,Eof,Error);
   pragma Assert(Error = 0);
   pragma Assert(Ada_String(Dirent.d_name) = Path1);
   pragma Assert(Dirent.d_type = DT_REG);

   Closedir(D,Error);
   pragma Assert(Error = 0);

   Put_Line("Test 0035 Passed.");

end T0035;
