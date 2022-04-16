#define CPU_FREQ 4000000U

#include "defines.h"


unsigned char receive_byte() {
    while (!(UART_FLAG & UART_FLAG_RX_DATA));
    UART_FLAG &= ~UART_FLAG_RX_DATA;
    return UART_RXD;
}

int main() {
    UART_BAUD = CPU_FREQ / 9600;

    while (1) {
        LED = receive_byte();
    }

    return 0;
}
