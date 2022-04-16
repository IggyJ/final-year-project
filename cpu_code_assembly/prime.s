# x1 -> number being tested if prime
# x2 -> divisor used for testing
# x3 -> range to test to
# x4 -> division remainder
# x5 -> store location

start:
    addi x1,x0,1            # First number to test will be 2  
main_loop:
    addi x1,x1,1            # Increment number being tested
    ori  x2,x0,2            # Set divisor to 2
    divu x3,x1,2            # Set range to half of number being tested
test_div:
    remu x4,x1,x2           # Test divisibility
    addi x2,x2,1            # Increment divisor
    beq  x4,x0,main_loop    # If remainder is 0, go back to main loop
    bge  x2,x3,store_prime  # If divisor surpassed range, store prime
    j    test_div           # Continue testing
store_prime:
    sw   x1,0(x5)           # Store prime number
    addi x5,x5,4            # Increment store location
    j    main_loop          # Go back to main loop
