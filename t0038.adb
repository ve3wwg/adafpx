-- t0038.adb - Wed Jan 15 21:41:47 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0038 is
   use Ada.Text_IO;    

   Error :     errno_t;
begin

   Put_Line("Test 0038 - Syslog");

   Openlog("Ada Test 0038",LOG_PID or LOG_CONS,LOG_LOCAL7);
   Syslog(5,"Test message from t0038.adb");
   Closelog;

   Put_Line("Test 0038 Passed.");

end T0038;
