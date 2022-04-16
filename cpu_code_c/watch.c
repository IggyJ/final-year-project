#define CPU_FREQ 4000000U

#include "defines.h"
#include "ssd1306.h"

#define SCREEN_WIDTH 128 
#define SCREEN_HEIGHT 64
#define SCREEN_ADDR_W (0x3c << 1)
#define SCREEN_ADDR_R ((0x3c << 1) | 0x01)


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


void display_init() {
    delay_ms(150);

    i2c_start(SCREEN_ADDR_W);
	i2c_send(0x00);
    i2c_send(SSD1306_DISP_OFF);
    i2c_send(SSD1306_MUX_RATIO);   // Set MUX ratio
	i2c_send(SCREEN_HEIGHT - 1);
    i2c_send(SSD1306_OFFSET);
    i2c_send(0x00);
	i2c_send(SSD1306_START_LINE);  // Set start line
	i2c_send(SSD1306_SEG_REMAP | 0x01); // Set segment re-map (left)
	i2c_send(SSD1306_COM_REMAP);  // Set COM output scan direction
	i2c_send(SSD1306_COM_PINS);    // COM pin configuration
	i2c_send(0x12);
	i2c_send(SSD1306_CONTRAST);    // Set contrast
	i2c_send(0x7f);
	i2c_send(SSD1306_RESUME);      // Resume display
	i2c_send(SSD1306_OSC_FREQ);    // Set oscillator frequency
	i2c_send(0x80);
    i2c_stop();

    delay_ms(150);

	i2c_start(SCREEN_ADDR_W);
	i2c_send(0x00);
    i2c_send(SSD1306_CHARGE_PUMP);
    i2c_send(0x14);
    i2c_send(SSD1306_DISP_ON);
    i2c_stop();

    delay_ms(150);

    return;
}

void display_char(int n, const unsigned char* bitmap_index[]) {
    i2c_start(SCREEN_ADDR_W);
	i2c_send(0x40);
    for (int i = 0; i < 8; i++)
        i2c_send(bitmap_index[n][i]);
    i2c_stop();

    return;
};


void set_cursor(int col, int row) {
    if (row > 7 || col > 16)
        return;

    int col_addr = col << 3;

    i2c_start(SCREEN_ADDR_W);
	i2c_send(0x00);
	i2c_send(SSD1306_START_COL_L | (col_addr & 0x0f));
	i2c_send(SSD1306_START_COL_H | (col_addr >> 4));
	i2c_send(SSD1306_START_PAGE  | row);
	i2c_stop();

    return;
}


void display_time(unsigned int h, unsigned int m, unsigned int s, const unsigned char* bitmap_index[]) {
    set_cursor(4, 3);
    display_char(h / 10, bitmap_index);
    display_char(h % 10, bitmap_index);
    display_char(10, bitmap_index);
    display_char(m / 10, bitmap_index);
    display_char(m % 10, bitmap_index);
    display_char(10, bitmap_index);
    display_char(s / 10, bitmap_index);
    display_char(s % 10, bitmap_index);
    return;
}


void display_bpm(unsigned int bpm, const unsigned char* bitmap_index[]) {
    set_cursor(6, 5);
    display_char(11, bitmap_index);
    display_char((bpm % 256)/ 100, bitmap_index);
    display_char((bpm % 100) / 10, bitmap_index);
    display_char(bpm % 10, bitmap_index);
    return;
}


void clear_display() {
    for (int i = 0; i < 8; i++) {
        set_cursor(0, i);
        i2c_start(SCREEN_ADDR_W);
        i2c_send(0x40);
        for (int j = 0; j < 128; j++) i2c_send(0x00);
        i2c_stop();
    }
    return;
}


int main(void) {
    const unsigned char char_0[] = {0x00, 0x1c, 0x22, 0x41, 0x41, 0x22, 0x1c, 0x00};
    const unsigned char char_1[] = {0x00, 0x00, 0x00, 0x42, 0x7f, 0x40, 0x00, 0x00};
    const unsigned char char_2[] = {0x00, 0x62, 0x51, 0x49, 0x49, 0x49, 0x46, 0x00};
    const unsigned char char_3[] = {0x00, 0x22, 0x41, 0x49, 0x49, 0x49, 0x36, 0x00};
    const unsigned char char_4[] = {0x00, 0x18, 0x14, 0x12, 0x7f, 0x10, 0x00, 0x00};
    const unsigned char char_5[] = {0x00, 0x37, 0x45, 0x45, 0x45, 0x45, 0x39, 0x00};
    const unsigned char char_6[] = {0x00, 0x3e, 0x49, 0x49, 0x49, 0x49, 0x32, 0x00};
    const unsigned char char_7[] = {0x00, 0x01, 0x41, 0x21, 0x11, 0x09, 0x07, 0x00};
    const unsigned char char_8[] = {0x00, 0x36, 0x49, 0x49, 0x49, 0x49, 0x36, 0x00};
    const unsigned char char_9[] = {0x00, 0x06, 0x09, 0x49, 0x49, 0x29, 0x1e, 0x00};
    const unsigned char char_colon[] = {0x00, 0x00, 0x00, 0x00, 0x24, 0x00, 0x00, 0x00};
    const unsigned char char_heart[] = {0x0e, 0x11, 0x21, 0x42, 0x21, 0x11, 0x0e, 0x00};
    const unsigned char* bitmap_index[] = {char_0, char_1, char_2, char_3, char_4, char_5, char_6, char_7, char_8, char_9, char_colon, char_heart};

	i2c_set_speed(400000U);

    display_init();

    clear_display();

    unsigned int seconds = 0;
    unsigned int minutes = 23;
    unsigned int hours = 11;
    unsigned int bpm = 69;

	for (;;) {
        if (seconds == 60) {
            seconds = 0;
            minutes++;
        }
        if (minutes == 60) {
            minutes = 0;
            hours++;
        }
        if (hours == 24) hours = 0;

        display_time(hours, minutes, seconds, bitmap_index);
        display_bpm(bpm, bitmap_index);

        seconds++;
        // bpm ^= bpm >> 3;
        // bpm ^= bpm << 5;

        delay_ms(1000);
    }

	return 0;
}