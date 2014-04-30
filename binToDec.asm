	.data
prompt:	.asciiz "Enter a binary number: "
empty:	.space 16
result:	.asciiz "\nDecimal: "
	
	.text
	.globl main
main:
	# Print prompt to user
	li	$v0, 4        
	la 	$a0, prompt    
	syscall

	# Get input from user
	la	$a0, empty
	li	$a1, 16		
	li	$v0, 8          
	syscall

	# Initialize result to zero
	li	$t4, 0               

	la	$t1, empty
	# Initialize counter to 16
	li	$t9, 16           

binToDec:
	lb	$a0, ($t1)
	blt	$a0, 48, printResult
	# Increment offset
	addi	$t1, $t1, 1
	# Convert to decimal
	addi	$a0, $a0, -48
	# Decrement counter
	addi	$t9, $t9, -1
	beq	$a0, 0, zero
	beq	$a0, 1, one
	j	printResult

zero:
	j	binToDec

one:
	li 	$t8, 1
	# Shift left by 2^value of counter
	sllv 	$t5, $t8, $t9
	# Add to the decimal result
	add 	$t4, $t4, $t5

	j 	binToDec

printResult:
	srlv 	$t4, $t4, $t9

	# Print result header
	la 	$a0, result
	li 	$v0, 4
	syscall

	# Get converted number and print
	move	$a0, $t4    
	li 	$v0, 1      
	syscall

exit:
	# Exit the program
	li 	$v0, 10     
	syscall

