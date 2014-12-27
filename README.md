adafpx
======

Ada For POSIX thick binding generator.

Status
======

This project is still in development, with most of the system
calls completed (section 2).

The purpose of the project is to generate Ada packages for
use on a POSIX system. The main target platforms for testing
include:

	- Linux
	- Darwin OSX
	- FreeBSD

but not necessarily in that priority.


Build and Test:
===============

    $ make clobber
    $ make
    $ make tests
