.data
num_test: .word 5
test1: .word -10
test2: .word 0
test3: .word 1
test4: .word 5
test5: .word 10

.text
setup:
    li    ra, -1
    li    sp, 0x7ffffff0
main:
    #######################
    #   t0 : num_test
    #   t1 : test_addr
    #   t2 : ans_addr
    #   t3 : i
    #   t4 : n 
    #   t5 : result
    #######################

    #save ra            ##main function ra
    addi sp, sp, -3
    sw ra, 0(sp)

    #Initilalize
    la t0, num_test
    lw t0, 0(t0)
    la t1, test1
    li t2, 0x01000000

    #For loop
    li t3, 0                #i = 0
    beq t0, x0, END_FOR     #if test1
FOR_LOOP:
    lw t4, 0(t1)            #n = MEM[0+test_addr]
    addi t1, t1, 4          #test_addr++
    mv a0, t4               #a0 = n

    #caller saved            ##Factorial 
    addi sp, sp, -24
    sw t5, 0(sp)
    sw t4, 4(sp)
    sw t3, 8(sp)
    sw t2, 12(sp)
    sw t1, 16(sp)
    sw t0, 20(sp)

    #FUNCTION call
    jal ra, FUNC_FACTORIAL

    #retrieve caller saved
    lw t5, 0(sp)
    lw t4, 4(sp)
    lw t3, 8(sp)
    lw t2, 12(sp)
    lw t1, 16(sp)
    lw t0, 20(sp)
    addi sp, sp, 24

    mv t5, a0           #result = a0 (return value)

    #Save answer 
    sw t5, 0(t2)        #save result
    addi t2, t2, 4      #ans_addr++

    addi t3, t3, 1      #i++
    blt t3, t0, FOR_LOOP
END_FOR:
    #retrieve ra
    lw ra, 0(sp)
    addi sp, sp, -4

    #return
    ret

FUNC_FACTORIAL:
    ############################################
    # < Function >
    #  Do factorial calculation through recursive
    #   n * (n-1) * (n-2)...........* 1
    #
    # < Parameter >
    #   a0 : n
    #
    # < Return Value >
    #   a0 : n * factorial (n - 1)
    #
    ###########################################
    # <Local Variable >
    # t0 : n
    # t1 : factorial (n - 1)
    ###########################################

    ##Save ra
    addi sp, sp, -4
    sw ra, 0(sp)

    mv t0, a0               # t0 = n
    addi t1, t0, -1         # t1 = n - 1
    blt t0, x0, END_IF_1    #if (n < 0)
    beq t0, x0, END_IF_2    #if (n == 0)
    beq t1, x0, END_IF_2    #if (n == 1)

    ##Caller saved
    addi sp, sp, -4
    sw t0, 0(sp)            #Save n 

    mv a0, t1               #a0 = n - 1
    jal ra , FUNC_FACTORIAL   #recursive

    ##Get return value
    mv t1, a0               #t1 (n-1) = factorial (n - 1)

    ##Retrieve caller saved
    lw t0, 0(sp)
    addi sp, sp, 4          #t0 = n 

    ##Caller saved and ra
    addi sp, sp, -12
    sw ra, 8(sp)
    sw t0, 4(sp)
    sw t1, 0(sp)

    mv a1, t0
    mv a2, t1

    jal ra, FUNC_MUL        ##now a1 = n, a2 = n - 1 ,return a1 = n *(n - 1) 

    ##retrieve caller saved and ra
    lw ra, 8(sp)
    lw t0, 4(sp)
    lw t1, 0(sp)
    addi sp, sp, 12
    mv a0, a1
END_LOOP:
    #retrieve ra
    lw ra, 0(sp)
    addi sp, sp, 4

    #return
    ret

END_IF_1:
    li a0, -1
    jal x0, END_LOOP
END_IF_2:
    li a0, 1
    jal x0, END_LOOP

