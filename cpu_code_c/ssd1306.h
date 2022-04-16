#ifndef _SSD1306_H_
#define _SSD1306_H_

/* Fundamental commands */
#define SSD1306_CONTRAST 0x81
#define SSD1306_RESUME   0xa4
#define SSD1306_ENTIRE   0xa5
#define SSD1306_NORMAL   0xa6
#define SSD1306_INVERSE  0xa7
#define SSD1306_DISP_OFF 0xae
#define SSD1306_DISP_ON  0xaf

/* Scrolling commands */
#define SSD1306_SCROLL_RH  0x26 // Right horizontal
#define SSD1306_SCROLL_LH  0x27 // Left horizontal 
#define SSD1306_SCROLL_RV  0x29 // Right vertical
#define SSD1306_SCROLL_LV  0x2a // Left vertical
#define SSD1306_SCROLL_OFF 0x2e
#define SSD1306_SCROLL_ON  0x2f
#define SSD1306_SCROLL_A   0xa3 // Vertical scroll area

/* Address setting commands */
#define SSD1306_START_COL_L 0x00
#define SSD1306_START_COL_H 0x10
#define SSD1306_ADDR_MODE   0x20
#define SSD1306_RANGE_COL   0x21
#define SSD1306_RANGE_PAGE  0x22
#define SSD1306_START_PAGE  0xb0

/* Hardware configuration commands */
#define SSD1306_START_LINE 0x40
#define SSD1306_SEG_REMAP  0xa0
#define SSD1306_MUX_RATIO  0xa8
#define SSD1306_COM_NORMAL 0xc0
#define SSD1306_COM_REMAP  0xc8
#define SSD1306_OFFSET     0xd3
#define SSD1306_COM_PINS   0xda

/* Timing & driving commands */
#define SSD1306_OSC_FREQ  0xd5
#define SSD1306_PRECHARGE 0xd9
#define SSD1306_VCOMH     0xdb
#define SSD1306_NOP       0xe3

/* Advanced graphics commands */
#define SSD1306_FADE 0x23
#define SSD1306_ZOOM 0xd6

/* Charge pump commands */
#define SSD1306_CHARGE_PUMP 0x8d

#endif