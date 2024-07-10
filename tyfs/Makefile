# Makefile for compiling tyfsedit

# Build the tyfsedit tool

all: tyfsedit

%.o : %.c
	gcc -c $(CPPFLAGS) $(CFLAGS) $< -o $@

tyfsedit : tyfsedit.o
	gcc $< -lm -o $@

.PHONY: clean

clean:
	rm -f *.o tyfsedit