FUNC_MUL:
    #######################################################
    # < Function >
    #    It can handle multiplication of 2 integer variables
    #
    # < Parameters >
    #    a1 : multiplicand
    #    a2 : multiplier
    #
    # < Return Value >
    #    a1 : result
    #######################################################
    # < Local Variable >
    #    t0 : mask_a
    #    t1 : mask_b
    #    t2 : abs(multiplicand) / smaller one 
    #    t3 : abs(multiplier) / bigger one
    #    t4 : mask_result
    #    t5 : i
    #    t6 : result
    #######################################################
    
    ## Save ra & Callee Saved
    # No use saved registers -> No need to do Callee Saved
    addi    sp, sp, -4               # Allocate stack space
                                     # sp = @sp - 4
    sw      ra, 0(sp)                # @ra -> MEM[@sp - 4]
    
    ## abs(multiplicand)
    srai    t0, a1, 31               # t0 = 0xffffffff(-) / 0(+)
    xor     t2, a1, t0               # Inverse(-) / Keep(+)
    sub     t2, t2, t0               # -(-1) / -0
                                     # t2 = abs(multiplicand)
    
    ## abs(multiplier)
    srai    t1, a2, 31               # t1 = 0xffffffff(-) / 0(+)
    xor     t3, a2, t1               # Inverse(-) / Keep(+)
    sub     t3, t3, t1               # t3 = abs(multiplier) 
    
    ## mask_result
    xor     t4, t0, t1               # t4 = 0xffffffff(-) / 0(+)
    
    ## array[2] = {a, b}
    addi    sp, sp, -8               # Allocate stack space
                                     # sp = @sp - 12
    sw      t3, 4(sp)                # t3 -> MEM[@sp - 8]
    sw      t2, 0(sp)                # t2 -> MEM[@sp - 12]
    
    ############### Call Function Procedure ###############
    # Caller Saved
    addi    sp, sp, -4               # Allocate stack space
                                     # sp = @sp - 16
    sw      t4, 0(sp)                # t4 -> MEM[@sp - 16]
    
    # Pass Arguments
    addi    a2, sp, 4                # a2 = &array
    
    # Jump to Callee
    jal     ra, FUNC_TWO_SORT        # ra = Addr(lw  t4, 0(sp))
    #######################################################
    
    # Retrieve Caller Saved
    lw      t4, 0(sp)                # t4(mask_result)
    lw      t2, 4(sp)                # t2 = smaller one 
    lw      t3, 8(sp)                # t3 = bigger one
    
    ## Do multiplication through successive addition
    li      t5, 0                    # t5(i) = 0
    li      t6, 0                    # t6(result) = 0
    bge     t5, t2, FMUL_endWhile_1  # if (i >= smaller), go to endWhile
FMUL_while_1:
    add     t6, t6, t3               # result += bigger
    addi    t5, t5, 1                # i++
    blt     t5, t2, FMUL_while_1     # if (i < smaller), go to while
FMUL_endWhile_1: 
    
    ## Now, t6 = abs(result)
    ## Append sign on the t6
    xor     t6, t6, t4               # Inverse(-) / Keep(+)
    sub     t6, t6, t4               # -(-1) / -0
                                     # t6 = result
                                     
    ## Pass return value
    mv      a1, t6                   # a2(return value) = t6
                                     
    ## Retrieve ra & Callee Saved
    lw      ra, 12(sp)               # ra = @ra
    addi    sp, sp, 16               # sp = @sp
    
    ## return
    ret                              # jalr  x0, ra, 0
    
    
FUNC_TWO_SORT:
    #######################################################
    # < Function >
    #    Do sorting
    #    * Put the smaller one in *array
    #    * Put the bigger one in *(array+1)
    #
    # < Parameters >
    #    a0 : int *array
    #
    # < Return Value >
    #    NULL
    #######################################################
    # < Local Variable >
    #    t0 : a
    #    t1 : b
    #######################################################
    
    ## Save ra & Callee Saved
    # No Function Call -> No need to save ra
    # No use saved registers -> No need to do Callee Saved
    
    lw      t0, 0(a0)                # a = *array
    lw      t1, 4(a0)                # b = *(array+1)
    
    bleu    t0, t1, FUNC_TWO_EXIT    # if a <= b, no need to swap
     
    sw      t1, 0(a0)                # smaller -> *array
    sw      t0, 4(a0)                # bigger -> *(array+1)
FUNC_TWO_EXIT:
    ret                              # return
    