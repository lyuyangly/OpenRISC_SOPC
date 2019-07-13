OUTPUT_FORMAT("elf32-or32")
OUTPUT_ARCH(or32)
ENTRY(_reset)

MEMORY
{
    RAM (rwx)  : ORIGIN = 0x0, LENGTH = 8K
    DRAM (rwx) : ORIGIN = 0x10000000, LENGTH = 8M
}

STACK_SIZE = 2K;

SECTIONS
{
    .text :
    {
        _stext = .;
        stext = .;
        *(.text)
        *(.text.*)
        . = ALIGN(4);
        _etext = .;
        etext = .;
    } > RAM

    .rodata :
    {
        _sdata = .;
        sdata = .;
        . = ALIGN(4);
        *(.rodata)
        *(.rodata.*)
    } > RAM

    .data :
    {
        *(.sdata)
        *(.data)
        *(.rwdata)
        *(.got.plt) *(.got)
        *(.shdata)
        *(.data.* .gnu.linkonce.d.*)
        . = ALIGN (4);
        _edata  =  .;
        edata  =  .;
    } > RAM

    .bss :
    {
        . = ALIGN(4);
        __bss_start = .;
        *(.sbss .sbss.*)
        *(.bss .bss.*)
        *(COMMON)
        . = ALIGN (4);
        __bss_end = .;
    } > RAM

    .stack : ALIGN(4)
    {
        . += STACK_SIZE;
        __stack_pointer = .;
    } > RAM
}

