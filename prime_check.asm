# Program: De_2
# Author: Tran Tuan Anh - 2110759
# Data segment
	.data
# Variable definition
decimal:						.word 1
FILE_DESCRIPTOR:				.word 1
FILENAME:						.asciiz "NGUYENTO.TXT"

NEWLINE_CHARACTER:				.asciiz "\n"
FILE_NOT_FOUND_ERROR_STRING:	.asciiz "Error: input file not found.\n"
FILE_READ_ERROR_STRING:			.asciiz "Error: can not read file.\n"

print_so: 						.asciiz "So "
prime_message: 					.asciiz " nguyen to.\n"
not_prime_message: 				.asciiz " khong nguyen to."

# Code segment
	.text
	.globl	main
main:	
# Input (syscall)
	# open the input file
	li $v0, 13			# open file
	la $a0, FILENAME
	li $a1, 1
	li $a2, 0
	syscall
	
	#check if file was opened successfully
	bltz $v0, FILE_NOT_FOUND
	sw $v0, FILE_DESCRIPTOR		# save file descriptor in FILE_DESCRIPTOR
	
# Process
loop1:
	jal GENERATE_RANDOM_INT
	move $a0, $v0
	jal is_prime
	beqz $v0, loop1     # if not prime, loop
	jal print_prime_check
	
loop2:
	jal GENERATE_RANDOM_INT
	move $a0, $v0
	jal is_prime
	bnez $v0, loop2		# if prime, loop
	jal print_prime_check
	
	# close input file
	li $v0, 16      	# close file
	lw $a0, FILE_DESCRIPTOR
	syscall

# Output (syscall)

# End program (syscall)
	li	$v0, 10
	syscall
	
# Function		
FILE_NOT_FOUND: 
	li $v0, 4
	la $a0, FILE_NOT_FOUND_ERROR_STRING
	syscall
	# exit program
	addiu	$v0, $zero, 10
	syscall
	
GENERATE_RANDOM_INT:
# Outputs: $v0 - random number
	# Set seed using syscalls 40 with time as the parameter
	li $v0, 30
	syscall
	
	li $v0, 40			# set seed
	move $a1, $a0
	syscall
	# Generate a random num x = (1,10000)
	li $v0, 42
	li $a1, 9998  		#upper bound -2
	syscall
	addi $v0, $a0, 2 	# return $v0
	jr $ra
	
is_prime:
# Function to check if a number is prime
# Inputs: $a0 - number to check
# Outputs: $v0 - 1 if prime, 0 if not prime

    # Check if number < 2
    li $v0, 0               # Assume number is not prime
    ble $a0, 1, return      # If number is less than 2, return 0
    
    # Check if number = 2
    li $v0, 1               # Assume number is prime
    beq $a0, 2, return      # If number is 2, return 1
    
    # Check if number is divisible by 2
    li $v0, 0 				# Assume number is not prime
    andi $t0, $a0, 1        # Get LSB
    beq $t0, $zero, return 	# If LSB = 0, number is even so return 0
    
    # Check if number is divisible by odd numbers 
    check:
        addi $t1, $zero, 3      # Start with 3 (skipping 2)
        loop:
            blt $t1, $a0, divisibility_check # If t1 > a0, we have checked all possible factors
            li $v0, 1           # Assume number is prime
            j return            # If we haven't found any factors yet, the number is prime
            
        divisibility_check:
            div $a0, $t1       # Divide a0 by t1
            mfhi $t2           # Check the remainder
            beq $t2, $zero, num_divisible # If remainder is 0, a0 is divisible by t1
            
            addi $t1, $t1, 2   # If remainder is not 0, try the next odd number
            j loop
            
        num_divisible:
            li $v0, 0          # Number is not prime
            j return
            
return:
    jr $ra 	# Return to calling function

print_prime_check:
	move $a3, $a0  	# a3 : random number
	move $v1, $v0	# v1 : isPrime(number)
	
	li $v0, 15            	# print "So " in file * in monitor
	lw $a0, FILE_DESCRIPTOR
    la $a1, print_so
    li $a2, 3
    syscall
    
    li $v0, 4
    la $a0, print_so
    syscall
    
    # convert $a3 to string stored in (decimal)
    	addi $s0, $zero, 3 	# index 
		move $t0, $a3		# store number to $t0
	loop_div:
		ble $t0, 9, add_	# if $t0 <= 9 go to add_
		div $t1, $t0, 10	# $t1 = [$t0 / 10]
		mul $t1, $t1, 10	# $t1 = $t1 * 10
		sub $t2, $t0, $t1	# get LSB $t2 = $t0 - $t1
		addi $t2, $t2, 48
		sb $t2, decimal($s0)# store to decimal
		addi $s0, $s0, -1	# $s0--
		div $t0, $t0, 10	# $t0 = $t0 % 10
		j loop_div
	
	add_: 	# store MSB
		addi $t0, $t0, 48
		sb $t0, decimal($s0)
		addi $s0, $s0, -1
	add_0: 	# store 0 if number of digit < 4
		beq $s0, -1, end_loop_div
		addi $t2, $zero, 48
		sb $t2, decimal($s0)
		addi $s0, $s0, -1
		j add_0
	end_loop_div:
	
    #
    li $v0, 15 				
    lw $a0, FILE_DESCRIPTOR            
    la $a1, decimal
    li $a2, 4
    syscall			# print "n" to file
    
    li $v0, 1
    move $a0, $a3
    syscall			# print 'n' to monitor
    
	if:
	beq $v1, $zero, not_prime
	li $v0, 15   
	lw $a0, FILE_DESCRIPTOR            
    la $a1, prime_message    
    li $a2, 12
    syscall     			# Print prime message to file
    li $v0, 4
    la $a0, prime_message
    syscall					# Print prime message to monitor
    
    j end_check     
	
	not_prime:
    li $v0, 15   
    lw $a0, FILE_DESCRIPTOR                
    la $a1, not_prime_message   
    li $a2, 18
    syscall   				# Print not prime message to file
    li $v0, 4
    la $a0, not_prime_message
    syscall					# Print not prime message to monitor
	end_check:
	jr $ra

# End