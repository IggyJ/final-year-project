#define CPU_FREQ 4000000U

#include "defines.h"
#include "ssd1306.h"


#define SCREEN_WIDTH 128 
#define SCREEN_HEIGHT 64
#define SCREEN_ADDR_W (0x3c << 1)
#define SCREEN_ADDR_R ((0x3c << 1) | 0x01)

#define BUTTON_JMP 0x02
#define BUTTON_PAUSE 0x04


void uart_send_byte(unsigned char data) {
    while (!(UART_FLAG & UART_FLAG_TX_READY));
    UART_TXD = data;
    UART_FLAG |= UART_FLAG_TX_DATA;
}


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
    i2c_send(SSD1306_ADDR_MODE);
    i2c_send(0x00);
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


typedef struct Cursor {
    unsigned char col, page;
} Cursor;


Cursor set_cursor(unsigned char col, unsigned char page) {
    i2c_start(SCREEN_ADDR_W);
	i2c_send(0x00);
	i2c_send(SSD1306_START_COL_L | (col & 0x0f));
	i2c_send(SSD1306_START_COL_H | (col >> 4));
	i2c_send(SSD1306_START_PAGE  | page);
	i2c_stop();

    return (Cursor){col, page};
}


void clear_display() {
    set_cursor(0, 0);
    for (int i = 0; i < 8; i++) {
        i2c_start(SCREEN_ADDR_W);
        i2c_send(0x40);
        for (int j = 0; j < 128; j++) i2c_send(0x00);
        i2c_stop();
    }
    return;
}


static inline void clear_frame_buffer(unsigned char frame_buffer[]) {
    for (int i = 0; i < 1024; i++) frame_buffer[i] = 0x00;
    return;
}

static inline void display_frame_buffer(unsigned char frame_buffer[]) {
    set_cursor(0, 0);
    for (int i = 0; i < 8; i++) {
        i2c_start(SCREEN_ADDR_W);
        i2c_send(0x40);
        for (int j = 0; j < 128; j++) i2c_send(frame_buffer[(128 * i) + j]);
        i2c_stop();
    }
    return;
}


void draw_sprite_misaligned_alpha(unsigned char frame_buffer[], const unsigned char sprite[], unsigned char x, unsigned char y, unsigned char w) {
    if (y > 63 || x > 127) return;

    unsigned char page = y / 8;
    unsigned char offset = y % 8;

    for (unsigned char i = 0; i < w; i++) {
        frame_buffer[(128 * page) + x + i] |= sprite[i] << offset;
    }

    if (page != 7) {
        page++;
        for (unsigned char i = 0; i < w; i++) {
            frame_buffer[(128 * page) + x + i] |= (sprite[i] >> (8 - offset));
        }
    }

    return;
}


void draw_sprite_aligned(unsigned char frame_buffer[], const unsigned char sprite[], unsigned char x, unsigned char y, unsigned char w) {
    if (y > 63 || x > 127) return;

    unsigned char page = y / 8;

    for (int i = 0; i < w; i++) {
        frame_buffer[(128 * page) + x + i] = sprite[i];
    }

    return;
}


void draw_pipe(unsigned char frame_buffer[], int x, int y) {
    if (x < -7 || x > 127) return;

    int page = y >> 3;
    // unsigned char offset = y % 8;

    for (int p = 0; p < 8; p++) {
        if (p >= page - 1 && p <= page + 1) continue;

        for (int i = 0; i < 8; i++) {
            int x_col = x + i;
            if (x_col > 127) break;
            if (x_col < 0) continue;
            int index = (128 * p) + x_col;
            if (index >= 0 && index < 1024) frame_buffer[index] = 0xff;
        }
    }

    return;
}


