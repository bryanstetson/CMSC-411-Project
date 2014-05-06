#Go TEAM DOGE
#Infinite amount of help:
#49 is ASCII code for '1'
#48 is ASCII code for '0'

	.data
initPrompt: .asciiz "Welcome to the binary converter!"
binPrompt:	.asciiz "\nEnter a binary number: "
basePrompt:	.asciiz "Enter a base (10=Decimal, 8=Octal, 16=Hex): "

test:	.asciiz "test"

binNum:		.space 16
decResult:	.asciiz "Decimal: "
octResult:	.asciiz "Octal: "
hexResult:	.asciiz "Hex: "			
	
	.text
	.globl main
main:
	# Print initial welcome prompt to user
	li	$v0, 4        
	la 	$a0, initPrompt    
	syscall

BinaryPrompt:
	# Print binary prompt to user
	li	$t3, 0	# reset flag
	li	$v0, 4        
	la 	$a0, binPrompt    
	syscall

	# Get binary input from user
	la	$a0, binNum
	li	$a1, 17		
	li	$v0, 8          
	syscall

	#Insert some binary number error checks

	# Stuff that needs to get reset every run 
	# Initialize result to zero
	li	$t4, 0               
	# Address of binary number in $t1
	la	$t1, binNum
	# Initialize binToDec counter to 16
	li	$t9, 16   
	# Initialize binToOct counter to 0
	li	$t8, 0

BasePrompt:
	# Print base conversion prompt to user
	li	$v0, 4        
	la 	$a0, basePrompt    
	syscall

	# Get conversion base input from user
	li	$v0, 5		#5 is sys read int          
	syscall

	# Check that the base is valid
	beq $v0, 10, binToDec	# Jump to decimal convert if 10
	beq $v0, 8, binToOct	# Jump to octal convert if 8
	beq $v0, 16, binToHex	# Jump to hex convert if 16  		
	j	BasePrompt

binToDec:
	lb	$a0, ($t1)
	blt	$a0, 48, printDecResult
	# Increment offset
	addi	$t1, $t1, 1
	# Convert to decimal
	addi	$a0, $a0, -48
	# Decrement counter
	addi	$t9, $t9, -1
	beq	$a0, 0, zero
	beq	$a0, 1, one
	j	printDecResult

zero:
	j	binToDec

one:
	li 	$t8, 1
	# Shift left by 2^value of counter
	sllv 	$t5, $t8, $t9
	# Add to the decimal result
	add 	$t4, $t4, $t5

	j 	binToDec

printDecResult:
	
	srlv 	$t4, $t4, $t9
	beq	$t3, 32, hexInit	#flag to not print for binToHex

	# Print result header
	la 	$a0, decResult
	li 	$v0, 4
	syscall

	# Get converted number and print
	move	$a0, $t4    
	li 	$v0, 1      
	syscall
	j 	exit

binToHex:
	#Will use binToDec to convert 4 binary strings to their decimal representation. Then will give ASCII values of those nibbles

	li	$t3, 32		#Set $t9 as a flag to not print binToDec.	
	j	binToDec	#Set $t4 as the decimal number needed to make hex	
	
hexInit:
	#Pre-Condition: $t4 is set to decimal value of the string
	li	$t9, 61440	#Mask to get nibble (1111000000000000)
	li	$t1, 0		#Counter
	li	$t8, 3		#Decrement Counter	
	j	hexLoop

hexLoop:
	beq	$t1, 4, exit	# if looped 3 times exit
	li	$t6, 4		
	mult	$t1, $t6	# 4*counter = shift value of mask
	mflo	$t2
	srlv	$t9, $t9,$t2	# Shift Mask

	and	$t5, $t9, $t4	# get nibble
	mult	$t8, $t6	# get number of bits to shift the nibble by
	mflo	$t2
	srlv	$t5, $t5, $t2	# nibble is now at last 4 bits
	
	li	$t2, 10
	sub	$t6, $t5, $t2
	addi	$t1, 1		#increment counter
	addi	$t8, -1		#decrement counter
	li	$t9, 61440	
	
	bgez	$t6, nonNumericPrint	#if output is not numeric (nibble >= 10)
	
	j	printHexResult
		
	
printHexResult:
	addi	$t5, 48
	move	$a0, $t5
	li	$v0, 11
	syscall
	j	hexLoop 

nonNumericPrint:

	addi	$t6, 65
	move 	$a0, $t6
	li	$v0, 11
	syscall
	j	hexLoop 				
	


binToOct:
	# Counter1 = $t7, keeps track of current bit
	# Counter2 = $t8, keeps track of current octal
	# Answer = $t4
	# Temp = t3, temporarily holds values to be added to the answer
	# Extra = t5, used for calculations
	# Reset counter for current bit
	li 	$t3, 0
	li	$t7, 0

	lb	$a0, ($t1)					# Take first input bit
	blt	$a0, 48, printOctResult 	# Go to the end
	addi	$t1, $t1, 1 			# Increment offset
	addi	$a0, $a0, -48			# Convert to 1 or 0
	sllv	$a0, $a0, $t7			# Shift into position
	addi	$t7, $t7, 1 			# Increment count1
	or 		$t3, $t3, $a0			# Place bit onto temp answer

	lb	$a0, ($t1)					# Take second input bit
	blt	$a0, 48, octProcess 		# Go to the octal processing
	addi	$t1, $t1, 1 			# Increment offset
	addi	$a0, $a0, -48			# Convert to 1 or 0
	sllv	$a0, $a0, $t7			# Shift into position
	addi	$t7, $t7, 1 			# Increment count1
	or 		$t3, $t3, $a0			# Place bit onto temp answer

	lb	$a0, ($t1)					# Take third input bit
	blt	$a0, 48, octProcess 		# Go to the octal processing
	addi	$t1, $t1, 1 			# Increment offset
	addi	$a0, $a0, -48			# Convert to 1 or 0
	sllv	$a0, $a0, $t7			# Shift into position
	addi	$t7, $t7, 1 			# Increment count1
	or 		$t3, $t3, $a0			# Place bit onto temp answer

octProcess:
	beq		$t8, 0, octContinue
	add 	$t2, $zero, $t8			# Copy $t8 to $t2

octPower:							# Basically does $t3*10^$t8
	beq		$t2, 0, octContinue		# $t2 is a countdown
	li		$t5, 10				
	mult	$t3, $t5				
	mflo 	$t3
	addi	$t2, $t2, -1 			# decrement count
	j 		octPower 				

octContinue:
	add 	$t4, $t4, $t3
	addi	$t8, $t8, 1 			# Increment count2
	j 		binToOct


printOctResult:
	# Print result header
	la 	$a0, octResult
	li 	$v0, 4
	syscall

	# Get converted number and print
	move	$a0, $t4    
	li 	$v0, 1      
	syscall
	j 	exit


exit:
	j	BinaryPrompt	# Repeat program
	li 	$v0, 10			# Exit the program (implement exit later)
	syscall

