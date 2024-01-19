.data                              # Data saved in RAM
    promt:		           .asciiz "Give the values of x and n(number of values): "
    TaylorMess1:                   .asciiz "Taylor Series with x="
    TaylorMess2:                   .asciiz " and n="
    TaylorMess3:	           .asciiz ": "
    newLine:                       .asciiz "\n"
    TaylorRMess:                   .asciiz "TaylorR(n): "
    
.text
.globl main
    main:
	                           # Input Message
	li $v0, 4                  # System Call Code 4 to print a String
	la $a0, promt              # Load address of promt in $a0
	syscall                    # Print Message(promt)

                                   # Read the value of integer x
	li $v0, 5	           # System Call Code 5 to read integer
	syscall                    # Input integer x will be stored in $v0
	
	move $a1, $v0              # Move value of x from $v0 to $a1 because its an arguement 

                                   # Read the value of integer x
	li $v0, 5                  # System Call Code 5 to read integer
	syscall                    # Input integer x will be stored in $v0

	move $a0, $v0              # Move value of n from $v0 to $a0 because its an arguement
        
	li $t1, 1                  # Initialize $t1 = i = 1 (index of TaylorMainLoop)
	move $t3, $a0              # Upper limit of TaylorMainLoop = n = $t3
	
	TaylorMainLoop:
	
	   move $a0, $t1                      # Move the value of $t1 to $a0 (index of loop)   
	   jal Taylor                         # Call the Taylor function

	   li $v0, 2                          # System Call Code 2 to print float
	   mov.s $f12, $f1                    # Load the return value of Taylor to $f12
	   syscall                            # Print 

	   li $v0, 4                          # System Call Code 4 to print String
	   la $a0, newLine                    # Load address of newLine in $a0
	   syscall                            # Print newLine

	   addi $t1, $t1, 1                   # Increase the index i

	   ble $t1, $t3, TaylorMainLoop       # If index is less or equal than the value of $t3 stay in loop

	li $v0, 4                             # System Call Code 4 to print String                    
	la $a0, TaylorRMess                   # Load address of TaylorRMess in $a0
	syscall                               # Print TaylorRMess

	move $a0, $t3                         # Move the value of $t3(n) to $a0

	jal TaylorR                           # Call Function TaylorR
	
	li $v0, 2                             # System Call Code 2 to print float
	mov.s $f12, $f1                       # Load the return value of TaylorR to $f12
	syscall                               # Print return value of TaylorR function
 
	li $v0, 10                            # System Call Code 10 to exit the program
	syscall

    Taylor:
	# Arguements $a1 = x,  $a0 = n

	addi $sp, $sp, -4               # Allocate Space in the Stack for 4 bytes
	sw $ra, 0($sp)                  # Save in the stack the return address

	move $s0, $a0                   # Move arguement in $s0, to avoid losing it when printing message

	                                # Print Taylor function's Output Message
	li $v0, 4                       # System Call Code 4 to print string
	la $a0,TaylorMess1              # Load Address of TaylorMess1 in $a0
	syscall                         # Print TaylorMess1

                                        # Printing x
	li $v0, 1                       # System Call Code 1 to print int
	move $a0, $a1                   # Move the value of $a1(x) to $a0  
	syscall                         # Print x

	li $v0, 4                       # System Call Code 4 to print string                      
	la $a0, TaylorMess2             # Load Address of TaylorMess2 in $a0
	syscall                         # Print TaylorMess2
	
	li $v0, 1
	move $a0, $s0   		# Printing n
	syscall
	
	li $v0, 4                       # System Call Code 1 to print int
	la $a0, TaylorMess3             # Load Address of TaylorMess3 in $a0
	syscall                         # Print TaylorMess3

	mtc1 $a1, $f2                    # Move value of $a1 to coprocec1 in $f2 to convert to a float
	cvt.s.w $f12, $f2                # Convert $f2 from integer to single precision float

	li.s $f1, 0.0                    # Initialize $f1 with 0 ($f1 will hold the return value) 
	addi $t1, $zero, 1               # $t1 = sum = 1

	loop:
	    beq $t1, $s0, exit_loop      # Exit loop when i = n

	    move $a0, $t1                # Set $a0 to the current value of $t1(i)

	    jal fact                     # Execute factorial function
	    move $t0, $v0                # Store the factorial Result in $t0

	    mtc1 $t0, $f2	         # Move the factorial return value to coprosec1 to convert
	    cvt.s.w $f3, $f2             #  Convert the factorial to a float in $f3 

	    jal powerR 	                 # Call powerR function (Return Value: $f0)  

	    div.s $f4, $f0, $f3          # Calculate powerR(x,n)/fact(n) and store in $f4

            add.s $f1, $f1, $f4	         # sum = sum + powerR(x,n)/fact(n)

	    
	
	    addi $t1, $t1, 1             # i++
	    j loop

	exit_loop: 
	    li.s $f2, 1.0                # Load 1.0 in $f2
	    add.s $f1, $f1, $f2          # sum = sum + $f2(1.0)
	    lw $ra, 0($sp)               # Load return address from stack
            addi $sp, $sp, 4             # Deallocate the stack
	    jr $ra                       # Return to calling function

    TaylorR:
	
	addi $sp, $sp, -8                # Allocate space in the stack for 8 bytes
	sw $ra, 4($sp)                   # Store the return address in the stack
	sw $a0, 0($sp)                   # Store the value of reg $a0 in the stack
	 
	bne $a0, 0, LabelTaylor          # If the value of $a0(n) != 0 go to LabelTaylor

	# Base Case
	li.s $f1, 1.0                    # Load 1.0 in $f1
	addi $sp,$sp,8                   # Deallocate the space in the stack
	jr $ra                           # Jump to return address
 
	# Recursive Step
