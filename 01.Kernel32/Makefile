all : VirtualOS.bin

VirtualOS.bin: VirtualOS.asm
	nasm -o VirtualOS.bin $<

clean:
	rm -f VirtualOS.bin
