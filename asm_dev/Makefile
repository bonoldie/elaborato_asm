CC = gcc -m32
CFLAGS = -Wall -gstabs 
OFLAGS = -c -o

all: postfix.o main.o
	$(CC) $(CFLAGS) -o bin/postfix obj/postfix.o obj/main.o

main.o : 
	$(CC) $(CFLAGS) $(OFLAGS) obj/main.o src/main.c

postfix.o : 
	$(CC) $(CFLAGS) $(OFLAGS) obj/postfix.o src/postfix.s	

clean: 
	rm -rf obj/* bin/*
