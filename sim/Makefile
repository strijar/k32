# CROSS = $(HOME)/toolchain/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux/bin/arm-linux-gnueabihf-

CC = $(CROSS)gcc
CFLAGS = -std=c99 -O2

all: k32

io.o: io.h io.c

k32.o: k32.c io.h

k32: k32.o io.o

clean:
	rm *.o k32 *.log
