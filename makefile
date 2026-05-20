
.PHONY: clean

__start__: calculator
	./calculator

calculator: lex.yy.c parser.tab.c
	g++ -std=c++23 -O3 -march=native parser.tab.c lex.yy.c -o calculator

parser.tab.c: parser.y
	bison parser.y --defines
	
lex.yy.c: lexer.l  
	flex lexer.l 
	
clean : 
	rm *.c *.h *.output calculator 
