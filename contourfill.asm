
.data

.asciiz
str_error:	"An error occured, checking file name might help."
out_buffer:	"P1\n50 50\n"
str1:		"./A3/test1.txt"
str3:		"./A3/filltest1.pbm"
buffer:  .space 10000		# buffers for upto 10000 bytes
newbuff: .space 40000		# (increase sizes if necessary)		# array?

.text
.globl main

main:	la	$a0,str1		#readfile takes $a0 as input
	jal	readfile

	la 	$a1,buffer		#$a1 will specify the "2D array" we will be filling
	la 	$a2,newbuff		#$a2 will specify the filled 2D array.
	li	$a0, 1			#a0 and 3 are the x and y coordinates
	li	$a3, 1
	jal	 fillregion

	la	$a0, str3		#writefile will take $a0 as file location
	la 	$a1,newbuff		#$a1 takes location of what we wish to write.
	jal	writefile

exit:	li 	$v0,10		
	syscall
	
error:	li	$v0, 4
	la	$a0, str_error
	syscall
	j	exit
	
readfile:
	li	$v0, 13
	li	$a1, 0
	li	$a2, 0
	syscall

	move	$t1, $v0	# t1 <- descriptor

	slt	$t0, $t1, $0
	bne	$t0, $0, error

	li	$v0, 14
	add	$a0, $t1, $0
	la	$a1, buffer
	li	$a2, 2535
	syscall
	
	slt	$t0, $v0, $0
	bne	$t0, $0, error

	move	$t2, $v0
	
	li	$v0, 16
	add	$a0, $t1, $0
	syscall
	
	slt	$t0, $v0, $0
	bne	$t0, $0, error

	# storing data in the buffer in a 2D array, that is actually 1D
	# set up a loop to run for the 2500 items we have in the buffer
	li	$t1, 0			# start
	li	$t2, 2500		# finish
	la	$t3, buffer
	la	$t4, newbuff
	
loop:	slt	$t0, $t1, $t2
	beq	$t0, $0, done
	
	lb	$t5, ($t3)		# pointer to go through buffer
	
	li	$t6, '\n'		# only writing 1s and 0s into newbuff
	beq	$t5, $t6, skip
	
	sb	$t5, ($t4)
					# update invariants
	addi	$t4, $t4, 1		# move newbuff pointer by 4 for each word
	addi	$t1, $t1, 1
skip:	addi	$t3, $t3, 1
	j	loop

done:	jr	$ra

