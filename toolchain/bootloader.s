.globl _start

_start:
  lui  sp,0x2001
  addi sp,sp,-4

  # Jump to the main program
  j main
