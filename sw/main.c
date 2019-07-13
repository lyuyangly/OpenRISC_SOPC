#include <stdint.h>
#include "openrisc.h"
#include "uart16550.h"
#include "board.h"

extern int xmodemReceive(unsigned char*, int);

typedef void (*p_func)(void);

void delay(unsigned int t)
{
	volatile uint32_t i, j;
	for(i = 0; i < t; i++)
		for(j = 0; j < 1024; j++);
}

int main(void)
{
	volatile int st, num;

    p_func boot_main=(p_func)(DDR_BASE);

    // GPIO
	*((volatile uint32_t *)(GPIO_BASE + 8)) = 0xff;
	*((volatile uint32_t *)(GPIO_BASE + 4)) = 0xaa;

    // UART 115200 8N1
    uart_init(27);
    uart_puts("OpenRISC Boot ...\r\n");
    uart_puts("Download Your Program @ 0x10000000 in 20s by Xmodem.\r\n");

    delay(25000);

    st = xmodemReceive((unsigned char *)(DDR_BASE), 8192);

    if(st < 0) {
        *((volatile uint32_t *)(GPIO_BASE + 4)) = 0x55;
        uart_puts("Xmodem Receive FAIL ...\r\n");
    } else {
        *((volatile uint32_t *)(GPIO_BASE + 4)) = 0x55;
        uart_puts("\r\nOK, Boot From DDR_BASE ...");
        boot_main();    
    }

	while(1) {
		*((volatile uint32_t *)(DDR_BASE + 0x10)) = 0xaa;
		num = *((volatile uint32_t *)(DDR_BASE + 0x10));
		*((volatile uint32_t *)(GPIO_BASE + 4)) = num;
		delay(5000);
		*((volatile uint32_t *)(DDR_BASE + 0x10)) = 0x55;
		num = *((volatile uint32_t *)(DDR_BASE + 0x10));
        *((volatile uint32_t *)(GPIO_BASE + 4)) = num;
		delay(5000);
	}

	return 0;
}
