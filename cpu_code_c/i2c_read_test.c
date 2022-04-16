#define CPU_FREQ 4000000U

#include "defines.h"


#define MAX30100_INT_STATUS     0x00  // Which interrupts are tripped
#define MAX30100_INT_ENABLE     0x01  // Which interrupts are active
#define MAX30100_FIFO_WR_PTR    0x02  // Where data is being written
#define MAX30100_OVRFLOW_CTR    0x03  // Number of lost samples
#define MAX30100_FIFO_RD_PTR    0x04  // Where to read from
#define MAX30100_FIFO_DATA      0x05  // Ouput data buffer
#define MAX30100_MODE_CONFIG    0x06  // Control register
#define MAX30100_SPO2_CONFIG    0x07  // Oximetry settings
#define MAX30100_LED_CONFIG     0x09  // Pulse width and power of LEDs
#define MAX30100_TEMP_INTG      0x16  // Temperature value, whole number
#define MAX30100_TEMP_FRAC      0x17  // Temperature value, fraction
#define MAX30100_REV_ID         0xFE  // Part revision
#define MAX30100_PART_ID        0xFF  // Part ID, normally 0x11

#define MAX30100_ADDR_W 0xae
#define MAX30100_ADDR_R 0xaf


int i2c_start(unsigned char addr) {
    LED = 0x01;
    while (!(I2C_FLAG & I2C_FLAG_READY));
    I2C_DATA = addr;
    I2C_FLAG |= I2C_FLAG_START;
    LED = 0x02;
    while (!(I2C_FLAG & I2C_FLAG_ACK) && !(I2C_FLAG & I2C_FLAG_STOP));
    if (I2C_FLAG & I2C_FLAG_STOP) return -1;
    return 0;
} 

int i2c_send(unsigned char data) {
    LED = 0x03;
    while (!(I2C_FLAG & I2C_FLAG_READY));
    I2C_DATA = data;
    I2C_FLAG |= I2C_FLAG_CONT;
    LED = 0x04;
    // while (!(I2C_FLAG & I2C_FLAG_ACK) && !(I2C_FLAG & I2C_FLAG_STOP));
    delay_us(5);
    if (I2C_FLAG & I2C_FLAG_STOP) return -1;
    return 0;
}

unsigned char i2c_read() {
    LED = 0x05;
    while (!(I2C_FLAG & I2C_FLAG_READY));
    I2C_FLAG |= I2C_FLAG_CONT;
    LED = 0x06;
    while (!(I2C_FLAG & I2C_FLAG_RDATA));
    return I2C_DATA;
}

void i2c_stop() {
    I2C_FLAG |= I2C_FLAG_STOP;
    return;
}

void uart_send(unsigned char data) {
    while (!(UART_FLAG & UART_FLAG_TX_READY));
    UART_TXD = data;
    UART_FLAG |= UART_FLAG_TX_DATA;
}

void max30100_send(unsigned char reg, unsigned char value) {
    i2c_start(MAX30100_ADDR_W);
    i2c_send(reg);
    i2c_send(value);
    i2c_stop();
    return;
}


int main() {
    i2c_set_speed(400000U);
    uart_set_baud(38400U);

    max30100_send(MAX30100_MODE_CONFIG, 0x02);
    max30100_send(MAX30100_LED_CONFIG, 0x0e);
    max30100_send(MAX30100_SPO2_CONFIG, (0x01 << 2) | 0x03);

    for (;;) {
        unsigned char buffer[4];
        i2c_start(MAX30100_ADDR_W);
        i2c_send(MAX30100_FIFO_DATA);
        
        i2c_start(MAX30100_ADDR_R);
        for (int i = 0; i < 4; i++) {
            buffer[i] = i2c_read();
            delay_us(10);
        }
        i2c_stop();
        uart_send(buffer[0]);
        uart_send(buffer[1]);

        LED = 0x00;
        delay_ms(500);
    }


    return 0;
}