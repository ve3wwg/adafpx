######################################################################
#  Makefile
######################################################################

include Makefile.incl
-include Makefile.tests

x:   xrm pugitest

xrm:
	rm -f pugixml_c.o pugi_xml.o

all:	main run atest

OBJS	= ansi-c-lex.o ansi-c-yacc.o pugixml.o main.o config.o utils.o comp.o \
	  macros.o types.o sect2.o btypes.o systypes.o structs.o

main:	ansi-c-lex.cpp ansi-c-yacc.cpp $(OBJS)
	$(CXX) $(OBJS) -o main
	rm -f atest atest.o *.ali b~* cglue.o

run:	main
	./main -G "$(CC)"

atest::	libadafpx.a
	gnatmake -Wall atest.adb -o atest -largs libadafpx.a
	@echo "Apply 'make tests' to compile and run tests."

libadafpx.a: adafpx.o
	ar r libadafpx.a adafpx.o

adafpx.c: posix.ads posix.adb
	cat cglue.c staging/*.cc >adafpx.c

adafpx.o: adafpx.c

atest.o: posix.ads posix.adb posix.o

retest:
	rm -f cglue.o atest atest.o 
	$(MAKE) -$(MAKEFLAGS) atest

clean:
	rm -f *.o *.ali core 
	rm -f t[0-9][0-9][0-9][0-9]

clobber: clean
	rm -fr ./staging adafpx.c
	rm -f b~* *.ali posix.defs
	rm -f ansi-c-lex.cpp ansi-c-yacc.cpp ansi-c-yacc.hpp errs.t main core*
	rm -f posix.ads posix.adb
	rm -f Makefile.tests pugitest

distclean: clobber

pugi_xml.o:
	$(GNAT) -c -gnata pugi_xml.adb
	
pugitest: pugixml_c.o pugi_xml.o pugixml.o
	$(GNAT) -g -gnata pugitest pugi_xml -largs pugixml_c.o pugixml.o -L. -ladafpx --LINK=g++

ansi-c-lex.o: ansi-c-yacc.cpp ansi-c-yacc.hpp

backup: clobber
	(cd .. && tar czvf adafpx.tar.gz adafpx)

ansi-c-lex.cpp: ansi-c-lex.flex
ansi-c-yacc.hpp: ansi-c-lex.flex

ansi-c-yacc.cpp: ansi-c-yacc.yacc
ansi-c-yacc.hpp: ansi-c-yacc.yacc

main.o:	ansi-c-yacc.hpp ansi-c-yacc.cpp cglue.h

posix.ads: main run
posix.adb: main run

# End Makefile
