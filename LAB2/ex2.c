#include <stdio.h>
#include <stdlib.h>
int main() {
    int *var = (int *)0x00000800;
    int *var1 = (int *)0x00000804;
    int tmp = -775687803; // 0xD1C3F185
    *var = tmp;
    tmp = 3365119; // 0x003358FF
    *var1 = tmp;

    asm volatile(
        "addi   sp, sp, -12"
        "addi   t3, zero, 1024"
        "slli   t3, t3, 1"
        "lb     t0, 0(t3)"
        "sh     t0, 0(sp)"
        "lhu    t1, 0(t3)"
        "sw     t1, 4(sp)"
        "lw     t2, 4(t3)"
        "sb     t2, 8(sp)"
        "addi   sp, sp, 12"
    );

    return 0;
}