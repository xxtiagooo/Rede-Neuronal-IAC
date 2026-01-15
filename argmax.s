.data
# You can change this array to test other values
array: .word 1, 9, 3, 9, 2   # Initial array values

.text

main:
    la a0, array           # Load address of the array
    li a1, 5               # Number of elements in the array

    jal ra, argmax         # Call the argmax function

    # Result: the index of the largest element is now in a0

exit:
    li a7, 10              # Exit syscall code
    ecall                  # Terminate the program


# =================================================================
# FUNCTION: Given an int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the number of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    ble a1, x0, exit_with_error      # If length <= 0, jump to error exit
    
    lw t0, 0(a0)                     # Set max value to first element
    li t1, 0                         # Set max index to 0
    li t2, 1                         # Set iterator to 0

Loop:
    beq t2, a1, loop_end             # If iterator == length, exit loop
    slli t3, t2, 2                   # Compute byte offset (t3 = t2 * 4)
    add t4, t3, a0                   # Get address of array[t2]
    lw t5, 0(t4)                     # Load array element

    ble t5, t0, end_if               # If element <= max, skip to end_if
    mv t1, t2                        # Update max index
    mv t0, t5                        # Update max value

end_if:
    addi t2, t2, 1                   # Increment iterator
    j Loop                           # Repeat loop

loop_end:
    mv a0, t1                        # Return max index in a0
    jr ra                            # Return

# Exits the program with an error 
# Arguments: 
# a0 (int) is the error code 
# You need to load a0 the error to a0 before to jump here
exit_with_error:
    li a0, 36                    #puts the error code
    li a7, 93                    # Exit system call
    ecall                        # Terminate program
