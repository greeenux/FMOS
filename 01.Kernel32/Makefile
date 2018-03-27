##########################################
# set the build environment and rules
##########################################
NASM32 = nasm
GCC32 = gcc -c -m32 -ffreestanding
LD32= ld -melf_i386 -T ../elf_i386.x -nostdlib -e Main -Ttext 0x10200
OBJCOPY32= objcopy -j .text -j .data -j .rodata -j .bss -S -O binary

OBJECTDIRECTORY =Temp
SOURCEDIRECTORY =Source

###########################################
# set build item and build methology
###########################################
all : prepare Kernel32.bin

prepare:
	mkdir -p $(OBJECTDIRECTORY)

$(OBJECTDIRECTORY)/EntryPoint.bin : $(SOURCEDIRECTORY)/EntryPoint.s
	$(NASM32) -o $@ $<

dep:
	@echo === Make Dependancy File ===
	make -C $(OBJECTDIRECTORY) -f ../Makefile InternalDependency
	@echo === Dependancy Search Complete ===

ExecuteInternalBuild : dep
	make -C $(OBJECTDIRECTORY) -f ../Makefile Kernel32.elf

$(OBJECTDIRECTORY)/Kernel32.elf.bin: ExecuteInternalBuild
	$(OBJCOPY32) $(OBJECTDIRECTORY)/Kernel32.elf $@

Kernel32.bin : $(OBJECTDIRECTORY)/EntryPoint.bin $(OBJECTDIRECTORY)/Kernel32.elf.bin
	cat $^ > $@

clean :
	rm -f *.bin
	rm -f $(OBJECTDIRECTORY)/*.*

##########################################
#the calling from Make , executed on a Temp Directory basis
##########################################
CENTRYPOINTOBJECTFILE= Main.o
CSOURCEFILES= $(wildcard ../$(SOURCEDIRECTORY)/*.c)
ASSEMBLYSOURCEFILES= $(wildcard ../$(SOURCEDIRECTORY)*.asm)
OBJECTFILES = $(subst Main.o, , $(notdir $(patsubst %.c,%.o,$(CSOURCEFILES))))
ASSEMBLYOBJECTFILES =$(notdir $(patsubst %.asm,%.o,$(ASSEMBLYSOURCEFILES)))

#rules to convert .c files to .o files
%.o: ../$(SOURCEDIRECTORY)/%.c
	$(GCC32) -c $<
#rules to convert .asm files to .o files
%.o: ../$(SOURCEDIRECTORY)/%.asm
	$(NASM32) -f elf32 -o $@ $<

InternalDependency:
	$(GCC32) -MM $(CSOURCEFILES) > Dependency.dep

Kernel32.elf : $(CENTRYPOINTOBJECTFILE) $(COBJECTFILE) $(ASSEMBLYOBJECTFILES)
	$(LD32) -o $@ $^

ifeq (Dependency.dep, $(wildcard Dependency.dep))
include Dependency.dep
endif
