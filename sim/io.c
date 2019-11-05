#include <stdio.h>

#define UART_DATA       0x10000
#define UART_STATE      0x10004

unsigned int io_read(unsigned int addr) {
    if (addr == UART_STATE) {
        return -1;
    }

    return 0;
}

void io_write(unsigned int addr, unsigned data) {
    if (addr == UART_DATA) {
        printf("%c", data & 0xFF);
    }
}
