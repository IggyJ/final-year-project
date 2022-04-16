#define CPU_FREQ 4000000
#include "defines.h"

int main() {
    while (1) {
        LED = ~LED;
        delay_s(2);
    }
    return 0;
}