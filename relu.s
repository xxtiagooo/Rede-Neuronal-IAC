.data
# You can change this array to test other values
array: .word -3, 2, -1, 7, -2   # Initial array values				 

.text

main:
  la a0, array      # a0 = pointer to array
  li a1, 5          # a1 = number of elements in the array

  jal ra, relu      # Call relu function

  # Result: the array now has its negative values replaced by zero

exit:
  li a7, 10              # Exit syscall code
  ecall                  # Terminate the program


# ============================================================
# FUNCTION: relu
#   Applies ReLU on each element of the array (in-place)
# Arguments:
#   a0 = pointer to int array
#   a1 = array length
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ============================================================
relu:
    ble a1, x0, exit_with_error          # If length <= 0, jump to error exit
    li t0, 0                             # Set iterator to 0
Loop:
    beq t0, a1, loop_end                 # If iterator == length, exit loop

    slli t1, t0, 2                       # Compute byte offset (t1 = t0 * 4)
    add t2, t1, a0                       # Get address of array[t0]
    lw t3, 0(t2)                         # Load array element

    bgez t3, end_if                      # If element >= 0, skip to end_if                             # Set element to 0
    sw zero, 0(t2)                       # Store 0 back to array

end_if:
    addi t0, t0, 1                       # Increment iterator
    j Loop                               # Repeat loop
    
loop_end:
    jr ra                                # Return                


# Exits the program with an error 
# Arguments: 
# a0 (int) is the error code 
# You need to load a0 the error to a0 before to jump here
exit_with_error:
  li a0,36             # give correct error code
  li a7, 93            # Exit system call
  ecall                # Terminate program

