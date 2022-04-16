#define CPU_FREQ 4000000U

#include "defines.h"


void send_byte(unsigned char data) {
    while (!(UART_FLAG & UART_FLAG_TX_READY));
    UART_TXD = data;
    UART_FLAG |= UART_FLAG_TX_DATA;
}

int main() {
    uart_set_baud(9600);
    UART_CONF = UART_CONF_WIDTH_7 ;

    const unsigned char msg1[8] = "Hello fr";
    const unsigned char msg2[8] = "om the C";
    const unsigned char msg3[4] = "PU!\n";

    while (1) {
        LED = 0x01;
        for (int c = 0; c < 8; c++) send_byte(msg1[c]);
        for (int c = 0; c < 8; c++) send_byte(msg2[c]);
        for (int c = 0; c < 4; c++) send_byte(msg3[c]);
        LED = 0x00;
        delay_s(1);
    }

    return 0;
}
