#include "defines.h"

#define CPU_FREQ 4000000U

void send_byte(unsigned char data) {
    while (!(UART_FLAG & UART_FLAG_TX_READY));
    UART_TXD = data;
    UART_FLAG |= UART_FLAG_TX_DATA;
}

int main() {
    UART_BAUD = CPU_FREQ / 9600;

    send_byte(0xff);
    send_byte(0xff);
    send_byte(0x00);

    volatile unsigned int a = 0;
    volatile unsigned int b = 1;
    volatile unsigned int c;

    while (1) {
        c = a + b;
        a = b;
        b = c;

        LED = 0x01;

        for (int i = 0; i < 4; i++) send_byte(c >> (i * 8));
        // send_byte('\n');

        LED = 0x00;

        delay_s(1);
    }
    return 0;
}