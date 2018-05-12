CFLAGS=-g -std=c99 -O0 -Werror -Wall -pthread

CFILES=$(sort $(wildcard *.c))
OFILES=$(subst .c,.o,$(CFILES))
RFILES=$(sort $(wildcard *.rs))
ROFILES=$(subst .rs,.o,$(CFILES))

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
	cp ./compiler/test/*.ok ./test-build
	cp ./compiler/test/*.fun ./test-build
	cp ./compiler/test/*.args ./test-build
	cp ./compiler/src/gfc.c ./test-build
	cp ./hardware/*.v ./test-build
	cp Makefile ./test-build
	cp ./ass/ass.rs
	cd test-build; make -s test;

clean :
	rm -f *.out $(EXECS)
	rm -f *.d
	rm -f *.o
	rm -f *.s
	rm -f gfc
	rm -rf ./test-build

VFILES=$(wildcard *.v)

OK = $(sort $(wildcard *.ok))
TESTS = $(patsubst %.ok,%,$(OK))
RAWS = $(patsubst %.ok,%.raw,$(OK))
VCDS = $(patsubst %.ok,%.vcd,$(OK))
OUTS = $(patsubst %.ok,%.out,$(OK))
RESULTS = $(patsubst %.ok,%.result,$(OK))

cpu : $(VFILES) Makefile
	-iverilog -o cpu $(VFILES)

test : $(RESULTS)

clean :
	rm -rf cpu *.out *.vcd *.raw mem.hex

$(RAWS) : %.raw : Makefile cpu %.hex
	cp $*.hex mem.hex
	-timeout 10 ./cpu > $*.raw 2>&1
	-mv cpu.vcd $*.vcd

$(VCDS) : %.vcd : %.raw;

$(OUTS) : %.out : Makefile %.raw
	-grep -v "VCD info: dumpfile cpu.vcd opened for output" $*.raw > $*.out

$(RESULTS) : %.result : Makefile %.out %.ok
	@echo -n "$* ... "
	-@((diff -wbB $*.out $*.ok > /dev/null 2>&1) && echo "pass") || (echo "fail")
-include *.d
