all: link
link: compile
	ld -m elf_i386 start.o encoder.o util.o -o task1
compile: clean encoder.s util.c start.s
	gcc -m32 -Wall -ansi -c -nostdlib -fno-stack-protector util.c -o util.o
	nasm -f elf32 start.s -o start.o
	nasm -f elf32 encoder.s -o encoder.o
clean:
	rm -f *.o task0