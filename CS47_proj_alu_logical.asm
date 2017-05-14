.include "./cs47_proj_macro.asm"
.text
.globl au_logical
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_logical
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_logical:
	# RTE Store
	addi  	$sp,	$sp,		-56
	sw      $fp,                56($sp)
	sw      $ra,                52($sp)
	sw 	    $a0,     			48($sp)
	sw      $a1,   				44($sp)
	sw 		$a2,				40($sp)
	sw 		$s0,				36($sp)
	sw 		$s1,				32($sp)
	sw 		$s2,				28($sp)
	sw 		$s3,				24($sp)
	sw 		$s4,				20($sp)
	sw 		$s5,				16($sp)
	sw 		$s6,				12($sp)
	sw 		$s7,				8($sp)
	addi    $fp,  	$sp,        56

	li		$t1, 	'+'						# $t1 = '+'
	beq		$a2, 	$t1, 	add_logical		# if $a2 == $t1 then add_logical
	li		$t1, 	'-'						# $t1 = '-'
	beq		$a2, 	$t1, 	sub_logical		# if $a2 == $t1 then sub_logical
	li		$t1, 	'*'						# $t1 = '*'
	beq		$a2, 	$t1, 	mult_logical	# if $a2 == $t1 then mult_logical
	li		$t1, 	'/'						# $t1 = '/'
	beq		$a2, 	$t1, 	div_logical		# if $a2 == $t1 then div_logical

add_logical:
	li		$a2,	0						# $a2 = 0x00000000
	jal		add_sub_logical					# jump to add_sub_logical
	j		exit

sub_logical:
	li		$a2, 	0xFFFFFFFF				# $a2 = 0xFFFFFFFF
	jal		add_sub_logical					# jump to add_sub_logical
	j		exit

add_sub_logical:
	move	$s0,	$a0 					# a
	move    $s1, 	$a1 					# b
	move 	$s2, 	$zero 					# i
	move  	$s3, 	$zero 					# s

	move 	$a0, 	$a2						# prepare arguments
	move 	$a1, 	$s2						# prepare arguments
	extract_nth_bit($a0, $a1)				# get LSB of $a2
	move 	$s4, 	$v0               		# ci
	beq		$s4, 	0, 		addition		# check for subtraction
	not		$s1,	$s1						# b = ~b

	addition:
	move 	$a0, 	$s0						# prepare argument a
	move 	$a1, 	$s2						# prepare argument i
	extract_nth_bit($a0, $a1)				# get ith bit of a
	move 	$s5, 	$v0						# save ith bit of a
	move 	$a0, 	$s1						# prepare argument b
	move 	$a1, 	$s2						# prepare argument i
	extract_nth_bit($a0, $a1)				# get ith bit of b
	move 	$s6, 	$v0						# save ith bit of b

	move 	$a0, 	$s5						# prepare argument ith bit of a
	move 	$a1, 	$s6						# prepare argument ith bit of b
	move 	$a2, 	$s4 					# prepare argument ci
	oneBitAdder($a0, $a1, $a2)				# call oneBitAdder
	move 	$s7, 	$v0      				# save y from first full adder
	move 	$s4,	$v1						# save co for second full adder

	move 	$a0,	$s5						# prepare argument ith bit of a
	move 	$a1,	$s6						# prepare argument ith bit of b
	move 	$a2, 	$s4 					# prepare argument
	oneBitAdder($a0, $a1, $a2)				# call oneBitAdder
	move 	$s4, 	$v1  					# save co from second full adder

	beq 	$s7, 	0, 	continue_add		# if y = 0, dont insert anything

	move 	$a0, 	$s3						# prepare argument s
	move 	$a1, 	$s2						# prepare argument i
	move    $a2, 	$s7						# prepare argument y
	insert_to_nth_bit($a0, $a1, $a2)		# insert y into s[i]
	move 	$s3, 	$v0						# save s

	continue_add:
	add		$s2, 	$s2, 	1				# increment i
	beq		$s2, 	32, 	addition_end	# if i == 32 then addition_end
	j		addition						# loop

	addition_end:
	move 	$v0, 	$s3						# $v0 = s
	move 	$v1, 	$s4						# $v1 = overflow bit (co)
	jr 		$ra								# jump to $ra

mult_logical:
	mul_signed($a0, $a1)
	j		exit

div_logical:
	div_signed($a0, $a1)
	j 		exit

exit:
	# RTE Restore
	lw      $fp,                56($sp)
	lw      $ra,                52($sp)
	lw 	    $a0,     			48($sp)
	lw      $a1,   				44($sp)
	lw 		$a2,				40($sp)
	lw 		$s0,				36($sp)
	lw 		$s1,				32($sp)
	lw 		$s2,				28($sp)
	lw 		$s3,				24($sp)
	lw 		$s4,				20($sp)
	lw 		$s5,				16($sp)
	lw 		$s6,				12($sp)
	lw 		$s7,				8($sp)
	addi	$sp, 	$sp, 		56

	jr 		$ra
