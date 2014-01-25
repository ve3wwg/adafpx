-- t0045.adb - Fri Jan 24 19:22:31 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- $Id$
--
-- Protected under the GNU GENERAL PUBLIC LICENSE v2, June 1991

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0045 is
   use Ada.Text_IO;

   Path :      constant String := "Makefile";
   Fd :        fd_t := -1;
   P :         s_pollfd_array := (
                  0 => (
                     fd => 0,
                     events => POLLIN,
                     revents => 0
                  )
               );
   Count :     Natural := 0;
   Rd_Count :  Natural := 0;
   Buf :       uchar_array(1..32);
   Last :      Natural;
   S :         s_stat;
   Error :     errno_t;
begin

   Put_Line("Test 0045 - Poll");

   Open(Path,O_RDONLY,Fd,Error);
   pragma Assert(Error = 0);
   pragma Assert(Fd >= 0);

   P(P'First).fd := Fd;

   loop
      Poll(P,1,Count,Error);
      case Error is
         when 0 =>
            if Count > 0 then
               for X in P'Range loop
                  if ( P(X).revents and POLLIN ) /= 0 then
                     Read(P(X).fd,Buf,Last,Error);
                     pragma Assert(Error = 0);
                     Rd_Count := Rd_Count + Buf(Buf'First..Last)'Length;
                  end if;
               end loop;
               exit when Last < Buf'First;
            end if;
         when EINTR =>
            null;
         when others =>
            pragma Assert(Error = 0);
            null;
      end case;
   end loop;

   Close(Fd,Error);
   pragma Assert(Error = 0);

   -- Check the Bytes Read Count
   Stat(Path,S,Error);
   pragma Assert(Error = 0);
   pragma Assert(Natural(S.st_size) = Rd_Count);

   Put_Line("Test 0045 Passed.");

end T0045;
