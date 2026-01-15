# ===========================================================
# Identificacao do grupo:  [T?? para Tagus ou A?? para Alameda]
# A36
# Membros [istID, primeiro + ultimo nome]
# 1. ist1113887 - Francisco Pinto
# 2. ist1114077 - Francisco Carvalho
# 3. ist1113875 - Tiago Andrês
#
# ===========================================================
# Requisitos do enunciado que *nao* estao corretamente implementados:
# (indicar um por linha, ou responder "nenhum")
# - nenhum
#
# ===========================================================
# Top-5 das otimizacoes que a vossa solucao incorpora:
# (maximo 140 caracteres por cada otimizacao)
#
# 1.
#
# 2.
#
# 3.
#


# 4.
#
# 5.
#
# ===========================================================

.data

# ===========================================================
#Main data structures. These definitions cannot be changed.

h_m0: .word 128
w_m0: .word 784
m0: .zero 401408                #h_m0 * w_m0 * 4 bytes

h_m1: .word 10
w_m1: .word 128
m1: .zero 5120                  #h_m1 * w_m1 * 4 bytes

h_input: .word 784
w_input: .word 1
input: .zero 3136               #h_input * w_input * 4 bytes

h_h: .word 128
w_h: .word 1
h: .zero 512                    #h_h * w_h * 4 bytes

h_o: .word 10
w_o: .word 1
o: .zero 40                     #h_o * w_o * 4 bytes


# ===========================================================
# Here you can define any additional data structures that your program might need
size_read_m0: .word 100352
size_read_m1: .word 1280
size_read_input: .word 796
size_h: .word 128
size_o: .word 10
buffer_read_m0: .zero 100352          # h_m0 * w_m0
buffer_read_m1: .zero 1280            # h_m1 * w_m1
buffer_read_input: .zero 796          # h_input * w_input + 12 bytes header
m0_filename: .string "m0.bin"
m1_filename: .string "m1.bin"
input_filename: .string "p5input8.pgm"
# ===========================================================
.text

main:
    # Set up arguments for *classify* function
    la a0, m0_filename
    la a1, m1_filename
    la a2, input_filename

    # Call *classify* function
    jal ra, classify
    
    # Print
    li a7, 1
    ecall

    j exit
    

# ===========================================================
# FUNCTION: abs
#   Computes absolute value of the int stored at a0
# Arguments:
#   a0, a pointer to int
# Returns:
#   Nothing (modifies value in memory)
# ===========================================================

abs:
  lw t0, 0(a0)         	 	 	 	     # Load int value
  bge t0, zero, done   	 	 	 	 	 # If value >= 0, skip negation
  sub t0, x0, t0       	 	 	 	 	 # t0 = -t0
  sw t0, 0(a0)         	 	 	 	 	 # Store back to memory

done:
    jr ra                    	 	 	 # Return to the caller



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
    blez a1, exit_with_error_36          # If length <= 0, jump to error exit
    li t0, 0                             # Set iterator to 0
    
Loop_relu:
    beq t0, a1, loop_end_relu            # If iterator == length, exit loop

    slli t1, t0, 2                       # Compute byte offset (t1 = t0 * 4)
    add t2, t1, a0                       # Get address of array[t0]
    lw t3, 0(t2)                         # Load array element

    bgez t3, end_if_relu                 # If element >= 0, skip to end_if                            
    sw zero, 0(t2)                       # Store 0 back to array

end_if_relu:
    addi t0, t0, 1                       # Increment iterator
    j Loop_relu                          # Repeat loop
    
loop_end_relu:
    
    jr ra                    			 # Return to the caller



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
#     this function terminates the program with error code 37
# =================================================================
argmax:
    ble a1, x0, exit_with_error_37   	 # If length <= 0, jump to error exit
    lw t0, 0(a0)                     	 # Set max value to first element
    li t1, 0                         	 # Set max index to 0
    li t2, 1                         	 # Set iterator to 0
    
Loop_argmax:
    beq t2, a1, loop_end_argmax          # If iterator == length, exit loop
    slli t3, t2, 2                   	 # Compute byte offset (t3 = t2 * 4)
    add t4, t3, a0                   	 # Get address of array[t2]
    lw t5, 0(t4)                     	 # Load array element

    ble t5, t0, end_if_argmax            # If element <= max, skip to end_if
    mv t1, t2                        	 # Update max index
    mv t0, t5                        	 # Update max value

end_if_argmax:
    addi t2, t2, 1                   	 # Increment iterator
    j Loop_argmax                        # Repeat loop

loop_end_argmax:
    mv a0, t1                        	 # Return max index in a0
    jr ra                    	 	 	 # Return to the caller




# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) - Pointer to the start of arr0
#   a1 (int*) - Pointer to the start of arr1
#   a2 (int)  - Number of elements to use   
# Returns:
#   a0 (int)  - The dot product of arr0 and arr1
# Exceptions:
#   - If a2 < 1, exit with error code 38
# =======================================================
dotproduct:
    ble a2, zero, exit_with_error_38	 # If length <= 0, jump to error exit 
    li t0, 0							 # Set iterator to 0
	li t5, 0 	 	 	 	 	 	 	 # Set accumulator to 0
    addi sp,sp, -4                       # guardar espaco
    li t6, 2                             # teste prático - para dividir B por 2

Loop_dotproduct:
    bge t0, a2, Loop_end_dotproduct	 	 # If iterator == length, exit loop
    slli t1, t0, 2	 	 	 	 	 	 # Compute byte offset (t1 = t0 * 4)
    add t2, a0, t1	 	 	 	 	 	 # Get address of array0[t0]
    add t3, a1, t1			 	 	 	 # Get address of array1[t0]
    lw a3, 0(t2)   	 	 	 	 	 	 # Load array0 element
    slli a3, a3, 1                       # teste prático - 2A
    lw a4, 0(t3) 	 	 	 	 	 	 # Load array1 element
    div a4, a4, t6                       # teste prático - 1/2 * B
    mul t4, a3, a4	 	 	 	 	 	 # t4 = a3 * a4 (teste prático - 2A * 1/2B)
    add t5, t5, t4	 	 	 	 	 	 # Add to accumulator
    addi t0, t0, 1 	 	 	  	 	 	 # Increment iterator	 	 	 
    j Loop_end_dotproduct 	 	 	 	 # Repeat loop

Loop_end_dotproduct:
    mv a0, t5 	 	 	 	  	 	 	 # Return accumulator in a0
    addi t6,t6,4                         # retirar do stack
    jr ra                    	 	 	 # Return to the caller


# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
#
# Arguments:
#   a0 (int*)  - pointer to the start of m0     (Matrix A)
#   a1 (int*)  - pointer to the start of m1     (Matrix B)
#   a2 (int)   - number of rows in m0 (A)             [rows_A]
#   a3 (int)   - number of columns in m0 (A)          [cols_A]
#   a4 (int)   - number of rows in m1 (B)             [rows_B]
#   a5 (int)   - number of columns in m1 (B)          [cols_B]
#   a6 (int*)  - pointer to the start of d            (Matrix C = A x B)
#
# Returns:
#   None (void); result is stored in memory pointed to by a6 (d)
#
# Exceptions:
#  - If the height or width of any of the matrices is less than 1, 
#    this function terminates the program with error core 39
#  - If the number of columns in matrix A is not equal to the number 
#    of rows in matrix B, it terminates with error code 40
# =======================================================
matmul:
    ble a2, zero, exit_with_error_39     # rows_A < 1
    ble a3, zero, exit_with_error_39     # cols_A < 1
    ble a4, zero, exit_with_error_39     # rows_B < 1
    ble a5, zero, exit_with_error_39     # cols_B < 1
    bne a3, a4, exit_with_error_40       # cols_A != rows_B 

    addi sp, sp, -32		 	 	 	 # Context Backup
    sw ra, 0(sp)
    sw s0, 4(sp)     
    sw s1, 8(sp)     
    sw s2, 12(sp)    
    sw s3, 16(sp)    
    sw s8, 20(sp)    
    sw s10, 24(sp)   
    sw s11, 28(sp)   

    li s11, 0            			 	 # number of iterations
    li s10, 0            			 	 # new matrix iterator
    li t0, 0              	 	 	 	 # iterator
    mv s0, a0            	 	 	 	 
    mv s1, a1            
    mul s2, a2, a5       	 	 	 	 # number of elements of the new matrix
    li s3, 0             	 	 	 	 # accumulator

Loop_matmul:
    beq t0, a3, inc_col      			 # if t0 == a3, have to increment column
    beq s10, s2, Loop_end_matmul    	 # if s10 == s2, new matrix is full

    slli t1, t0, 2           	 	 	 # Compute byte offset (t1 = t0 * 4)
    add t1, s0, t1           	  	  	 # Get address of A[t0]
    lw t2, 0(t1)             	 	 	 # Load A[t0] element

    slli t3, t0, 2           	 	 	 # Compute byte offset (t3 = t0 * 4)
    mul t3, t3, a5           	 	 	 # multiply by number of columns to get the next column element
    add t3, s1, t3           	 	 	 # Get address of B[t0]
    lw t4, 0(t3)             	 	 	 # Load B[t0] element

    mul t5, t4, t2			 	 	 	 # Dot product
    add s3, s3, t5          

    addi t0, t0, 1           	 	 	 # Increment iterator

    beq t0, a4, add          	 	 	 # if t0 == a4, end of column need to add the result to new matrix
    j Loop_matmul


