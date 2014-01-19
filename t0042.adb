-- t0042.adb - Sat Jan 18 19:20:40 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- $Id$
--
-- Protected under the GNU GENERAL PUBLIC LICENSE v2, June 1991

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0042 is
   use Ada.Text_IO;    

   Info :      s_msqid_ds;
   Msgq :      int_t := -1;
   Message :   constant uchar_array := ( 1, 2, 3 );
   Msg_Buf :   uchar_array(2..6) := ( 0, 0, 0, 0, 0 );
   Msg_Type :  long_t := 0;
   Msglen :    Natural := 0;
   Error :     errno_t;
begin

   Put_Line("Test 0042 - Msgget/Msgctl/Msgsnd/Msgrcv");

   Msgget(IPC_PRIVATE,IPC_CREAT or IPC_EXCL or 8#700#,Msgq,Error);
   if Error = EEXIST then
      Msgctl(Msgq,IPC_RMID,Error);
      pragma Assert(Error = 0);

      Msgget(IPC_PRIVATE,IPC_CREAT or IPC_EXCL or 8#700#,Msgq,Error);
   end if;

   pragma Assert(Error = 0);
   pragma Assert(Msgq >= 0);

   Msgctl_Get(Msgq,IPC_STAT,Info,Error);
   pragma Assert(Error = 0);
   pragma Assert(Info.msg_qnum = 0);   

   Msgsnd(Msgq,1,Message,MSG_NOERROR,Error);
   pragma Assert(Error = 0);

   Msgctl_Get(Msgq,IPC_STAT,Info,Error);
   pragma Assert(Error = 0);
   pragma Assert(Info.msg_qnum = 1);

   Msg_Type := 1;
   Msgrcv(Msgq,Msg_Type,Msg_Buf,MSG_NOERROR,Msglen,Error);
   pragma Assert(Error = 0);
   pragma Assert(Msg_Type = 1);
   pragma Assert(Msglen = Message'Length);
   pragma Assert(Msg_Buf(Msg_Buf'First..Msg_Buf'First+Msglen-1) = Message);

   Msgctl(Msgq,IPC_RMID,Error);
   pragma Assert(Error = 0);

   Put_Line("Test 0042 Passed.");

end T0042;
