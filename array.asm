# This program manipulates an array by inserting and deleting at specified index and sorting the contents of the array.
# The program should also be able to print the current content of the array.
# The program should not terminate unless the 'quit' subroutine is called
# You can add more subroutines and variables as you wish.
# Remember to use the stack when calling subroutines.
# You can change the values and length of the beginarray as you wish for testing.
# You will submit 5 .asm files for this quesion, Q1a.asm, Q1b.asm, Q1c.asm, Q1d.asm and Q1e.asm.
# Each file will be implementing the functionalities specified in the assignment.
# Use this file to build the helper functions that you will need for the rest of the question.


.data

beginarray: 	.word -999			#’beginarray' with some contents	 DO NOT CHANGE THE NAME "beginarray"
array: 		.space 4000					#allocated space for ‘array'

.asciiz
str_command:	"Enter a command (i, d, s or q): " # command to execute
str_error:	"You have entered an invalid command\n"
str_i_index:	"Enter an index: "
str_i_error:	"Index out of bounds.\n"
str_i_value:	"Enter a value: "
str_i_result:	"The current array is "
newline: 	"\n"
space: 		" "

.text
.globl main

main:

	# initialize array (clean-up from q1a)
	la	$a0, beginarray
	la	$a1, array
	jal	copyarray
	# print initial array
	la	$a0, array
	jal	printarray
	
	# receivde input
choice:	li	$v0, 4
	la	$a0, str_command
	syscall
	
	li	$v0, 12	
	syscall
	add	$s0, $v0, $zero	# s0 <- choice
	
	li	$v0, 11
	lb	$a0, newline
	syscall
	
	# printing choice for testing purposes
	#li	$v0, 11
	#add	$a0, $s0, $zero
	#syscall
	
	beq	$s0, 'i', insert
	beq	$s0, 'd', delete
	beq	$s0, 's', sort
	beq	$s0, 'q', quit
	li	$v0, 4
	la	$a0, str_error
	syscall
	j	choice
	
	
quit:	li	$v0, 10
	syscall
	
	
i_error:
	li	$v0, 4
	la	$a0, str_i_error
	syscall
insert:
	# receive index
	li	$v0, 4
	la	$a0, str_i_index
	syscall
	li	$v0, 5
	syscall
	add	$s1, $v0, $zero		# s1 <- index input
	# check if index is valid
	la	$a0, array
	jal	length			# v0 <- array length
	addi	$s3, $v0, 2		# s3 <- length + 2
	slt	$t0, $v0, $s1
	bne	$t0, $zero, i_error	# error if index > length
	slt	$t0, $s1, $zero
	bne	$t0, $zero, i_error	# error if index < 0
	
	# receive value
	li	$v0, 4
	la	$a0, str_i_value
	syscall
	li	$v0, 5
	syscall
	add	$s2, $v0, $zero		# s2 <- value input
	
	
	# insert value
	# setting starting position where insertion will happen
	la	$t1, array		# t1 <- array[0] pointer
	addi 	$t0, $zero, 4
	mult	$s1, $t0		# 4 * index
	mflo	$t0			# t0 <- bytes t1 needs to shift by
	add	$t1, $t1, $t0		# t1 <- array[index] pointer
	add	$t3, $s2, $zero		# t3 <- value to be inserted
	
	# t1: pointer, t2: current value, t3: next value
	
	# loop condition, similar to setting starting position, this time for last value instead of given index
	# s3 = length + 2, to account for the new item that is being added and -999 the special end value
	la	$t4, array
	addi	$t0, $zero, 4
	mult	$s3, $t0
	mflo	$t0
	add	$t4, $t4, $t0 		# t4 <- pointer to last element of array
	
loop_i:	lw	$t2, ($t1)		# t2 <- array[index] value
	sw	$t3, ($t1)		# array[index] <- value
	addi	$t1, $t1, 4		# t1 moves to next position in the array
	add	$t3, $t2, $zero		# current value becomes next value
	slt	$t0, $t4, $t1
	beq	$t0, $zero, loop_i
	
	# print
	li	$v0, 4
	la	$a0, str_i_result
	syscall
	la	$a0, array
	jal	printarray
	
	# back to choice menu
	j	choice
	
d_error:
	li	$v0, 4
	la	$a0, str_i_error
	syscall	