LabelTaylor:
	addi $a0,$a0,-1                  # Decrease $a0(n) by 1
	jal TaylorR                      # Call the TaylorR function(recursion)

dTaylor: 
	lw $a0,0($sp)                    # Load the value of $a0 from the stack
	jal fact                         # Call fac function

	move $t0, $v0                    # Return value(int) of factorial stored in $t0

	# Convert int to float
	mtc1 $a1, $f2                    # Move $a1(x) to coprosec1 to convert to float
	cvt.s.w $f12, $f2                # Store x float value in $f12

	jal powerR                       # Call powerR function-->Result in $f0

	# Convert factorial return value(int to float)
	mtc1 $t0, $f2                    # Move $t0 to coprosec1 to convert to float
	cvt.s.w $f3, $f2                 # Convert the factorial result to float in $f3

	div.s $f4, $f0, $f3              # Calculate: power(x,n)/fact(n)

	
	addi $sp,$sp,8                   # Deallocate stack space
	add.s $f1, $f4, $f1              # sum = sum + power(x,n)/fact(n)
	
        lw $ra,4($sp)                    # Load return address from stack
	jr $ra                           # Jump to return address

    powerR:
	addi $sp,$sp,-8                  # Allocate Space in the stack
	sw $ra,4($sp)                    # Save return address in the stack
	sw $a0,0($sp)                    # Save the value of $a0(n) on the stack
	
	# Base Case
	bne $a0, 0, L1                   # If $a0 is not equal to zero go to L1
	
	li.s $f0, 1.0                    # Load 1.0 to $f0
	addi $sp,$sp,8                   # Deallocate stack space
	jr $ra                           # Jump to return address
        
	# Recursive Step
    L1:
	addi $a0,$a0,-1                  # Decrease $a0 (n) by 1
	jal powerR                       # Call powerR function

        lw $a0,0($sp)                    # Load the value of $a0 from the stack
	lw $ra,4($sp)                    # Load the return address from the stack

	addi $sp,$sp,8                   # Deallocate the space in the stack
	mul.s $f0,$f12,$f0               # Calculate x*power(x,n-1) in $f0

	jr $ra                           # Jump to return address

    fact:
	addi $sp,$sp,-8                  # Allocate space in the stack
	sw $ra,4($sp)                    # Save the return address in the stack
	sw $a0,0($sp)                    # Save the value of n in the stack

	bne $a0,$zero,L2                 # If the value of $a0 is not equal to 0 go to L2
	addi $v0,$zero,1                 # Set the factorial return value to 1 when n=0
	addi $sp,$sp,8                   # Deallocate the space in the stack
	jr $ra                           # Jump to return address
    L2:
	addi $a0,$a0,-1                  # Decrease the value of $a0(n) by 1
	jal fact                         # Call the fact function(recursion)
 
	lw $a0,0($sp)                    # Load word the value of $a0 from the stack
	lw $ra,4($sp)                    # Load the return address from the stack

	addi $sp,$sp,8                   # Deallocate the space in the stack
	mul $v0,$a0,$v0                  # Calculate n*factorial(n-1)
	jr $ra                           # Jump to return address