# This is a make file for "scanner" flex/C++ program
# Created by Carson Pemble 4/22/2020

scanner: syntax.o
	g++ syntax.cpp -o scanner

syntax.o:
	flex -o syntax.cpp syntax.l

clean:
	rm syntax.cpp scanner
