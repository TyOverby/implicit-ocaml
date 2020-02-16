
surface_net.o : surface_net.c
	gcc -Wall -O3 -O -c surface_net.c -lm

marching_squares.o : marching_squares.c
	gcc -Wall -O3 -O -c marching_squares.c -lm

marching_squares.wasm : marching_squares.c
	emcc marching_squares.c -s WASM=1 -o hello.html

default: surface_net.o marching_squares.o marching_squares.wasm

.DEFAULT_GOAL := default