inc_col:
    beq s11, a5, inc_line    	 	 	 # if it is the last column need to increment line also
    li t0, 0                 	 	 	 # iterator = 0
    li s3, 0                 	 	 	 # reset accumulator
    addi s1, s1, 4           	 	 	 # move pointer to next column
    j Loop_matmul

inc_line:
    mv s1, a1                	 	 	 # reset pointer to the start
    li t0, 0                 	 	 	 # iterator = 0
    li s3, 0                 	 	 	 # accumulator = 0
    slli s8, a3, 2           	 	 	 # Compute byte offset (s8 = a3 * 4)
    add s0, s0, s8           	 	  	 # increment line
    li s11, 0                            # number of iterations = 0
    j Loop_matmul

add:
    slli t6, s10, 2          	 	 	 # Compute byte offset (t6 = s10 * 4)
    add t6, a6, t6           	 	 	 # get the position of the new matrix to store the value
    sw s3, 0(t6)             	 	 	 # store the accumulator value 
    addi s10, s10, 1         	 	  	 # number of iterations ++
    addi s11, s11, 1         	 	 	 # iterator++
    j Loop_matmul

Loop_end_matmul:				 	 	 # Restore Context
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s8, 20(sp)
    lw s10, 24(sp)
    lw s11, 28(sp)
    addi sp, sp, 32
    jr ra


######################################################################
# Function: read_file(char* filename, byte* buffer, int length)
# Input:
#   a0: pointer to null-terminated filename string
#   a1: destination buffer
#   a2: number of bytes to read
# Output:
#   a0: number of bytes read (return value from syscall)
# Exceptions:
#   - Error code 41 if error in the file descriptor
#   - Error code 42 If the length of the bytes to read is less than 1
######################################################################

read_file:
    
    # Save arguments
    mv t0, a0                	 	 	 # t0 = filename
    mv t1, a1                	 	 	 # t1 = buffer
    mv t2, a2                	 	 	 # t2 = length
    
    ble t2, x0, exit_with_error_42  # length < 1

    # Open file: ecall 1024 (a0=filename, a1=flags)
    mv a0, t0
    li a1, 0                 	 	 	 # O_RDONLY
    li a7, 1024
    ecall
    
    ble a0, x0, exit_with_error_41 # open error

    mv t3, a0                	 	 	 # t3 = file descriptor

    # Read file: ecall 63 (a0=fd, a1=buffer, a2=length)
    mv a0, t3                	 	 	 # fd
    mv a1, t1                	 	 	 # buffer
    mv a2, t2                	 	 	 # length
    li a7, 63
    ecall
    
    ble a0, x0, exit_with_error_41 # read error

    mv t4, a0                	 	 	 # t4 = bytes read

    # Close file: ecall 57 (a0=fd)
    mv a0, t3
    li a7, 57
    ecall

    # Return bytes read
    mv a0, t4
    jr ra

######################################################################
# AUXILIAR FUNCTION: subtract32
#
# Arguments:
#	a0(int*) - pointer to buffer
#	a1(int) - number of bytes that buffer has
#
# Subtracts 32 to content of each element in the buffer 
#
######################################################################

subtract32:
    li t0, 0
    
loop_subtract32:
    bge t0, a1, loop_end_subtract32
    lb t1, 0(a0)
    addi t1, t1, -32
    sb t1, 0(a0)
    addi a0, a0, 1
    addi t0, t0, 1
    j loop_subtract32
    
    
loop_end_subtract32:
    jr ra

######################################################################
# AUXILIAR FUNCTION: convert_8_to_32
#
# Arguments:
#	a0(int*) - pointer to buffer
#	a1(int) - number of bytes that buffer has
#   a2(int*) - pointer to new buffer 
#
# Converts a buffer of elements with 8 bits 
# to a buffer with elements of 32 bits
#
######################################################################

convert_8_to_32:
    li t0, 0
    
loop_convert_8_to_32:
    bge t0, a1, loop_end_convert_8_to_32
    lb t1, 0(a0)
    sw t1, 0(a2)
    
    addi a0, a0, 1
    addi a2, a2, 4
    addi t0, t0, 1
    j loop_convert_8_to_32
    
loop_end_convert_8_to_32:
    jr ra

