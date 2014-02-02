-- t0047.adb - Sat Feb  1 16:15:50 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- $Id$
--
-- Protected under the GNU GENERAL PUBLIC LICENSE v2, June 1991

with Ada.Text_IO;

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
   Accepted :  Boolean;
   Received :  Boolean;

   Fd1, Fd2 :  fd_t := -1;
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
   Get_Cmsg(Ctl_Buf(1..Len),Offset,Ctl_Level,Ctl_Type,I'Address,I'Size/8,Received);
   pragma Assert(Received);
   pragma Assert(Ctl_Level = 1);
   pragma Assert(Ctl_Type = 11);
   pragma Assert(I = 98);

   Get_Cmsg(Ctl_Buf(1..Len),Offset,Ctl_Level,Ctl_Type,J'Address,J'Size/8,Received);
   pragma Assert(Received);
   pragma Assert(Ctl_Level = 2);
   pragma Assert(Ctl_Type = 12);
   pragma Assert(J = 95);

   Get_Cmsg(Ctl_Buf(1..Len),Offset,Ctl_Level,Ctl_Type,K'Address,K'Size/8,Received);
   pragma Assert(Received);
   pragma Assert(Ctl_Level = 3);
   pragma Assert(Ctl_Type = 13);
   pragma Assert(K = 23);

   Get_Cmsg(Ctl_Buf(1..Len),Offset,Ctl_Level,Ctl_Type,L'Address,L'Size/8,Received);
   pragma Assert(Received);
   pragma Assert(Ctl_Level = 4);
   pragma Assert(Ctl_Type = 14);
   pragma Assert(L = 29);

   Put_Line("Offset =" & uint64_t'Image(Offset));
   pragma Assert(Offset = Ctl_Len);

   -- There should be no next message

   Get_Cmsg(Ctl_Buf(1..Len),Offset,Ctl_Level,Ctl_Type,L'Address,L'Size/8,Received);
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

   Put_Line("Test 0047 Passed.");

end T0047;
