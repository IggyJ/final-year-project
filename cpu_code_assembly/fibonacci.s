start:
    andi x1,x0,0  # clear reg 1
    andi x2,x0,0  # store a 0 in reg 2
    addi x3,x0,1  # store a 1 in reg 3
fib:
    add  x4,x2,x3 # add reg 2+3 and store in reg 4
    sw   x4,0(x1) # store contents of reg 4 at address in reg 1
    andi x2,x0,0  # clear reg 2
    addi x2,x3,0  # copy reg 3 to reg 2
    andi x3,x0,0  # clear reg 3
    addi x3,x4,0  # copy reg 4 to reg 3
    addi x1,x1,4  # increment reg 4
    j    fib      # jump to start of label

    