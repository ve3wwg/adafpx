-- t0049.adb - Fri Jun 10 21:25:59 2016
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the GNU GENERAL PUBLIC LICENSE v2, June 1991

with Ada.Text_IO;

with Posix;
use Posix;

with System;
use System;

procedure T0049 is
   use Ada.Text_IO;

   Connect_Addr : constant String := "127.0.0.1";

   Inet_C_Addr :  s_sockaddr_in;
   Port_C_No :    constant ushort_t := 19199;

   S, L :      fd_t := -1;       -- Connecting socket
   Child :     pid_t := -1;
   Error :     errno_t;
begin

   Put_Line("Test 0049 - IPv4 socket/connect/etc.");

   Fork(Child,Error);
   pragma Assert(Error = 0);

   if Child /= 0 then
      -- Parent process

      -- Create socket:
      Socket(PF_INET,SOCK_STREAM,0,S,Error);
      pragma Assert(Error = 0);
      pragma Assert(S >= 0);

      -- Create address to connect with:
      Inet_C_Addr.sin_family := AF_INET;
      Inet_C_Addr.sin_port   := Htons(Port_C_No);
      Inet_Aton(Connect_Addr,Inet_C_Addr.sin_addr,Error);
      pragma Assert(Error = 0);

      -- Test Inet_Ntop -- should return same IPv4 String
      declare
         Str_Addr :  String(1..300);
         Last :      Natural := 0;
      begin
         Inet_Ntop(Inet_C_Addr.sin_addr,Str_Addr,Last,Error);
         pragma Assert(Error = 0);
         pragma Assert(Str_Addr(1..Last) = Connect_Addr);
      end;

      -- Test port
      declare
         Test_Port : constant ushort_t := Ntohs(Inet_C_Addr.sin_port);
      begin
         pragma Assert(Test_Port = Port_C_No);
         null;
      end;

      -- Wait for client to setup and listen
      Sleep(2);

      -- Connect to the client process
      Connect(S,Inet_C_Addr,Error);
      pragma Assert(Error = 0);

      -- Write something
      declare
         Msg :    constant uchar_array := To_uchar_array("Hello!");
         Count :  Natural;
      begin
         Write(S,uchar_array(Msg),Count,Error);
         pragma Assert(Error = 0);
         pragma Assert(Count = Msg'Length);
      end;

      -- Test Shutdown(2)
      Shutdown(S,SHUT_RD,Error);
      pragma Assert(Error = 0);

      -- Close the socket
      Close(S,Error);
      pragma Assert(Error = 0);

      -- Wait for child process to exit
      declare
         Status : int_t := -1;
      begin
         Wait_Pid(Child,0,Status,Error);
         pragma Assert(WIFEXITED(Status));
         pragma Assert(WEXITSTATUS(Status) = 0);
      end;

      Put_Line("Test 0049 Passed.");
   else
      -- Child process

      -- Create a listening socket:
      Socket(PF_INET,SOCK_STREAM,0,L,Error);
      pragma Assert(Error = 0);
      pragma Assert(L >= 0);

      -- Create the address to bind to:
      Inet_C_Addr.sin_family := AF_INET;
      Inet_C_Addr.sin_port   := Htons(Port_C_No);
      Inet_Aton(Connect_Addr,Inet_C_Addr.sin_addr,Error);
      pragma Assert(Error = 0);

      -- Bind to the address:
      Bind(L,Inet_C_Addr,Error);
      pragma Assert(Error = 0);

      loop
         Listen(L,10,Error);
         exit when Error = 0;
         pragma Assert(Error = EINTR);
      end loop;

      -- Accept one connect
      declare
         Peer :      u_sockaddr;
         Peer_Len :  socklen_t;
      begin
         loop
            Accept_Connect(L,Peer,Peer_Len,S,Error);
            exit when Error = 0;
            pragma Assert(Error = EINTR);
         end loop;

         pragma Assert(S >= 0);
         pragma Assert(Peer.addr_sock.sa_family = AF_INET);

         -- Display local socket address
         declare
            Local_Addr :   u_sockaddr;
            Addr_Len :     socklen_t;
            Str_Addr :     String(1..300);
            Last :         Natural := 0;
         begin
            Getsockname(S,Local_Addr,Addr_Len,Error);
            pragma Assert(Error = 0);
            pragma Assert(Local_Addr.addr_sock.sa_family = AF_INET);
            Inet_Ntop(Local_Addr.addr_in.sin_addr,Str_Addr,Last,Error);
            pragma Assert(Error = 0);
            Put_Line("Local name is " & Str_Addr(1..Last) & ":" & ushort_t'Image(Ntohs(Local_Addr.addr_in.sin_port)));
         end;

         -- Display peer's address
         declare
            Str_Addr :  String(1..300);
            Last :      Natural := 0;
            Port :      constant ushort_t := Ntohs(Peer.addr_in.sin_port);
         begin
            Inet_Ntop(Peer.addr_in.sin_addr,Str_Addr,Last,Error);
            pragma Assert(Error = 0);

            Put_Line("Received connect from " & Str_Addr(1..Last) & ":" & ushort_t'Image(Port));

            -- Test Getpeername
            declare
               Peer_Name : u_sockaddr;
               Name_Len :  socklen_t;
               Buf2 :      String(1..300);
               Last2 :     Natural := 0;
            begin
               Getpeername(S,Peer_Name,Name_Len,Error);
               pragma Assert(Error = 0);
               pragma Assert(Peer_Name.addr_sock.sa_family = AF_INET);
               Inet_Ntop(Peer_Name.addr_in.sin_addr,Buf2,Last2,Error);
               pragma Assert(Error = 0);
               pragma Assert(Buf2(1..Last2) = Str_Addr(1..Last));         

               Put_Line("Peer name is " & Str_Addr(1..Last) & ":" & ushort_t'Image(Ntohs(Peer_Name.addr_in.sin_port)));
            end;      
         end;
      end;

#if POSIX_FAMILY = "FreeBSD" or POSIX_FAMILY = "Darwin"

      -- Test KQueue
      declare
         Kq :        fd_t;
         Chgs :      s_kevent64_array(1..1);
         Evts :      s_kevent64_array(1..1);
         N_Evts :    Natural := 0;
         Timeout :   constant s_timespec := ( tv_sec => 1, tv_nsec => 0 );
      begin
         KQueue(Kq,Error);
         pragma Assert(Kq >= 0);

         Chgs(1).ident := uint64_t(S);
         Chgs(1).filter := EVFILT_READ;
         Chgs(1).flags := EV_ADD;
         Chgs(1).fflags := 0;
         Chgs(1).udata := Null_Address;
         
         loop
            KEvent(Kq,Chgs,1,Evts,N_Evts,0,Timeout,Error);
            pragma assert(Error = 0);

            exit when N_Evts > 0;
         end loop;

         pragma Assert(N_Evts > 0);
         pragma Assert(Evts(1).ident = uint64_t(S));
         pragma Assert(Evts(1).filter = EVFILT_READ);
         pragma Assert(Evts(1).data > 0);
         pragma Assert(Evts(1).udata = Null_Address);

         declare
            Rx_Avail :  constant Natural := Natural(Evts(1).data);
            Rx_Buf :    uchar_array(1..Rx_Avail);
            Last :      Natural;
         begin
            Read(S,Rx_Buf,Last,Error);
            pragma Assert(Error = 0);
            pragma Assert(Last = Rx_Avail);
            
            Put("Got msg '");
            Put(To_String(Rx_Buf(1..Last)));
            Put_Line("'");
         end;

         Close(Kq,Error);
         pragma Assert(Error = 0);
      end;

#end if;

      -- Close listening socket
      Close(L,Error);
      pragma Assert(Error = 0);

      -- Test getsockopt(2)
      declare
         Sock_Error : int_t := -33;
         Keep_Alive : int_t := -33;
      begin
         Get_Sockopt(S,SOL_SOCKET,SO_ERROR,Sock_Error,Error);
         pragma Assert(Error = 0);
         pragma Assert(Sock_Error = 0);

         Get_Sockopt(S,SOL_SOCKET,SO_KEEPALIVE,Keep_Alive,Error);
         pragma Assert(Error = 0);
         pragma Assert(Keep_Alive >= 0);

         if Keep_Alive /= 0 then
            Keep_Alive := 0;        -- Turn it off
            Set_Sockopt(S,SOL_SOCKET,SO_KEEPALIVE,Keep_Alive,Error);
            pragma Assert(Error = 0);

            Keep_Alive := -95;
            Get_Sockopt(S,SOL_SOCKET,SO_KEEPALIVE,Keep_Alive,Error);
            pragma Assert(Error = 0);
            pragma Assert(Keep_Alive = 0);
         else
            Keep_Alive := 1;        -- Turn it on
            Set_Sockopt(S,SOL_SOCKET,SO_KEEPALIVE,Keep_Alive,Error);
            pragma Assert(Error = 0);

            Keep_Alive := -95;
            Get_Sockopt(S,SOL_SOCKET,SO_KEEPALIVE,Keep_Alive,Error);
            pragma Assert(Error = 0);
            pragma Assert(Keep_Alive /= 0);
         end if;
      end;

      declare
         Linger : s_linger := ( l_onoff => 1, l_linger => 2 );
      begin
         Set_Sockopt(S,SOL_SOCKET,SO_LINGER,Linger,Error);
         pragma Assert(Error = 0);

         Linger.l_onoff := 0;
         Linger.l_linger := 23;
         Get_Sockopt(S,SOL_SOCKET,SO_LINGER,Linger,Error);
         pragma Assert(Error = 0);
         pragma Assert(Linger.l_onoff /= 0);
         pragma Assert(Linger.l_linger = 2);
      end;

      -- Close accepted socket
      Close(S,Error);
      pragma Assert(Error = 0);

   end if;

end T0049;
