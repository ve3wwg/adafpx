######################################################################
#  Makefile
######################################################################

include Makefile.incl
-include Makefile.tests

.SUFFIXES: .yacc .flex .cpp .hpp

.yacc.cpp:
	$(YACC) -o $*.cpp --defines=$*.hpp $<

.flex.cpp:
	$(FLEX) --outfile=$*.cpp $<
#	$(FLEX) -d --outfile=$*.cpp $<

.cpp.o:
	$(CXX) -c -Wall -Wno-unused-function $(OPTZ) $(CSTD) $(INCL) $< -o $*.o

.c.o:
	$(CC) -c -Wall -Wno-unused-function $(OPTZ) $(INCL) $< -o $*.o

all:	main run atest

OBJS	= ansi-c-lex.o ansi-c-yacc.o pugixml.o main.o config.o utils.o comp.o \
	  macros.o types.o sect2.o btypes.o systypes.o structs.o

main:	ansi-c-lex.cpp ansi-c-yacc.cpp $(OBJS)
	$(CXX) $(OBJS) -o main
	rm -f atest atest.o *.ali b~* cglue.o

run:
	./main

atest::	libadafpx.a
	gnatmake -Wall atest.adb -o atest -largs libadafpx.a

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
	rm -f *.o core 

clobber: clean
	rm -fr ./staging adafpx.c
	rm -f b~* *.ali
	rm -f ansi-c-lex.cpp ansi-c-yacc.cpp ansi-c-yacc.hpp errs.t main core*
	rm -f posix.ads posix.adb
	rm -f Makefile.tests

ansi-c-lex.o: ansi-c-yacc.cpp ansi-c-yacc.hpp

backup: clobber
	(cd .. && tar czvf adafpx.tar.gz adafpx)

# End Makefile
