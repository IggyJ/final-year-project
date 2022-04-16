PATH_SV   = systemverilog
PATH_S    = cpu_code_assembly
PATH_C    = cpu_code_c
PATH_TOOL = toolchain

default: top

# SystemVerilog modules
%: $(PATH_SV)/%.sv $(PATH_SV)/testbench/%_tb.sv
	iverilog -Wall -Wno-timescale -g 2012 -I$(PATH_SV) -o $@.vvp $(PATH_SV)/testbench/$@_tb.sv

# Raw assembly files
%: $(PATH_S)/%.s
	bronzebeard -o $@.bin $(PATH_S)/$@.s
	xxd -p -c 1 $@.bin > imem.txt

# GCC toolchain
CC = riscv64-unknown-elf-gcc
OBJCOPY = riscv64-unknown-elf-objcopy
CFLAGS = -Wall -Os -mabi=ilp32 -march=rv32i -nostdlib -Xlinker -Map=output.map -Wl,--print-memory-usage -fstack-usage
OBJCOPY_FLAGS = -O binary -j .text
LINKER_FLAGS = -T
LINKER_SCRIPT = $(PATH_TOOL)/link.ld
BOOTLOADER = $(PATH_TOOL)/bootloader.s
MATH_LIB = $(PATH_TOOL)/math.s

# Compoile C programs
%: $(PATH_C)/%.c $(LINKER_SCRIPT) $(BOOTLOADER)
	$(CC) $(LINKER_FLAGS) $(LINKER_SCRIPT) $(CFLAGS) $(BOOTLOADER) $(MATH_LIB) $(PATH_C)/$@.c -o $@.o
	$(OBJCOPY) $(OBJCOPY_FLAGS) $@.o $@.bin
	xxd -p -c 4 $@.bin > imem.txt
	python2 convert_to_mif.py -dr HEX imem.txt imem.mif


# $(CC) $(LINKER_FLAGS) $(LINKER_SCRIPT) $(CFLAGS) $(BOOTLOADER) $(PATH_C)/$@.c -o $@.o
# @stat --printf="Binary is %s bytes\n" $@.bin

run:
	vvp top.vvp
	scripts/chop.sh dmem.txt 16

clean:
	rm -rf *.vvp *.vcd *.bin *.o *_chopped.txt *.su
