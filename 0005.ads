----------------------------------------------------------------------
-- Ada for POSIX (AdaFPX)
----------------------------------------------------------------------
-- Warren W. Gay VE3WWG     Tue Dec  3 18:49:48 2013
-- 
-- This file is generated. Edit at your own risk.
--
-- This is free software. See associated file LICENSE the license
-- details.
-- 
-- No warranty is expressed or implied.

with System;

package Posix is

    -- These types are temporary and for testing.. for the moment..
    type int_t is range -2**31 .. 2**31-1;

    type errno_t is new int_t range 0 .. 2**31-1;
    type fcntl_t is new int_t;
    type whence_t is new int_t;
    type mntflags_t is new int_t;

    type amode_t is range -2**16 .. 2**16-1;
    type mode_t is new int_t;
    type pid_t is new int_t;
    type time_t is new int_t;
    type dev_t is new int_t;
    type uid_t is new int_t;
    type gid_t is new int_t;
    type offset_t is new int_t;
    type uint_t is new int_t;
