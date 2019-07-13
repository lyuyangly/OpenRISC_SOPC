#***********************************************************************************************
#   File        : Makefile
#   Author      : Lyu Yang
#   Date        :
#   Description : Makefile for OpenRISC
#***********************************************************************************************

TARGET = main

CROSS_COMPILE = or32-elf-

INCLUDE_DIRS = -I ./
LIBRARY_DIRS = -L ./

CC = $(CROSS_COMPILE)gcc
CFLAGS =  $(INCLUDE_DIRS) -c -msoft-div -msoft-float -msoft-mul -mno-ror -mno-cmov -mno-sext -Os

CXX = $(CROSS_COMPILE)g++
CXXFLAGS =  $(INCLUDE_DIRS) -c -msoft-float -msoft-mul -mno-ror -mno-cmov -mno-sext -Os

AS = $(CROSS_COMPILE)gcc
ASFLAGS = -c

LD = $(CROSS_COMPILE)gcc
LDFLAGS = $(LIBRARY_DIRS) -T./openrisc.lds -Wl,-Map,$(TARGET).map -nostartfiles

OBJCP = $(CROSS_COMPILE)objcopy
OBJCPFLAGS = -O binary -j .text -j .rodata -j .data -j .bss

AR = $(CROSS_COMPILE)ar
ARFLAGS = cr

DUMP = $(CROSS_COMPILE)objdump
DUMPFLAG = --disassemble --syms --all-header

SIZE = $(CROSS_COMPILE)size

OBJS_LIB +=

OBJS += $(patsubst %.S, %.o, $(wildcard *.S))
OBJS += $(patsubst %.c, %.o, $(wildcard *.c))

# Make
.PHONY: all clean debug
all: $(TARGET).elf $(TARGET).bin $(TARGET).asm $(TARGET).mif
	$(SIZE) $(TARGET).elf

%.o: %.S
	$(AS) $(ASFLAGS) $^ -o $@

%.o: %.c
	$(CC) $(CFLAGS) $^ -o $@

$(TARGET).elf: $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS_LIB) $^ -o $@

$(TARGET).asm: $(TARGET).elf
	$(DUMP) $(DUMPFLAG) $(TARGET).elf > $(TARGET).asm

$(TARGET).bin: $(TARGET).elf
	$(OBJCP) $(OBJCPFLAGS) $< $@

$(TARGET).mif: $(TARGET).bin
	./bin2fpga/bin2fpga 4096 $<

clean:
	rm -rf *.o *.asm *.elf *.bin *.mif *.map *.coe data.txt

debug:
	$(CROSS_COMPILE)gdb $(TARGET).elf -x gdbinit.txt
