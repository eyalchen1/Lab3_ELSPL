all: link
link: compile
	ld -m elf_i386 printing.o -o taskzero 
compile: clean printing.s
	nasm -f elf32 printing.s -o printing.o
clean:
	rm -f *.o taskzero