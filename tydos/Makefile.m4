# By default, the bootable program name will be $(dosname).bin
# If you export this directory to extend the example as part of a programming
# exercise, redefine $(dos) to reflect your own DOS name, say
# dos = "amazingOS"

dos=$(shell basename $$(realpath .))
PROJECT_DIR=/home/yudiaramos/Desktop/teste/syseg
TYFS_EDIT=$(PROJECT_DIR)/eg/tyfs/tyfsedit

# Build the OS and an example user program.

all: $(dos).bin prog.bin disk.img copy-files-to-disk

# Link all objects needed by the OS.

$(dos).bin : bootloader.o bios1.o kernel.o kaux.o bios2.o logo.o syscall.o 
	ld -melf_i386 -T tydos.ld --orphan-handling=discard $^ -o $@

# Here we are statically linking the user program 'prob.bin' into the kernel,
# so as to simulate the execution of a user program. If we were to actually load
# and execute an external program, we should remove 'prog.o' and 'libtydos.o'
# from the list of pre-requisites, and edit the linker script accordingly.
# Comment out the following line if this is the case.

# $(dos).bin : prog.o libtydos.o 

# Rules to build objects from either C or assembly code.

%.o : %.c
	gcc -m16 -O0 --freestanding -fno-pic -c $(CFLAGS) $< -o $@

%.o : %.S
	as -32 $< -o $@

bootloader.o : bios1.h kernel.h 
kernel.o : bios1.h bios2.h kernel.h kaux.h   
kaux.o:    bios2.h kaux.h   

$(dos).bin : .EXTRA_PREREQS = rt0.o tydos.ld

# Rules to build the user programs
# You would add new programs to this variable if building other user programs.
# The user library is automatically added by the linker script.

progs = prog.bin

$(progs)  : %.bin : %.o libtydos.a 
	ld -melf_i386 -T prog.ld --orphan-handling=discard $< -o $@

$(progs:%.bin=%.o) : %.o : %.c $(PROJECT_DIR)/tydos.h
	gcc -m16 -O0 --freestanding -fno-pic -c $(CFLAGS) $< -o $@

$(progs:%.bin=%.o) : $(PROJECT_DIR)/tydos.h

$(progs:%.bin=%.o) : .EXTRA_PREREQS = prog.ld

# Recipes to build the user library.

libtydos.o: $(PROJECT_DIR)/libtydos.c $(PROJECT_DIR)/tydos.h
	gcc -m16 -O0 --freestanding -fno-pic -c $(CFLAGS) $< -o $@

libtydos.o : $(PROJECT_DIR)/tydos.h

libtydos.a : libtydos.o
	ar rcs $@ $^

# Rule to compile tyfsedit
$(PROJECT_DIR)/eg/tyfs/tyfsedit: 
	$(MAKE) -C $(PROJECT_DIR)/eg/tyfs tyfsedit

# Rule to create the disk image
disk.img: $(PROJECT_DIR)/eg/tyfs/tyfsedit
	dd if=/dev/zero of=disk.img bs=1k count=1440
	$(TYFS_EDIT) -f disk.img 1 1024

# Rule to copy files to the disk image
copy-files-to-disk: disk.img
	$(TYFS_EDIT) -w disk.img somefile.txt

# Rule to run the OS using QEMU
.PHONY: run

run: $(dos).bin
	qemu-system-i386 -fda $(dos).bin
# By default, the bootable program name will be $(dosname).bin
# If you export this directory to extend the example as part of a programming
# exercise, redefine $(dos) to reflect your own DOS name, say
# dos = "amazingOS"

dos=$(shell basename $$(realpath .))
PROJECT_DIR=/home/yudiaramos/Desktop/teste/syseg
TYFS_EDIT=$(PROJECT_DIR)/eg/tyfs/tyfsedit

# Build the OS and an example user program.

all: $(dos).bin prog.bin disk.img copy-files-to-disk

# Link all objects needed by the OS.

$(dos).bin : bootloader.o bios1.o kernel.o kaux.o bios2.o logo.o syscall.o 
	ld -melf_i386 -T tydos.ld --orphan-handling=discard $^ -o $@

# Here we are statically linking the user program 'prob.bin' into the kernel,
# so as to simulate the execution of a user program. If we were to actually load
# and execute an external program, we should remove 'prog.o' and 'libtydos.o'
# from the list of pre-requisites, and edit the linker script accordingly.
# Comment out the following line if this is the case.

# $(dos).bin : prog.o libtydos.o 

# Rules to build objects from either C or assembly code.

%.o : %.c
	gcc -m16 -O0 --freestanding -fno-pic -c $(CFLAGS) $< -o $@

%.o : %.S
	as -32 $< -o $@

bootloader.o : bios1.h kernel.h 
kernel.o : bios1.h bios2.h kernel.h kaux.h   
kaux.o:    bios2.h kaux.h   

$(dos).bin : .EXTRA_PREREQS = rt0.o tydos.ld

# Rules to build the user programs
# You would add new programs to this variable if building other user programs.
# The user library is automatically added by the linker script.

progs = prog.bin

$(progs)  : %.bin : %.o libtydos.a 
	ld -melf_i386 -T prog.ld --orphan-handling=discard $< -o $@

$(progs:%.bin=%.o) : %.o : %.c $(PROJECT_DIR)/tydos.h
	gcc -m16 -O0 --freestanding -fno-pic -c $(CFLAGS) $< -o $@

$(progs:%.bin=%.o) : $(PROJECT_DIR)/tydos.h

$(progs:%.bin=%.o) : .EXTRA_PREREQS = prog.ld

# Recipes to build the user library.

libtydos.o: $(PROJECT_DIR)/libtydos.c $(PROJECT_DIR)/tydos.h
	gcc -m16 -O0 --freestanding -fno-pic -c $(CFLAGS) $< -o $@

libtydos.o : $(PROJECT_DIR)/tydos.h

libtydos.a : libtydos.o
	ar rcs $@ $^

# Rule to compile tyfsedit
$(PROJECT_DIR)/eg/tyfs/tyfsedit: 
	$(MAKE) -C $(PROJECT_DIR)/eg/tyfs tyfsedit

# Rule to create the disk image
disk.img: $(PROJECT_DIR)/eg/tyfs/tyfsedit
	dd if=/dev/zero of=disk.img bs=1k count=1440
	$(TYFS_EDIT) -f disk.img 1 1024

# Rule to copy files to the disk image
copy-files-to-disk: disk.img
	$(TYFS_EDIT) -w disk.img somefile.txt

# Rule to run the OS using QEMU
.PHONY: run

run: $(dos).bin
	qemu-system-i386 -fda $(dos).bin

# Housekeeping.

.PHONY: clean

clean:
	rm -f *.bin *.o *~ *.s *.a
	rm -f disk.img
	$(MAKE) -C $(PROJECT_DIR)/eg/tyfs clean

# Housekeeping.

.PHONY: clean

clean:
	rm -f *.bin *.o *~ *.s *.a
	rm -f disk.img
	$(MAKE) -C $(PROJECT_DIR)/eg/tyfs clean
