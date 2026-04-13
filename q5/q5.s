.section .data

filename: .string "input.txt"
mode: .string "r"
yes_str: .string "Yes\n"
no_str: .string "No\n"

.section .text
.global main

main:
    addi sp, sp, -32
    sd ra, 24(sp)
    sd s0, 16(sp)  #file pointer
    sd s1, 8(sp)   #strlen
    sd s2, 0(sp)   #index

    la a0, filename  # fopen("input.txt", "r")
    la a1, mode
    call fopen 
    mv s0,a0 #s0 now stores the file pointer

    mv a0,s0
    li a1,0
    li a2,2 
    call fseek #fseek(*fp,0,SEEK_END), note fseeks just return if it succeeded or not

    mv a0,s0
    call ftell
    mv s1,a0 #s1 stores n now

    # check if last char is newline, if so trim length
    mv a0,s0
    li a1,-1
    li a2,2        
    call fseek #fseek(*fp,-1,SEEK_END),points to the last char
    mv a0,s0
    call fgetc
    li t0,10       # '\n'
    bne a0,t0,no_newline
    addi s1,s1,-1  # trim length by 1 if its a newline char

    no_newline:

    mv a0,s0
    li a1,0
    li a2,0
    call fseek #fseek(*fp,0,SEEK_SET)
    li s2,0 

    loop:
        srli t0,s1,1 #t0=n/2
        bge s2,t0,is_palindrome #if index>n/2 that means the two pointers have crossed each other without any mismatch, string is a palindrome

        mv a0,s0
        mv a1,s2
        li a2,0
        call fseek #fseek(*fp,index,SEEK_START), moving file pointer to str[i]
        mv a0,s0
        call fgetc #getting str[i]
        mv t1,a0 # storing left char in t1

        mv a0,s0
        sub a1,s1,s2 #a1=n-i
        addi a1,a1,-1 #a1=n-i-1
        li a2,0
        call fseek#fseek(*fp,n-index-1,SEEK_START), moving file pointer to str[n-1-i], which is the opposite of str[i]
        mv a0,s0
        call fgetc#getting the value
        mv t2,a0 #storing right char in t2

        bne t1,t2,not_palindrome #if left and right dont match, its not a palindrome by definition

        addi s2,s2,1 #incrementing index

        j loop

    is_palindrome:

    la a0, yes_str #print yes
    call printf
    j cleanup

    not_palindrome:

    la a0, no_str #print no
    call printf

    cleanup:

    mv a0, s0
    call fclose
    ld ra, 24(sp)
    ld s0, 16(sp)
    ld s1, 8(sp)
    ld s2, 0(sp)
    addi sp, sp, 32
    li a0, 0
    ret