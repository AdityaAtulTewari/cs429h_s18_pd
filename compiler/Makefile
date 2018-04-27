CFLAGS=-g -std=c99 -O0 -Werror -Wall -pthread

CFILES=$(sort $(wildcard *.c))
OFILES=$(subst .c,.o,$(CFILES))

gfc : $(OFILES) Makefile
	gcc $(CFLAGS) -o gfc $(OFILES)

$(OFILES) : %.o : %.c Makefile
	gcc $(CFLAGS) -MD -c $*.c

TESTS=$(sort $(wildcard *.fun))
EXECS=$(subst .fun,,$(TESTS))
RUNS=$(patsubst %.fun,%.result,$(TESTS))

test : $(RUNS)

$(EXECS) : % : %.fun Makefile gfc
	@echo compiling $*.fun
	@-timeout 5 ./gfc $*

$(RUNS) : %.result : % %.args
	@echo -n "$* ... "
	@-timeout 5 ./$* `head -n 1 $*.args` > $*.out
	@((diff -b $*.out $*.ok > /dev/null) && echo "pass") || (echo "fail" ; echo "--- expected ---"; cat $*.ok; echo "--- found ---" ; cat $*.out)

alltest:
	rm -rf ./test-build
	mkdir test-build
	cp ./test/*.ok ./test-build
	cp ./test/*.fun ./test-build
	cp ./test/*.args ./test-build
	cp ./src/gfc.c ./test-build
	cp Makefile ./test-build
	cd test-build; make -s test;

clean :
	rm -f *.out $(EXECS)
	rm -f *.d
	rm -f *.o
	rm -f *.s
	rm -f gfc
	rm -rf ./test-build

-include *.d
