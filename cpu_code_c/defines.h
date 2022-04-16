#ifndef _DEFINES_H_
#define _DEFINES_H_

/* Define size_t as unsigned 32 bit integer */
typedef unsigned int size_t;

/* Helper macros to write data to RAM */
#define WRITE_WORD(addr, value) (*((volatile unsigned int*)(addr)) = value)
#define WRITE_HALFWORD(addr, value) (*((volatile unsigned short*)(addr)) = value)
#define WRITE_BYTE(addr, value) (*((volatile unsigned char*)(addr)) = value)

/* Helper macros to read data from RAM */
#define READ_WORD(addr) (*((volatile unsigned int*)(addr)))
#define READ_HALFWORD(addr) (*((volatile unsigned short*)(addr)))
#define READ_BYTE(addr) (*((volatile unsigned char*)(addr)))

/* LED register (8-bit) */
#define LED (*(volatile unsigned char*)(0x04000000))

/*   UART baud rate configuration register
    UART_BAUD = CPU_FREQ / DESIRED BAUD RATE */
#define UART_BAUD (*(volatile unsigned short*)(0x04000004))

/*           UART configuration register (8-bit)
               Default Value = 00011000 (0x18)
|-------------------------------------------------------|
|  3 bits  |   2 bits   |  1 bit  |  1 bit  |   1 bit   |
|          | Data Width |    Parity Bit     | Stop Bits |
|--------- |------------|-------------------|-----------|
| (unused) | 00: 5 bits | 0: none   0: even | 0: 1 bit  |
|          | 01: 6 bits | 1: 1 bit  1: odd  | 1: 2 bits |
|          | 10: 7 bits |                   |           |
|          | 11: 8 bits |                   |           |
|-------------------------------------------------------|*/
#define UART_CONF (*(volatile unsigned char*)(0x04000006))
#define UART_CONF_WIDTH_6  0x08
#define UART_CONF_WIDTH_7  0x10
#define UART_CONF_WIDTH_8  0x18
#define UART_CONF_PARITY_E 0x04
#define UART_CONF_PARITY_O 0x06
#define UART_CONF_STOP_BIT 0x01

/*          UART flags register (8-bit)
|-----------------------------------------------------|
|  1 bit   |  1 bit  |  1 bit  |   1 bit   |  4 bits  |
|----------|---------|---------|-----------|----------|
| TX ready | TX data | RX data | RX Parity | (unused) |
|    R     |    W    |   R/W   |    R      |          |
|------------------------------------------|----------|*/
#define UART_FLAG (*(volatile unsigned char*)(0x04000007))
#define UART_FLAG_TX_READY 0x80
#define UART_FLAG_TX_DATA  0x40
#define UART_FLAG_RX_DATA  0x20
#define UART_FLAG_RX_ERROR 0x10

/* UART receive buffer (8-bit) */
#define UART_RXD  (*(volatile unsigned char*)(0x04000008))

/* UART transmit buffer (8-bit) */
#define UART_TXD  (*(volatile unsigned char*)(0x04000009))

#define uart_tx_wait_for_ready() while (!(UART_FLAG & UART_FLAG_TX_READY))
#define uart_rx_wait_for_data()  while (!(UART_FLAG & UART_FLAG_RX_DATA))


/*    I2C clock speed configuration register
    I2C_SPEED = CPU_FREQ / DESIRED CLOCK SPEED */
#define I2C_SPEED (*(volatile unsigned short*)(0x0400000a))

/*  I2C configuration register (8-bit)
    Default Value = 00000000 (0x00)
|-----------------------|
|  1 bit   |   7 bits   |
|----------|------------|
|  Slave   |  (unused)  |
|   Mode   |            |
|-----------------------|*/
#define I2C_CONF (*(volatile unsigned char*)(0x0400000c))

/*                I2C flags register (8-bit)
|--------------------------------------------------------------------------|
|  1 bit   |  1 bit  |  1 bit  |  1 bit   |  1 bit  |   1 bit   |  2 bits  |
|----------|---------|---------|----------|---------|-----------|----------|
|  Ready   |  Start  |   ACK   | Continue |   Stop  | Read Data | (unused) |
|    R     |    W    |    R    |    W     |   R/W   |     R     |          |
|--------------------------------------------------------------------------|*/
#define I2C_FLAG (*(volatile unsigned char*)(0x0400000d))
#define I2C_FLAG_READY 0x80
#define I2C_FLAG_START 0x40
#define I2C_FLAG_ACK   0x20
#define I2C_FLAG_CONT  0x10
#define I2C_FLAG_STOP  0x08
#define I2C_FLAG_RDATA 0x04

/* I2C data buffer */
#define I2C_DATA (*(volatile unsigned char*)(0x0400000e))

/*   I2C slave address (used in slave mode only
          Default Value = 00000000 (0x00)              */
#define I2C_ADDR (*(volatile unsigned char*)(0x0400000f))


/* BUTTON register (8-bit) */
#define BUTTON (*(volatile unsigned char*)(0x04000020))


#ifdef CPU_FREQ

/* Delay for s seconds */
// static inline void delay_s(unsigned int s) { for (volatile unsigned int i = 0; i < ((CPU_FREQ * s) / 6); i++); return; };

/* Delay for ms miliseconds */
// static inline void delay_ms(unsigned int ms) { for (volatile unsigned int i = 0; i < ((CPU_FREQ * ms) / 6000); i++); return; };

/* Delay for s seconds */
static inline void delay_s(unsigned int s) {
    unsigned int t_start, t_now, t_len;
    __asm__ volatile ("rdcycle %0" :"=r"(t_start));
    t_len = CPU_FREQ * s;

    do {
        __asm__ volatile ("rdcycle %0" :"=r"(t_now));
    } while(t_now - t_start < t_len);

    return;
};

/* Delay for ms miliseconds */
static inline void delay_ms(unsigned int ms) {
    unsigned int t_start, t_now, t_len;
    __asm__ volatile ("rdcycle %0" :"=r"(t_start));
    t_len = (CPU_FREQ / 1000) * ms;

    do {
        __asm__ volatile ("rdcycle %0" :"=r"(t_now));
    } while(t_now - t_start < t_len);
    
    return;
};

/* Delay for us microseconds */
static inline void delay_us(unsigned int us) {
    unsigned int t_start, t_now, t_len;
    __asm__ volatile ("rdcycle %0" :"=r"(t_start));
    t_len = (CPU_FREQ / 1000000) * us;

    do {
        __asm__ volatile ("rdcycle %0" :"=r"(t_now));
    } while(t_now - t_start < t_len);
    
    return;
};

/* Set UART module baud rate to b */
#define uart_set_baud(b) (UART_BAUD = CPU_FREQ / b)

/* Set I2C module clock speed to c */
#define i2c_set_speed(c) (I2C_SPEED = CPU_FREQ / c)

#endif

/* Returns number of cycles elapsed since cpu reset as a 32 bit unsigned int */
static inline unsigned int get_cycles_32() {
    unsigned int cycles;
    __asm__ volatile ("rdcycle %0" :"=r"(cycles));
    return cycles;
};


/* Returns number of cycles elapsed since cpu reset as a 64 bit unsigned int */
static inline unsigned long long get_cycles_64() {
    unsigned long cycles_h, cycles_l;
    __asm__ volatile ("rdcycle %0" :"=r"(cycles_l));
    __asm__ volatile ("rdcycleh %0" :"=r"(cycles_h));

    return ((unsigned long long)cycles_h << 32) | cycles_l;
};


#endif