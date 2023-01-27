CC=g++
CFLAGS=-g -Wall -O3 -I ~/include -L ~/lib -pedantic -std=c++11 -Wno-unused-function -D_GNU_SOURCE
HEADERS=kstring.h
OBJECTS=$(HEADERS:.h=.o)
LIBS=-lz -lsdsl

.PHONY: clean rebuild

all:createIndexMem-VERSION-NICO createIndexMem_0-1

createIndexMem-VERSION-NICO: createIndexMem-VERSION-NICO.c $(HEADERS) $(OBJECTS) Makefile
	$(CC) $(CFLAGS) $(OBJECTS) $< -o $@ $(LIBS)
	
createIndexMem_0-1: createIndexMem_0-1.c $(HEADERS) $(OBJECTS) Makefile
	$(CC) $(CFLAGS) $(OBJECTS) $< -o $@ $(LIBS)

clean:
	rm -f createIndexMem *.o
	rm -f createIndexMem-VERSION-NICO *.o

rebuild: clean all

