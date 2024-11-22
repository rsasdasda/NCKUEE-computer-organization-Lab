.data
num_test: .word 18
test1: .word 0, 0                   #0,0
test2: .word 0, -2
test3: .word 0, 7
test4: .word 7, 0
test5: .word -3, 0
test6: .word 1, 4
test7: .word 1, 0
test8: .word 1, -5
test9: .word -1, 5
test10: .word -1, 4
test11: .word -1, 0
test12: .word -1, -5
test13: .word -1, -4
test14: .word 2, 3
test15: .word 2, -3
test16: .word -3, 5
test17: .word -3, 6
test18: .word -3, -3

.text
setup:
    li    ra, -1
    li    sp, 0x7ffffff0
main:
    ##############################
    #   t0 : num_test
    #   t1 : test_addr
    #   t2 : answer_addr
    #   t3 : i
    #   t4 : result
    #   t5 : valid
    ##############################

    ##Save and Initialize parameters
    la t0, num_test
    lw t0, 0(t0)            #Save num_test to t0
    la t1, test1            #t1 = test_addr
    li t2, 0x01000000       #t2 = answer_addr

FOR_LOOP:
    li t5, 1                    #valid = 1
    lw a0, 0(t1)                #a0 = base 
    addi t1, t1, 4              #test_addr++
    lw a1, 0(t1)                #a1 = exponent
    addi t1, t1, 4              #test-addr++
    bne a0, x0, ELSE_LOOP       #if (base != 0), jump to else
    blt x0, a1, ELSE_LOOP       #if (base == 0 but exponent > 0), jump to else
    li t5, 0                    ##Left is base ==0 && 0 >= exponent, vlaid = 0
    jal x0, ENDIF_LOOP
ELSE_LOOP:
    ##ra saved and caller saved
    addi sp, sp, -28
    sw t5, 0(sp)
    sw t4, 4(sp)
    sw t3, 8(sp)
    sw t2, 12(sp)
    sw t1, 16(sp)
    sw t0, 20(sp)
    sw ra, 24(sp)

    ##Function call
    jal ra, FUNC_POWER

    ##Retrieved ra and caller
    lw t5, 0(sp)
    lw t4, 4(sp)
    lw t3, 8(sp)
    lw t2, 12(sp)
    lw t1, 16(sp)
    lw t0, 20(sp)
    lw ra, 24(sp)
    addi sp, sp, 28

ENDIF_LOOP:
    ##Save answer (answer now is in a0 and we store in t4)
    mv t4, a0

    sw t5, 0(t2)
    addi t2, t2, 4          #Save valid
    sw t4, 0(t2)
    addi t2, t2, 4          #Save result
    addi t3, t3, 1          #i++
    blt t3, t0, FOR_LOOP    #check whether i < num_test
    ret


FUNC_POWER:
    #########################################################
    # < Function >
    #    It can handle power calculation of 2 integer variables
    #
    # < Parameters >
    #    a0 : base
    #    a1 : exponent
    #
    # < Return Value >
    #    a0 : result
    #########################################################
    # < Local Variable >
    #   t0 = i 
    #   t1 : result
    #   t2 : 1
    #########################################################
    ##Save ra 
    addi sp, sp, -4
    sw ra, 0(sp)

    ##Save and Initial parameter 
    li t0, 0        #Initial i = 0
    li t1, 1        #result = 1
    li t2, 1        #used for == 1

    ##If Special Condition 
    beq a0, x0, BS_ZERO     #Base = 0, Ex positive
    beq a1, x0, EX_ZERO     #Exponent = 0
    blt a1, x0, EX_NEG      #Exponent < 0

    ##Do power through succssive multiplcations
FOR_LOOP_1:
    ##Caller save
    addi sp, sp, -12
    sw t0, 8(sp)
    sw t1, 4(sp)
    sw t2, 0(sp)

    ##Save parameter
    mv a2, t1
    mv a3, a0

    ##Function call
    jal ra, FUNC_MUL         #(t1,a0)

    ##Retrieve caller saved
    lw t0, 8(sp)
    lw t1, 4(sp)
    lw t2, 0(sp)
    addi sp, sp, 12

    ##Save answer
    mv t1, a2

    addi t0, t0, 1           #i++
    blt t0, a1, FOR_LOOP_1   #if(i < exponent)  
    mv a0, t1                #a0(Return value ) = t1
POWER_EXIT:
    ##retrieve ra
    lw ra, 0(sp)
    addi sp, sp, 4

    ##Return
    ret

BS_ZERO:
    li a0, 0
    jal x0, POWER_EXIT 
EX_ZERO:
    li a0, 1   
    jal x0, POWER_EXIT  
EX_NEG:
    beq a0, t2, BS_ONE_EX_NEG       ##Base = 1 and Ex negative
    li a0, 0
    jal x0, POWER_EXIT 
BS_ONE_EX_NEG:
    li a0, 1
    jal x0, POWER_EXIT 


FUNC_MUL:
    #######################################################
    # < Function >
    #    It can handle multiplication of 2 integer variables
    #
    # < Parameters >
    #    a2 : multiplicand
    #    a3 : multiplier
    #
    # < Return Value >
    #    a2 : result
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
    srai    t0, a2, 31               # t0 = 0xffffffff(-) / 0(+)
    xor     t2, a2, t0               # Inverse(-) / Keep(+)
    sub     t2, t2, t0               # -(-1) / -0
                                     # t2 = abs(multiplicand)
    
    ## abs(multiplier)
    srai    t1, a3, 31               # t1 = 0xffffffff(-) / 0(+)
    xor     t3, a3, t1               # Inverse(-) / Keep(+)
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
    mv      a2, t6                   # a2(return value) = t6
                                     
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
    
