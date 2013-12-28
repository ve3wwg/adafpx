with Posix;
use Posix;

procedure ATest is
   Error : errno_t;
begin
   Close(5,Error);
   pragma Unreferenced(Error);

   Openlog("Ada Test",LOG_PID or LOG_CONS,LOG_LOCAL7);
   Syslog(5,"Testing from atest.adb");
   Closelog;
end ATest;
