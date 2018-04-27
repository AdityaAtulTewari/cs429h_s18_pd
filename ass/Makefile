RSFLAGS=-O -g

ass : main.rs Makefile
	rustc $(RSFLAGS) -o ass main.rs

TESTS=$(sort $(wildcard *.fun))
RUNS=$(patsubst %.fun,%.result,$(TESTS))

test : $(RUNS)

$(RUNS) : %.result : %.fun Makefile ass
	@echo -n "[$*] ... "
	@-timeout 5 ./ass $*.fun > $*.out
	@((diff -b $*.out $*.ok > /dev/null) && echo "pass") || (echo "fail" ; echo "--- expected ---"; cat $*.ok; echo "--- found ---" ; cat $*.out)

clean :
	rm -f *.out
	rm -f ass
	rm -f main
	rm -rf build-test

allclean:
	make clean
	rm -rf build-test

alltest:
	rm -rf ./build-test
	mkdir ./build-test
	cp test/*.ok ./build-test
	cp test/*.fun ./build-test
	cp Makefile ./build-test
	cp ./src/*.rs ./build-test
	cd build-test; make -s test;

