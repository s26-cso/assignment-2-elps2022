# in c we have a struct with val and left and right
#in assembly, we have to somehow define such a struct and make it so its traversable
.globl make_node, insert, get, getAtMost
.equ NODE_LEFT,0
.equ NODE_RIGHT,8
.equ NODE_VAL,16
.equ NODE_SIZE,20
make_node:#a0 contains val
    addi sp,sp,-16 #because malloc call overwrites return address, need to save it on the stack
    sd ra,0(sp)
    sd s0,8(sp) #s0 might have had something before the function call
    mv s0,a0 # save the val in s0 for future use
    li a0,NODE_SIZE #argument for malloc
    call malloc
    sd x0,NODE_LEFT(a0)
    sd x0,NODE_RIGHT(a0)
    sw s0,NODE_VAL(a0)
    ld ra,0(sp)
    ld s0,8(sp)
    addi sp,sp,16
    ret
insert: #a0 contains the node, a1 contains the value to be inserted
    addi sp,sp,-48
    sd ra,0(sp)
    sd s0,8(sp)    #save old s0
    sd s1,16(sp)   #save old s1
    sd a0,24(sp)   #save the root node because its about to be overwritten
    sd a1,32(sp)   #save val because make_node will clobber a1
    mv s0,a0
    mv s1,a1
    mv a0,a1
    call make_node #now a0 will have the node to be inserted
    sd a0,40(sp)   #save new node
    ld t0,24(sp)   #root node
    ld a1,32(sp)   #restore val
    li t1,0        #parent = NULL
    traversal:
        beqz t0,insertion       #if current node is NULL, insert here
        lw t2,NODE_VAL(t0)
        mv t1,t0                #save parent
        blt a1,t2,less_than
        ld t0,NODE_RIGHT(t0)
        j traversal
    less_than:
        ld t0,NODE_LEFT(t0)
        j traversal
insertion:
    ld t3,40(sp)            #new node
    lw t2,NODE_VAL(t1)
    blt a1,t2,insert_left
    sd t3,NODE_RIGHT(t1)
    j done
insert_left:
    sd a0,NODE_LEFT(t1)
done:
    ld a0,24(sp)   #return root
    ld s1,16(sp)
    ld s0,8(sp)
    ld ra,0(sp)
    addi sp,sp,48
    ret

get:#traverse through tree until you get null or the node, a0=pointer to root, a1=value
    mv t0,a0
    traversal_get:
        beqz t0,return_miss
        lw t1,NODE_VAL(t0)
        beq t1,a1,return_hit
        blt a1,t1,less_than_get
        ld t0,NODE_RIGHT(t0)
        j traversal_get
    less_than_get:
        ld t0,NODE_LEFT(t0)
        j traversal_get
    return_miss:
        mv a0,x0
        ret
    return_hit:
        mv a0,t0
        ret

getAtMost: # a0=val, a1=root
    mv t0,a1
    li t1,0
    traversal_getmost:
        beqz t0,logic
        lw t2,NODE_VAL(t0)      # lw because int is 4 bytes
        bgt t2,a0,go_left       # current > target, go left
        mv t1,t0                # update best match
        beq t2,a0,logic         # exact match, stop early
        ld t0,NODE_RIGHT(t0)    # current < target, go right
        j traversal_getmost
    go_left:
        ld t0,NODE_LEFT(t0)
        j traversal_getmost
    logic:
        beqz t1,miss_most
        lw a0,NODE_VAL(t1)      # return best match value
        ret
    miss_most:
        li a0,-1
        ret



