#define CPU_FREQ 4000000U

#include "defines.h"

int i2c_start(unsigned char addr) {
    while (!(I2C_FLAG & I2C_FLAG_READY));
    I2C_DATA = addr;
    I2C_FLAG |= I2C_FLAG_START;
    while (!(I2C_FLAG & I2C_FLAG_ACK) && !(I2C_FLAG & I2C_FLAG_STOP));
    if (I2C_FLAG & I2C_FLAG_STOP) return -1;
    return 0;
} 

int i2c_send(unsigned char data) {
    while (!(I2C_FLAG & I2C_FLAG_READY));
    I2C_DATA = data;
    I2C_FLAG |= I2C_FLAG_CONT;
    while (!(I2C_FLAG & I2C_FLAG_ACK) && !(I2C_FLAG & I2C_FLAG_STOP));
    if (I2C_FLAG & I2C_FLAG_STOP) return -1;
    return 0;
}

void i2c_stop() {
    I2C_FLAG |= I2C_FLAG_STOP;
    return;
}

int main() {
    i2c_set_speed(400000U);

    if (i2c_start(0xaa)) goto i2c_fail;
    if (i2c_send(0x55)) goto i2c_fail;
    if (i2c_send(0xf1)) goto i2c_fail;
    if (i2c_send(0x10)) goto i2c_fail;
    i2c_stop();

i2c_fail:
    while (1);

    return 0;
}