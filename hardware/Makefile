VFILES=$(wildcard *.v)

OK = $(sort $(wildcard *.ok))
TESTS = $(patsubst %.ok,%,$(OK))
RAWS = $(patsubst %.ok,%.raw,$(OK))
VCDS = $(patsubst %.ok,%.vcd,$(OK))
OUTS = $(patsubst %.ok,%.out,$(OK))
RESULTS = $(patsubst %.ok,%.result,$(OK))

cpu : $(VFILES) Makefile
	iverilog -o cpu $(VFILES)

test : $(RESULTS)

clean :
	rm -rf cpu *.out *.vcd *.raw mem.hex

$(RAWS) : %.raw : Makefile cpu %.hex
	cp $*.hex mem.hex
	timeout 10 ./cpu > $*.raw 2>&1
	mv cpu.vcd $*.vcd

$(VCDS) : %.vcd : %.raw;

$(OUTS) : %.out : Makefile %.raw
	grep -v "VCD info: dumpfile cpu.vcd opened for output" $*.raw | grep -v '#.*' > $*.out
	grep '#.*' $*.raw > $*.cycles

$(RESULTS) : %.result : Makefile %.out %.ok
	@echo -n "$* ... "
	@((diff -wbB $*.out $*.ok > /dev/null 2>&1) && echo "pass") || (echo "fail" ; echo "\n\n----------- expected ----------"; cat $*.ok ; echo "\n\n------------- found ----------"; cat $*.out)

allclean:
	make clean
	 rm -rf blah

alltest:
	rm -rf ./blah
	mkdir ./blah
	cp tests/*.ok ./blah
	cp tests/*.hex ./blah
	cp Makefile ./blah
	cp *.v ./blah
	cd blah; make -s test;

intialize:
	ln -s ~gheith/public/cs429h_s18_pa ./tests