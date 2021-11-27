# fileio.asm

.data

.asciiz
str1:		"/Users/neyirerdeser/Documents/2020_Fall/COMP\ 273/A3/test1.txt"
str2:		"/Users/neyirerdeser/Documents/2020_Fall/COMP\ 273/A3/test2.txt"
str3:		"/Users/neyirerdeser/Documents/2020_Fall/COMP\ 273/A3/test2.pbm"
str_error:	"An error occured, checking file name might help."

out_buffer:	"P1\n50 50\n"

buffer: .space 10172			# buffer for upto 4096 bytes (increase size if necessary)

.text
.globl main

main:	la	$a0,str2		#readfile takes $a0 as input
	jal	readfile
	move	$s0, $v0
	move	$s1, $v1
	
	li	$v0, 4			# warm-up print to screen
	la	$a0, buffer
	syscall

	la	$a0, str3		#writefile will take $a0 as file location
	la	$a1,buffer		#$a1 takes location of what we wish to write.
	jal	writefile

exit:	li	$v0,10			
	syscall

error:	li	$v0, 4
	la	$a0, str_error
	syscall
	j	exit

readfile:

	# Open the file to be read,using $a0
	# Conduct error check, to see if file exists

	# You will want to keep track of the file descriptor*
	
	li	$v0, 13
	li	$a1, 0
	li	$a2, 0
	syscall

	move	$t1, $v0	# t1 <- descriptor

	slt	$t0, $t1, $0
	bne	$t0, $0, error

	# read from file
	# use correct file descriptor, and point to buffer
	# hardcode maximum number of chars to read

	li	$v0, 14
	add	$a0, $t1, $0
	la	$a1, buffer
	li	$a2, 2535
	syscall
	
	slt	$t0, $v0, $0
	bne	$t0, $0, error

	move	$t2, $v0

	# address of the ascii string you just read is returned in $v1.
	# the text of the string is in buffer	
	# close the file (make sure to check for errors)
	li	$v0, 16
	add	$a0, $t1, $0
	syscall
	
	slt	$t0, $v0, $0
	bne	$t0, $0, error

	jr	$ra



writefile:
	#open file to be written to, using $a0.
	li	$v0, 13
	li	$a1, 1
	li	$a2, 0
	syscall

	move	$t1, $v0	# t1 <- descriptor

	slt	$t0, $t1, $0
	bne	$t0, $0, error
	#write the specified characters as seen on assignment PDF:
	#P1
	#50 50
	li	$v0, 15
	move	$a0, $t1
	la	$a1, out_buffer
	li	$a2, 9
	syscall
	
	slt	$t0, $v0, $0
	bne	$t0, $0, error
	
	# content in the buffer
	li	$v0, 15
	add	$a0, $t1, $0
	la	$a1, buffer
	li	$a2, 2535
	syscall
	
	slt	$t0, $v0, $0
	bne	$t0, $0, error
	
	#write the content stored at the address in $a1.
	#close the file (make sure to check for errors)
	li	$v0, 16
	add	$a0, $t1, $0
	syscall
	
	slt	$t0, $v0, $0
	bne	$t0, $0, error
	
	jr	$ra
