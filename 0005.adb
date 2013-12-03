----------------------------------------------------------------------
-- Ada for POSIX (AdaFPX)
----------------------------------------------------------------------
-- This is generated source code. Do not edit.

package body Posix is

    function C_Error(Ret_Val: int_t) return errno_t is
        function c_errno return errno_t;
        pragma Import(C,c_errno,"c_errno");
    begin
        if Ret_Val >= 0 then
            return 0;
        else
            return c_errno;
        end if;
    end C_Error;

    function C_Error(PID: pid_t) return errno_t is
        function c_errno return errno_t;
        pragma Import(C,c_errno,"c_errno");
    begin
        if PID /= -1 then
            return 0;
        else
            return c_errno;
        end if;
    end C_Error;

    function C_String(Ada_String: String) return String is
        T : String(Ada_String'First..Ada_String'Last+1);
    begin
        T(T'First..T'Last-1) := Ada_String;
        T(T'Last) := Character'Val(0);
        return T;
    end C_String;
