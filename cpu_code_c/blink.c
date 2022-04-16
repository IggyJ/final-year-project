#include "defines.h"

#define CPU_FREQ 4000000U


int main() {
    while (1) {      
        for (LED = 1;   LED != 0; LED = LED << 1) delay_ms(500);
        for (LED = 128; LED != 0; LED = LED >> 1) delay_ms(500);
    }
    return 0;
}