delete:
	# receive index
	li	$v0, 4
	la	$a0, str_i_index
	syscall
	li	$v0, 5
	syscall
	add	$s1, $v0, $zero		# s1 <- index input
	# check if index is valid
	la	$a0, array
	jal	length			# v0 <- array length
	addi	$s2, $v0, 1		# s2 <- length to be used in loop condition
	slt	$t0, $s1, $v0
	beq	$t0, $zero, d_error	# error if index >= length
	slt	$t0, $s1, $zero
	bne	$t0, $zero, d_error	# error if index < 0
	
	# similar procedure to insert:
	
	# t1: pointer, t2: next pointer, t3: next value
	
	# setting starting position where insertion will happen
	la	$t1, array		# t1 <- array[0] pointer
	addi 	$t0, $zero, 4
	mult	$s1, $t0		# 4 * index
	mflo	$t0			# t0 <- bytes t1 needs to shift by
	add	$t1, $t1, $t0		# t1 <- array[index] pointer
	addi	$t2, $t1, 4
	
	# loop condition
	# s2 = length, to account for the missing item that is being revomed and -999 the special end value (they balance each other out)
	la	$t4, array
	addi	$t0, $zero, 4
	mult	$s2, $t0
	mflo	$t0
	add	$t4, $t4, $t0
	
loop_d:	lw	$t3, ($t2)		# t3 <- value to be replaced with
	sw	$t3, ($t1)		# array[index] <- next value
	addi	$t1, $t1, 4		# t1 moves to next position in the array
	addi	$t2, $t2, 4		# t2 moves to next position in the array
	slt	$t0, $t4, $t2		# if t2 exceeds the length we would be adding an extra random value after -999
	beq	$t0, $zero, loop_d
	
	# print
	li	$v0, 4
	la	$a0, str_i_result
	syscall
	la	$a0, array
	jal	printarray
	
	# back to choice menu
	j	choice
	
	
sort:	# bubble sort
	la	$a0, array
	jal	length
	addi	$s0, $v0, -1		# s0 will be used for loop condition, -1 to point at the last "real element", not -999
	
	addi	$t0, $zero, 4
	la	$t1, array
	mult	$s0, $t0
	mflo	$t0
	add	$s1, $t1, $t0		# s1 <- pointer to last "real" element of array
	
	la	$t1, array		# counter will go from first element to last (s1)
	la	$t2, array		# counter will go from first element to last-(loop count) (s2)
	la	$t2, array		# counter will go from first element to last-(loop count) (s2)
	add	$s2, $s1, $zero		# s2 start from last element (s1) and decrease by one place every loop
	
loop_s:	add	$s0, $zero, $zero	# (pseudo)boolean to see if changes were made during each iteration
	slt	$t0, $t1, $s1		# t1 < s1 to go into loop
	beq	$t0, $zero, sorted	# o.w. assume sorted
	
	
	# start of loop_ss
loop_ss:addi	$t3, $t2, 4
	lw	$t4, 0($t2)		# t4 = array at t2
	lw	$t5, 0($t3)		# t5 = array at t3
	
	slt	$t0, $t5, $t4
	bne	$t0, $zero, swap
	
update:	addi	$t2, $t2, 4
	slt	$t0, $t2, $s2
	bne	$t0, $zero, loop_ss
	
	##### after loop_ss but before next iteration of loop_s
	addi	$s2, $s2 -4		# update s2
	la	$t2, array		# restore t2
	
	addi	$t1, $t1, 4		# update t1 for next element
	beq	$s0, $zero, sorted	# if no update to the array has been made, we can end the procedure
	j	loop_s			# otherwise outer loop loops
	#####	
	j	loop_s
	
swap:	sw	$t5, 0($t2)
	sw	$t4, 0($t3)
	addi	$s0, $zero, 1
	j	update
	
	# end of loop_ss
	
	

	
	# print
sorted:	li	$v0, 4
	la	$a0, str_i_result
	syscall
	la	$a0, array
	jal	printarray
	
	# back to choice menu
	j	choice
	
	
	
length:
	# a0 <- pointer to beginarray
	add	$v0, $zero, $zero
	
loop1:	lw	$t0, 0($a0)
	beq	$t0, -999, done1
	addi	$v0, $v0, 1
	addi	$a0, $a0, 4
	j	loop1
	
done1:	jr $ra

copyarray:
	# a0 <- first array
	# a1 <- second array
loop2:	lw	$t0, 0($a0)
	sw	$t0, 0($a1)
	beq	$t0, -999, done2
	addi	$a0, $a0, 4
	addi	$a1, $a1, 4
	j	loop2
	
done2:	jr $ra


printarray:
	# a0 <- pointer to beginarray
	add	$t0, $a0, $zero	 # using t0 instead of a0 since the routine will make syscalls and constantly change thevalue of a0
loop3:	lw	$a0, 0($t0)
	beq	$a0, -999, done3
	li	$v0, 1
	syscall
	li	$v0, 11
	lb	$a0, space
	syscall
	addi	$t0, $t0, 4
	j	loop3

done3:	
	li	$v0, 11
	lb	$a0, newline
	syscall
	jr $ra



# You will repeat the steps below for each of the .asm files. Q1b.asm is shown below

# For Q1b.asm, you will need to implement the insert operation
# str_index: .asciiz "Enter index: "
# str_value: .asciiz "Enter value: "

# insert:
# INSERT subroutine expects index of and value to insert