int main() {
    const unsigned char bm_bird_0[] = {0x08, 0x18, 0x28, 0x48, 0x64, 0x42, 0x3c, 0x08};
    const unsigned char bm_bird_1[] = {0x40, 0x60, 0x50, 0x48, 0x64, 0x42, 0x3c, 0x08};
    const unsigned char bm_fps_0[] = {0x7f, 0x09, 0x09, 0x00, 0x7f, 0x09, 0x09, 0x06};
    const unsigned char bm_fps_1[] = {0x00, 0x26, 0x49, 0x49, 0x32, 0x00, 0x14, 0x00};
    const unsigned char bm_0[] = {0x1c, 0x22, 0x41, 0x41, 0x22, 0x1c};
    const unsigned char bm_1[] = {0x00, 0x00, 0x42, 0x7f, 0x40, 0x00};
    const unsigned char bm_2[] = {0x62, 0x51, 0x49, 0x49, 0x49, 0x46};
    const unsigned char bm_3[] = {0x22, 0x41, 0x49, 0x49, 0x49, 0x36};
    const unsigned char bm_4[] = {0x18, 0x14, 0x12, 0x7f, 0x10, 0x00};
    const unsigned char bm_5[] = {0x37, 0x45, 0x45, 0x45, 0x45, 0x39};
    const unsigned char bm_6[] = {0x3e, 0x49, 0x49, 0x49, 0x49, 0x32};
    const unsigned char bm_7[] = {0x01, 0x41, 0x21, 0x11, 0x09, 0x07};
    const unsigned char bm_8[] = {0x36, 0x49, 0x49, 0x49, 0x49, 0x36};
    const unsigned char bm_9[] = {0x06, 0x09, 0x49, 0x49, 0x29, 0x1e};
    const unsigned char* bm_num_inedex[10];
    bm_num_inedex[0] = bm_0;
    bm_num_inedex[1] = bm_1;
    bm_num_inedex[2] = bm_2;
    bm_num_inedex[3] = bm_3;
    bm_num_inedex[4] = bm_4;
    bm_num_inedex[5] = bm_5;
    bm_num_inedex[6] = bm_6;
    bm_num_inedex[7] = bm_7;
    bm_num_inedex[8] = bm_8;
    bm_num_inedex[9] = bm_9;

    unsigned char frame_buffer[1024];

    uart_set_baud(38400U);
    i2c_set_speed(400000U);
    
    
    unsigned int t_frame = 4096;
    unsigned int t_frame_last = 0;
    unsigned int fps;

    unsigned char bird_y = 128;
    signed char bird_vel = 0;

    signed char pipes_y[6] = {30,  40,  40,  30,  20,  30};
    signed char pipes_x[6] = {0,   43,  85,  128,  171, 213};

    int paused = 1;

    display_init();
    clear_display();

    for (;;) {
        // Caclulate frame time
        t_frame_last = t_frame;
        t_frame = get_cycles_32();
        fps = CPU_FREQ / (t_frame - t_frame_last);

        // Clear canvas for new frame
        clear_frame_buffer(frame_buffer);

        // Pause logic
        if (!(BUTTON & BUTTON_PAUSE)) {
            paused = !paused;
            delay_ms(200);
        }
        if (paused) LED = 0xff;
        else LED = 0x00;

        // Move bird
        if (!paused) {
            if (bird_vel < 16) bird_vel += 1;
            if (!(BUTTON & BUTTON_JMP) && (bird_vel > 2)) bird_vel = -8;
            bird_y += bird_vel;
        }

        
        // Draw bird
        if (bird_vel >= 0)
            draw_sprite_misaligned_alpha(frame_buffer, bm_bird_0, 18, (bird_y >> 2), sizeof(bm_bird_0));
        else
            draw_sprite_misaligned_alpha(frame_buffer, bm_bird_1, 18, (bird_y >> 2), sizeof(bm_bird_0));


        // Draw and move pipes
        for (int i = 0; i < 6; i++) {
            draw_pipe(frame_buffer, (int)pipes_x[i], (int)pipes_y[i]);
            if (!paused) pipes_x[i]--;
        }

        // Draw FPS counter
        draw_sprite_aligned(frame_buffer, bm_fps_0, 0, 0, sizeof(bm_fps_0));
        draw_sprite_aligned(frame_buffer, bm_fps_1, 8, 0, sizeof(bm_fps_1));
        draw_sprite_aligned(frame_buffer, bm_num_inedex[(fps % 100) / 10], 17, 0, 6);
        draw_sprite_aligned(frame_buffer, bm_num_inedex[fps % 10], 24, 0, 6);

        // Update display
        display_frame_buffer(frame_buffer);
    }

    return 0;
}