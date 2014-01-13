-- t0028.adb - Sun Jan 12 21:44:01 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0028 is
   use Ada.Text_IO;    

   Set :       sigset_t;
   Error :     errno_t;
begin

   Put_Line("Test 0028 - Sigemptyset/Sigfillset/Sigaddset/Sigdelset/Sigismember");

   Sigfillset(Set);

   for Signo in sig_t(1)..31 loop
      pragma Assert(Sigismember(Set,Signo));
      null;
   end loop;

   Sigemptyset(Set);

   for Signo in sig_t(1)..31 loop
      pragma Assert(not Sigismember(Set,Signo));
      null;
   end loop;

   Sigaddset(Set,SIGINT);
   Sigaddset(Set,SIGTERM);

   for Signo in sig_t(1)..31 loop
      case Signo is
      when SIGINT | SIGTERM =>
         pragma Assert(Sigismember(Set,Signo));
         null;
      when others =>
         pragma Assert(not Sigismember(Set,Signo));
         null;
      end case;
   end loop;

   Sigfillset(Set);

   Sigdelset(Set,SIGINT);
   Sigdelset(Set,SIGTERM);

   for Signo in sig_t(1)..31 loop
      case Signo is
      when SIGINT | SIGTERM =>
         pragma Assert(not Sigismember(Set,Signo));
         null;
      when others =>
         pragma Assert(Sigismember(Set,Signo));
         null;
      end case;
   end loop;

   Put_Line("Test 0028 Passed.");

end T0028;
