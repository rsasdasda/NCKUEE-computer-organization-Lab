.text

main: 
     # a : t0 , b : t1 , c : t2 , d: t3 , sum  : t4 , temp_1 : t5 , temp_2 : t6
     
    li t0, 10 # Let a = 10
    li t1, -16 # Let b = -16
    li t2, -40 # Let c =-40
    
    slli t3,t0,30
    srli t3,t3,30         
    
    li t4, 0 # Let sum = 0 

    slli t4,t1,3 # sum = b*8
    srli t4,t0,3 # sum = b*8 + a/8
    
    srli t5,t1,2
    addi t5,t5,36 # temp 1 save 一大串
    
    slli t6,t5,3
    add  t6,t6,t5  #  把一串乘以9倍加入temp_2    
    
    add t4,t4,t6 # sum = b*8 + a/8 + 9*一大串

    slli t5,t0,1 # temp_1 = 2*a
    srli t6,t0,1 # temp_2 = 0.5a

    add t5,t5,t0 # temp_1 = 2a + a
    add t5,t5,t6 # temp_1 = 3a + 0.5a

    add t4,t4,t5 # sum  = b*8 + a/8 + 9*一大串 +3.5a

    addi t4,t4,40 # sum = 前面+ abs(c)

    sub t4,t4,t3 # end

    add t0,t4,0 # Let x_5 = sum



    ret
