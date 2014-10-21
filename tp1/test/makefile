mygetopt_long: mygetopt_long.o
	gcc -g3 -c -Wall mygetopt_long.c

mips32_plot: mips32_plot.o
	gcc -g3 -c -Wall mips32_plot.S

tp1: main.o mips32_plot.o mygetopt_long.o
	gcc -g3 -g -lm -o tp1 main.c mips32_plot.S mygetopt_long.c

clean:
	rm -f *.o tp1

tp: clean tp1
