
surface_net.o : surface_net.c
	gcc -Wall -O3 -O -c surface_net.c -lm

marching_squares.o : marching_squares.c
	gcc -Wall -O3 -O -c marching_squares.c -lm

marching_squares.js : marching_squares.c
	emcc -O3 marching_squares.c -s EXTRA_EXPORTED_RUNTIME_METHODS='["cwrap"]' -s WASM=0 -o hello.js

default: surface_net.o marching_squares.o marching_squares.wasm

.DEFAULT_GOAL := default
