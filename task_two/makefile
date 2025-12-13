all: link
link: compile
	ld -m elf_i386 start.o util.o task2.o -o task2
compile: clean util.c start.s
	gcc -m32 -Wall -ansi -c -nostdlib -fno-stack-protector util.c -o util.o
	gcc -m32 -Wall -ansi -c -nostdlib -fno-stack-protector task2.c -o task2.o
	nasm -f elf32 start.s -o start.o
clean:
	rm -f *.o task2