fillregion:
	# a0:x   a3:y   ==meaning==>   a3:i   a0:j in a regular 2D array
	# a1:buffer   a2:newbuff
	
	# convert coordinates to an index in the array
	li	$t0, 50
	mult	$a3, $t0
	mflo	$t1
	
	add	$t1, $t1, $a0		# t1 <- index of seed
	
	add	$t2, $a2, $t1		# t2 <- pointer to coordinate
	
	# check if point is indeed white (0)
	lb	$t3, ($t2)
	subi	$t3, $t3, '0'
	bne	$t3, $0, return
	# if so, colour it in (1)
	addi	$t1, $0, '1'
	sb	$t1, ($t2)
	
	# now repeating for all the neighbors
	# 8 calls (1 for each neighbor)
	# no need to check for position viability since the borders are coloured in black, and will terminate the sequence
	
	# 3 steps to repeat for each neighbor:	(written as 3 block after each comment title)
	# STEP 1: save stack - we need to keep a0, a3, ra.
	# STEP 2: update coordinates + recursive call
	# STEP 3: restore stack
	
	# (x-1 , y+1)
	addi	$sp, $sp, -12
	sw	$ra, 0($sp)
	sw	$a0, 4($sp)
	sw	$a3, 8($sp)
	
	addi	$a0, $a0, -1
	addi	$a3, $a3, 1
	jal	fillregion
	
	lw	$ra, 0($sp)
	lw	$a0, 4($sp)
	lw	$a3, 8($sp)
	addi	$sp, $sp, 12
	
	# (x-1 , y  )
	addi	$sp, $sp, -12
	sw	$ra, 0($sp)
	sw	$a0, 4($sp)
	sw	$a3, 8($sp)
	
	addi	$a0, $a0, -1
	jal	fillregion
	
	lw	$ra, 0($sp)
	lw	$a0, 4($sp)
	lw	$a3, 8($sp)
	addi	$sp, $sp, 12
	
	# (x-1 , y-1)
	addi	$sp, $sp, -12
	sw	$ra, 0($sp)
	sw	$a0, 4($sp)
	sw	$a3, 8($sp)
	
	addi	$a0, $a0, -1
	addi	$a3, $a3, -1
	jal	fillregion
	
	lw	$ra, 0($sp)
	lw	$a0, 4($sp)
	lw	$a3, 8($sp)
	addi	$sp, $sp, 12
	
	# (x   , y+1)
	addi	$sp, $sp, -12
	sw	$ra, 0($sp)
	sw	$a0, 4($sp)
	sw	$a3, 8($sp)
	
	addi	$a3, $a3, 1
	jal	fillregion
	
	lw	$ra, 0($sp)
	lw	$a0, 4($sp)
	lw	$a3, 8($sp)
	addi	$sp, $sp, 12
	
	# (x   , y-1)
	addi	$sp, $sp, -12
	sw	$ra, 0($sp)
	sw	$a0, 4($sp)
	sw	$a3, 8($sp)
	
	addi	$a3, $a3, -1
	jal	fillregion
	
	lw	$ra, 0($sp)
	lw	$a0, 4($sp)
	lw	$a3, 8($sp)
	addi	$sp, $sp, 12
	
	# (x+1 , y+1)
	addi	$sp, $sp, -12
	sw	$ra, 0($sp)
	sw	$a0, 4($sp)
	sw	$a3, 8($sp)
	
	addi	$a0, $a0, 1
	addi	$a3, $a3, 1
	jal	fillregion
	
	lw	$ra, 0($sp)
	lw	$a0, 4($sp)
	lw	$a3, 8($sp)
	addi	$sp, $sp, 12
	
	# (x+1 , y  )
	addi	$sp, $sp, -12
	sw	$ra, 0($sp)
	sw	$a0, 4($sp)
	sw	$a3, 8($sp)
	
	addi	$a0, $a0, 1
	jal	fillregion
	
	lw	$ra, 0($sp)
	lw	$a0, 4($sp)
	lw	$a3, 8($sp)
	addi	$sp, $sp, 12
	
	# (x+1 , y-1)
	addi	$sp, $sp, -12
	sw	$ra, 0($sp)
	sw	$a0, 4($sp)
	sw	$a3, 8($sp)
	
	addi	$a0, $a0, 1
	addi	$a3, $a3, -1
	jal	fillregion

	lw	$ra, 0($sp)
	lw	$a0, 4($sp)
	lw	$a3, 8($sp)
	addi	$sp, $sp, 12
	
return:	jr	$ra
	
writefile:
	# same subroutine as fileio using:
	# newbuff with 2500 characters instead of buffer with 2535 characters
	
	# open
	li	$v0, 13
	li	$a1, 1
	li	$a2, 0
	syscall

	move	$t1, $v0	# t1 <- descriptor

	slt	$t0, $t1, $0
	bne	$t0, $0, error
	
	# write: "P1 50 50"
	li	$v0, 15
	move	$a0, $t1
	la	$a1, out_buffer
	li	$a2, 9
	syscall
	
	slt	$t0, $v0, $0
	bne	$t0, $0, error
	
	# write: newbuff
	li	$v0, 15
	add	$a0, $t1, $0
	la	$a1, newbuff
	li	$a2, 2500
	syscall
	
	slt	$t0, $v0, $0
	bne	$t0, $0, error
	
	# close
	li	$v0, 16
	add	$a0, $t1, $0
	syscall
	
	slt	$t0, $v0, $0
	bne	$t0, $0, error
	
	jr	$ra
	

