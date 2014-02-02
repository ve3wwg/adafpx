//////////////////////////////////////////////////////////////////////
// cglue.c -- C Glue Code for Ada Package POSIX
// Date: Mon Dec  2 22:02:37 2013
///////////////////////////////////////////////////////////////////////

#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
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

#define CALC_POINTR(first,offset) ((struct cmsghdr *)(((char *)first) + offset))
#define CALC_OFFSET(first,ptr)   ((uint64_t) (((char *)ptr) - ((char *)first)))

uint64_t
c_put_cmsg(void *buf,uint64_t buflen,uint64_t curlen,struct cmsghdr *cmsg,void *data,uint64_t datalen) {
	struct msghdr mhdr;
	struct cmsghdr *f, *p = 0;

	mhdr.msg_control = buf;
	mhdr.msg_controllen = buflen;
	mhdr.msg_flags = 0;

	f = CMSG_FIRSTHDR(&mhdr);
	p = CALC_POINTR(f,curlen);

	uint64_t new_length = curlen + CMSG_SPACE(datalen);

	if ( new_length <= buflen ) {
		p->cmsg_level = cmsg->cmsg_level;
		p->cmsg_type = cmsg->cmsg_type;
		p->cmsg_len = CMSG_LEN(datalen);
		memcpy(CMSG_DATA(p),data,datalen);
	} else	{
		new_length = 0;			/* Won't fit buffer */
	}

	return new_length;
}

uint64_t
c_get_cmsg(void *buf,uint64_t buflen,uint64_t offset,struct cmsghdr *cmsg,void *data,uint64_t datalen) {
	struct msghdr mhdr;
	struct cmsghdr *f, *p, *n;

	mhdr.msg_control = buf;
	mhdr.msg_controllen = buflen;
	mhdr.msg_flags = 0;

	if ( offset > mhdr.msg_controllen )
		return 0;			/* No more messages */

	f = CMSG_FIRSTHDR(&mhdr);
	p = CALC_POINTR(f,offset);		/* Point to current message */
	
	if ( CALC_OFFSET(f,p) >= buflen ) {
		return 0;			/* There is no current message */
	}

	cmsg->cmsg_level = p->cmsg_level;
	cmsg->cmsg_type  = p->cmsg_type;
	cmsg->cmsg_len   = p->cmsg_len;

	uint64_t actual_data = cmsg->cmsg_len - sizeof *cmsg;

	if ( actual_data < datalen )
		datalen = actual_data;		/* Use smaller actual length */

	if ( data && datalen > 0 )
		memcpy(data,CMSG_DATA(p),datalen);	/* Copy over data */

	n = CMSG_NXTHDR(&mhdr,p);
	if ( !n )
		return buflen;			/* No more messages */

	uint64_t new_offset = CALC_OFFSET(f,n);
	return new_offset;
}

// End cglue.c
