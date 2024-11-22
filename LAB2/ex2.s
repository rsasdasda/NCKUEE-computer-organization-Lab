.text
    // 初始化 var 和 var1 的記憶體地址
    li     t0, 0x00000080       // 將 0x80 的地址載入 t0 暫存器
    li     t1, 0x00000084       // 將 0x84 的地址載入 t1 暫存器

    // 設置 tmp 為 -775687803 (0xD1C3F185)
    li     t2, 0xD1C3F185       // 將立即數載入 t2 暫存器

    // 將 tmp 值存入 var (0x80)
    sw     t2, 0(t0)            // 將 t2 中的值存入 0x80

    // 設置 tmp 為 3365119 (0x003358FF)
    li     t2, 0x003358FF       // 將新值載入 t2 暫存器

    // 將 tmp 值存入 var1 (0x84)
    sw     t2, 0(t1)            // 將 t2 中的值存入 0x84

    // 以下是 asm volatile 部分的程式碼
    addi   sp, sp, -12
    addi   t3, zero, 1024
    slli   t3, t3, 1
    lb     t0, 0(t3)
    sh     t0, 0(sp)
    lhu    t1, 0(t3)
    sw     t1, 4(sp)
    lw     t2, 4(t3)
    sb     t2, 8(sp)
    addi   sp, sp, 12
    ret
