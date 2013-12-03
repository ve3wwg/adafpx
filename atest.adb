with Posix;
use Posix;

procedure ATest is
    Error : errno_t;
begin
    Close(5,Error);
end ATest;
