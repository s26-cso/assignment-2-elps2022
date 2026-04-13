.section .rodata
fmt:
.string "%d"
fmt_space:
.string " %d" 
.globl main
.section .text
#need to save count,size,both arrays
main: #ao contains argc, a1 contains argv
    addi sp, sp, -56
    sd ra, 48(sp) 
    sd s0, 40(sp) #n
    sd s1, 32(sp) #input array
    sd s2, 24(sp) #stack array
    sd s3, 16(sp) #stack size, used for argv pointer temporarily
    sd s4,  8(sp) #loop counter
    sd s5,  0(sp) #result array
    addi s0, a0, -1      #argc has one extra argument in the form of the command, not needed
    addi s3, a1, 8       #to exclude the command
    slli a0, s0, 3       #for malloc n*sizeof(long long) is the space allocated
    call malloc 
    mv s1, a0           
    slli a0, s0, 3       #mallocing the stack array 
    call malloc
    mv s2, a0
    slli a0, s0, 3       #mallocing the result array
    call malloc
    mv s5, a0
    li s4, 0             #initializing loop counter
input_loop:
    beq s4, s0, exit_il
    slli t0, s4, 3
    add t1, s3, t0       #t1 = address of argv[i]
    ld a0, 0(t1)
    call atoi            
    slli t0, s4, 3       #recompute t0 after atoi
    add t2, s1, t0
    sd a0, 0(t2)
    addi s4, s4, 1
    j input_loop
exit_il:
    mv s4, s0
    addi s4, s4, -1      #initialize s4 to n-1 as we need to traverse the input array from the back
    li s3, 0             #stack size - setting it to 0 initially
main_loop:
    blt s4, x0, exit_ml
pop_loop:
    beqz s3, exit_pl
    addi t0, s3, -1      #t0 = stack top index
    slli t0, t0, 3
    add t1, s2, t0
    ld t2, 0(t1)         #t2 = stack top value (an index into input array)
    slli t3, s4, 3
    add t4, s1, t3
    ld t5, 0(t4)         #t5 = input_array[s4] (current element's value)
    slli t6, t2, 3
    add t6, s1, t6
    ld t6, 0(t6)         #t6 = input_array[stack top value, which is an index]
    bgt t6, t5, exit_pl  #if stack top value > current, stop popping
    addi s3, s3, -1      #stack pop
    j pop_loop
exit_pl:
    slli t3, s4, 3
    add t4, s5, t3       #t4 = address of result[s4]
    beqz s3, make_minusone
    addi t0, s3, -1      #t0 = stack top index
    slli t0, t0, 3
    add t1, s2, t0
    ld t2, 0(t1)         #t2 = index of next greater element
    sd t2, 0(t4)         #result[s4] = t2
    j push
make_minusone:
    li t2, -1
    sd t2, 0(t4)         #result[s4] = -1
push:
    slli t0, s3, 3
    add t1, s2, t0
    sd s4, 0(t1)         #stack[s3] = s4
    addi s3, s3, 1       #incrementing stack size
    addi s4, s4, -1      #i--
    j main_loop
exit_ml:
    li s4, 0
print_loop:              #printing the results to stdout
    beq s4, s0, exit_prl
    slli t0, s4, 3
    add t1, s5, t0
    ld a1, 0(t1)
    beq s4, x0, print_first
    la a0, fmt_space
    j do_print
print_first:
    la a0, fmt
do_print:                #printing each element of the loop
    call printf
    addi s4, s4, 1
    j print_loop
exit_prl:
    li a0, 10
    call putchar         #adding a new line character (ascii 10) to make output look cleaner
    ld ra, 48(sp)