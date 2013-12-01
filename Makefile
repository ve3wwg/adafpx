######################################################################
#  Makefile
######################################################################

include Makefile.incl

.SUFFIXES: .yacc .flex .cpp .hpp

.yacc.cpp:
	$(YACC) -o $*.cpp --defines=$*.hpp $<

.flex.cpp:
	$(FLEX) --outfile=$*.cpp $<

.cpp.o:
	$(CXX) -c -Wall $(OPTZ) $(CSTD) $(INCL) $< -o $*.o

all:	main

OBJS	= ansi-c-lex.o ansi-c-yacc.o pugixml.o main.o config.o utils.o comp.o \
	  macros.o types.o sect2.o

main:	ansi-c-lex.cpp ansi-c-yacc.cpp $(OBJS)
	$(CXX) $(OBJS) -o main

clean:
	rm -f *.o core 

clobber: clean
	rm -fr ./staging
	rm -f ansi-c-lex.cpp ansi-c-yacc.cpp ansi-c-yacc.hpp errs.t main core*

ansi-c-lex.o: ansi-c-yacc.cpp ansi-c-yacc.hpp

backup: clobber
	(cd .. && tar czvf adafpx.tar.gz adafpx)

# End Makefile
