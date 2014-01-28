//////////////////////////////////////////////////////////////////////
// cglue.c -- C Glue Code for Ada Package POSIX
// Date: Mon Dec  2 22:02:37 2013
///////////////////////////////////////////////////////////////////////

#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <assert.h>

#include "cglue.h"

void *
c_error_ptr() {
	return (void *)(-1);
}

int
c_errno() {
	return errno;
}

unsigned
c_strlen(const char *sptr) {
	return (unsigned)strlen(sptr);
}

// End cglue.c
