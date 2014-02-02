-- t0047.adb - Sat Feb  1 16:15:50 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- $Id$
--
-- Protected under the GNU GENERAL PUBLIC LICENSE v2, June 1991

with Ada.Text_IO, System;

with Posix;
use Posix;

procedure T0047 is
   use Ada.Text_IO;

   I, J, L :   int_t;
   K :         ushort_t;
   Ctl_Buf :   uchar_array(1..128);
   Ctl_Len :   uint64_t;
   Len :       Natural;
   Ctl_Level : int_t;
   Ctl_Type :  int_t;
   Offset :    uint64_t;
   Data_Len :  uint64_t;
   Accepted :  Boolean;
   Received :  Boolean;

   Fd1, Fd2 :  fd_t := -1;
   Fd3 :       fd_t := -1;
   Child :     pid_t := -1;
   Error :     errno_t;
begin

   Put_Line("Test 0047 - Put/Get_Cmsg");

   I := 98;
   J := 95;
   K := 23;
   L := 29;

   -- Put control messages into Ctl_Buf
   Ctl_Len := 0;
   Put_Cmsg(Ctl_Buf,Ctl_Len,1,11,I'Address,I'Size/8,Accepted);
   pragma Assert(Accepted);
   Put_Cmsg(Ctl_Buf,Ctl_Len,2,12,J'Address,J'Size/8,Accepted);
   pragma Assert(Accepted);
   Put_Cmsg(Ctl_Buf,Ctl_Len,3,13,K'Address,K'Size/8,Accepted);
   pragma Assert(Accepted);
   Put_Cmsg(Ctl_Buf,Ctl_Len,4,14,L'Address,L'Size/8,Accepted);
   pragma Assert(Accepted);
   pragma Assert(Ctl_Len > 8);

   Put_Line("Ctl_Len =" & uint64_t'Image(Ctl_Len));

   I := 0;
   J := 0;
   K := 0;
   L := 0;

   -- Get control messages back from Ctl_Buf

   Offset := 0;
   Len := Natural(Ctl_Len);
   Get_Cmsg(Ctl_Buf(1..Len),Offset,Ctl_Level,Ctl_Type,Received);
   pragma Assert(Received);
   pragma Assert(Ctl_Level = 1);
   pragma Assert(Ctl_Type = 11);

   Data_Len := I'Size/8;
   Get_Cmsg(Ctl_Buf(1..Len),Offset,I'Address,Data_Len,Received);
   pragma Assert(Received);
   pragma Assert(Data_Len >= I'Size/8);
   pragma Assert(I = 98);

   Get_Cmsg(Ctl_Buf(1..Len),Offset,Ctl_Level,Ctl_Type,Received);
   pragma Assert(Received);
   pragma Assert(Ctl_Level = 2);
   pragma Assert(Ctl_Type = 12);

   Data_Len := J'Size/8;
   Get_Cmsg(Ctl_Buf(1..Len),Offset,J'Address,Data_Len,Received);
   pragma Assert(Received);
   pragma Assert(Data_Len >= J'Size/8);
   pragma Assert(J = 95);

   Get_Cmsg(Ctl_Buf(1..Len),Offset,Ctl_Level,Ctl_Type,Received);
   pragma Assert(Received);
   pragma Assert(Ctl_Level = 3);
   pragma Assert(Ctl_Type = 13);

   Data_Len := K'Size/8;
   Get_Cmsg(Ctl_Buf(1..Len),Offset,K'Address,Data_Len,Received);
   pragma Assert(Received);
   pragma Assert(Data_Len >= K'Size/8);
   pragma Assert(K = 23);

   Get_Cmsg(Ctl_Buf(1..Len),Offset,Ctl_Level,Ctl_Type,Received);
   pragma Assert(Received);
   pragma Assert(Ctl_Level = 4);
   pragma Assert(Ctl_Type = 14);

   Data_Len := L'Size/8;
   Get_Cmsg(Ctl_Buf(1..Len),Offset,L'Address,Data_Len,Received);
   pragma Assert(Received);
   pragma Assert(Data_Len >= L'Size/8);
   pragma Assert(L = 29);

   Put_Line("Offset =" & uint64_t'Image(Offset));
   pragma Assert(Offset = Ctl_Len);

   -- There should be no next message

   Get_Cmsg(Ctl_Buf(1..Len),Offset,Ctl_Level,Ctl_Type,Received);
   pragma Assert(not Received);

   -- This should faile due to small buffer size

   Ctl_Len := 0;
   Put_Cmsg(Ctl_Buf(1..12),Ctl_Len,1,11,I'Address,I'Size/8,Accepted);
   pragma Assert(not Accepted);

   -- Perform a networked test of the control message

   Socketpair(PF_LOCAL,SOCK_STREAM,0,Fd1,Fd2,Error);
   pragma Assert(Error = 0);
   pragma Assert(Fd1 >= 0);
   pragma Assert(Fd2 >= 0);

   Fork(Child,Error);
   pragma Assert(Error = 0);

   if Child > 0 then
      -- Child process
      Close(Fd1,Error);
      pragma Assert(Error = 0);

      pragma Warnings(Off);
      Fd1 := -1;
      pragma Warnings(On);

      declare
         Data :   String(1..32);
         Iov :    s_iovec_array := (
                     0 => ( iov_base => Data'Address, iov_len => Data'Length )
                  );
         Msg :    s_msghdr;
      begin
         Msg.msg_name := System.Null_Address;
         Msg.msg_namelen := 0;
         Msg.msg_iov := Iov'Address;
         Msg.msg_iovlen := Iov'Length;
         Msg.msg_control := Ctl_Buf'Address;
         Msg.msg_controllen := Ctl_Buf'Length;
         Msg.msg_flags := 0;

         Recvmsg(Fd2,Msg,0,Error);
         pragma Assert(Error = 0);

         Offset := 0;
         Len := Natural(Msg.msg_controllen);
         Fd3 := -1;

Put_Line("Child: Read msg with controllen=" & Natural'Image(Len));

         loop
            Get_Cmsg(Ctl_Buf(1..Len),Offset,Ctl_Level,Ctl_Type,Received);
            exit when not Received;

Put_Line("Child: Read Level=" & int_t'Image(Ctl_Level) & ", Type=" & int_t'Image(Ctl_Type));

            case Ctl_Level is
               when SOL_SOCKET =>
Put_Line("Child: SOL_SOCKET");
                  case Ctl_Type is
                     when SCM_RIGHTS =>
Put_Line("Child: SCM_RIGHTS");
                        declare
                           Rights :    fd_array_t(1..8);
                           Fd_Count :  Natural := 0;
                        begin
                           Get_Cmsg(Ctl_Buf(1..Len),Offset,Rights,Fd_Count,Received);
                           pragma Assert(Error = 0);
Put_Line("Child: Count =" & Natural'Image(Fd_Count));
                           pragma Assert(Fd_Count = 1);

                           Fd3 := Rights(Rights'First);
Put_Line("Child: Fd3 =" & fd_t'Image(Fd3));
                        end;
                     when others =>
Put_Line("Child: SCM_OTHER");
                        null;
                  end case;
               when others =>
Put_Line("Child: LEV_OTHER");
                  null;
            end case;
         end loop;
      end;

      Close(Fd3,Error);
      pragma Assert(Error = 0);     -- Success proves Fd came over to child proc

      Close(Fd2,Error);
      pragma Assert(Error = 0);     -- Close socket
      return;
   end if;

   -- Parent process      
   Close(Fd2,Error);
   pragma Assert(Error = 0);

   pragma Warnings(Off);
   Fd2 := -1;
   pragma Warnings(On);

   -- Send File Descriptor to Child process
   Open("Makefile",O_RDONLY,Fd3,Error);
   pragma Assert(Error = 0);
   pragma Assert(Fd3 >= 0);

   declare
      Fds : constant fd_array_t(1..1) := ( 1 => Fd3 );
   begin
      Ctl_Len := 0;
      Put_Cmsg(Ctl_Buf,Ctl_Len,Fds,Accepted);
      pragma Assert(Accepted);
      pragma Assert(Ctl_Len > 0);
   end;

   declare
      Byte :   String(1..1) := "X";
      Iov :    s_iovec_array := (
                  0 => ( iov_base => Byte'Address, iov_len => Byte'Length )
               );
      Msg :    s_msghdr;
   begin
      Msg.msg_name := System.Null_Address;
      Msg.msg_namelen := 0;
      Msg.msg_iov := Iov'Address;
      Msg.msg_iovlen := Iov'Length;
      Msg.msg_control := Ctl_Buf'Address;
#if POSIX_FAMILY = "Linux"
      Msg.msg_controllen := Ctl_Len;
#end if;
#if POSIX_FAMILY = "FreeBSD"
      Msg.msg_controllen := uint_t(Ctl_Len);
#end if;
#if POSIX_FAMILY = "Darwin"
      Msg.msg_controllen := uint_t(Ctl_Len);
#end if;
      Msg.msg_flags := 0;

      Sendmsg(Fd1,Msg,0,Error);
      pragma Assert(Error = 0);
Put_Line("Parent sent msg..");
   end;

   Shutdown(Fd1,SHUT_RD,Error);
   pragma Assert(Error = 0);
Put_Line("Parent SHUT_RD for " & fd_t'Image(Fd3));

   Close(Fd3,Error);
   pragma Assert(Error = 0);

   Close(Fd1,Error);
   pragma Assert(Error = 0);

   -- Wait for child process to exit
   declare
      Status : int_t := -1;
   begin
      Wait_Pid(Child,0,Status,Error);
      pragma Assert(WIFEXITED(Status));
      pragma Assert(WEXITSTATUS(Status) = 0);
Put_Line("Child" & pid_t'Image(Child) & " exited with rc=" & int_t'Image(WEXITSTATUS(Status)));
   end;

   Put_Line("Test 0047 Passed.");

end T0047;