# =======================================================
# FUNCTION: Classify decimal digit from input image
#   d = classify(A, B, input)
#
# Arguments:
#   a0 (string*)  - pathname of file with the weight matrix m0
#   a1 (string*)  - pathname of file with the weight matrix m1
#   a2 (string*)  - pathname of file with the input image in Raw PGM format
#
# Returns:
#   a0 (int) - value of the classified decimal digit
#
# =======================================================

classify:
	addi sp, sp, -12				 	 # Context Backup
    sw ra, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)


    mv s1, a1
    mv s2, a2
    
    la  a1, buffer_read_m0    	 	 	 # a1 = pointer to buffer
    lw  a2, size_read_m0      	 	 	 # a2 = number of bytes to read
    jal ra, read_file         	 	 	 # call read_file
    
    la a0, buffer_read_m0     	 	 	 # a0 = pointer to buffer
    lw a1, size_read_m0		  	 	 	 # a1 = number of bytes of the buffer
    jal ra, subtract32		  	 	 	 # call subtract32
    
    la a0, buffer_read_m0	  	 	 	 # a0 = pointer to buffer
    lw a1, size_read_m0		  	 	  	 # a1 = number of bytes of the buffer
    la a2, m0 				  	 	 	 # a2 = pointer to new buffer
    jal ra, convert_8_to_32   	 	 	 # call convert_8_to_32
    
    mv a0, s1
    la  a1, buffer_read_m1    	 	 	 # a1 = pointer to buffer
    lw  a2, size_read_m1      	 	 	 # a2 = number of bytes to read
    jal ra, read_file         	  	 	 # call read_file
    
    la a0, buffer_read_m1	  	 	 	 # a0 = pointer to buffer
    lw a1, size_read_m1		  	 	 	 # a1 = number of bytes of the buffer
    jal ra, subtract32		  	 	 	 # call subtract32
    
    la a0, buffer_read_m1	  	 	 	 # a0 = pointer to buffer
    lw a1, size_read_m1		  	 	 	 # a1 = number of bytes of the buffer
    la a2, m1 				   	 	 	 # a2 = pointer to new buffer
    jal ra, convert_8_to_32   	 	 	 # call convert_8_to_32
    
    mv a0, s2
    la  a1, buffer_read_input     	 	 # a1 = pointer to buffer
    lw  a2, size_read_input       	 	 # a2 = number of bytes to read
    jal ra, read_file             	 	 # call read_file
    
    
    la a0, buffer_read_input
    addi a0, a0, 12               	 	 # skip the header
    lw a1, size_read_input
    addi a1, a1, -12
    la a2, input 
    jal ra, convert_8_to_32
    
    la a0, m0					  	 	 # Storing arguments for matmul
    la a1, input
    la a6, h
    
    lw a2, h_m0
    lw a3, w_m0
    lw a4, h_input
    lw a5, w_input
    
    jal ra, matmul
    
    mv a0, a6						 	 # Storing arguments for relu
    lw a1, size_h
    
    jal ra, relu
    
    la a0, m1			   		 	 	 # Storing arguments for matmul
    la a1, h
    la a6, o
    
    lw a2, h_m1
    lw a3, w_m1
    lw a4, h_h
    lw a5, w_h
    
    jal ra, matmul
    
    mv a0, a6						 	 # Storing arguments for argmax
    lw a1, size_o
    
    jal ra, argmax
    
    lw s2, 8(sp)					 	 # Restore Context
    lw s1, 4(sp)
    lw ra, 0(sp)
	addi sp, sp, 12
    
    
    jr ra                    	 	 	 # Return to the caller




# =======================================================
# Exit procedures
# =======================================================

# Exits the program (with code 0)
exit:
    li a7, 93     # Exit syscall code
    ecall         # Terminate the program

# Exits the program with an error 
# Arguments: 
# a0 (int) is the error code 
# You need to load a0 the error to a0 before to jump here
exit_with_error_36:
    li a0, 36
    li a7, 93            # Exit system call
    ecall                # Terminate program

exit_with_error_37:
    li a0, 37
    li a7, 93            # Exit system call
    ecall                # Terminate program
    
exit_with_error_38:
    li a0, 38
    li a7, 93            # Exit system call
    ecall                # Terminate program
    
exit_with_error_39:
    li a0, 39
    li a7, 93            # Exit system call
    ecall                # Terminate program
    
exit_with_error_40:
    li a0, 40
    li a7, 93            # Exit system call
    ecall                # Terminate program
    
exit_with_error_41:
    li a0, 41
    li a7, 93            # Exit system call
    ecall                # Terminate program
    
exit_with_error_42:
    li a0, 42
    li a7, 93            # Exit system call
    ecall                # Terminate program
    
exit_with_error:
    li a7, 93            # Exit system call
    ecall                # Terminate program

