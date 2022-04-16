#include "defines.h"

#define CPU_FREQ 4000000U

int is_prime(unsigned int n) {
    for (unsigned int i = 2; i <= n/2; i++) {
        if (!(n % i)) return 0;
    }
    return 1;
}

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

    unsigned int number_to_test = 2;
    
    while (1) {
        if (is_prime(number_to_test)) {
            LED = 0x01;

            for (int i = 0; i < 4; i++) send_byte(number_to_test >> (i * 8));

            LED = 0x00;
        }
        number_to_test++;
        delay_ms(100);
    }

    return 0;
}
