.include "./cs47_proj_macro.asm"
.text
.globl au_normal
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_normal
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_normal:

	addi  	$sp,	$sp,		-24
	sw      $fp,                24($sp)
	sw      $ra,                20($sp)
	sw 	    $a0     			16($sp)
	sw      $a1,   				12($sp)
	sw 		$a2					8($sp)
	addi    $fp,  	$sp,        24

	li		$t1, 	'+'						# $t1 = '+'
	beq		$a2, 	$t1, 	add_normal		# if $a2 == $t1 then add_normal
	li		$t1, 	'-'						# $t1 = '-'
	beq		$a2, 	$t1, 	sub_normal		# if $a2 == $t1 then sub_normal
	li		$t1, 	'*'						# $t1 = '*'
	beq		$a2, 	$t1, 	mult_normal		# if $a2 == $t1 then mult_normal
	li		$t1, 	'/'						# $t1 = '/'
	beq		$a2, 	$t1, 	div_normal		# if $a2 == $t1 then div_normal

add_normal:

	add		$v0, $a0, $a1					# $v0 = $a0 + $a1
	j		exit							# jump to exit

sub_normal:

	sub		$v0, $a0, $a1					# $v0 = $a0 - $a1
	j		exit							# jump to exit

mult_normal:

	mult		$a0, $a1		# $a0 * $a1 = Hi and Lo registers
	mflo		$v0				# copy Lo to $v0
	mfhi		$v1				# copy Hi to $v1
	j		exit				# jump to exit

div_normal:

	div		$a0, $a1		# $a0 / $a1
	mflo		$v0			# $v0 = floor($a0 / $a1)
	mfhi		$v1			# $v1 = $a0 mod $a1
	j		exit			# jump to exit

exit:

	lw		$fp, 	24($sp)
	lw		$ra, 	20($sp)
	lw		$a0,	16($sp)
	lw		$a1, 	12($sp)
	lw		$a2, 	8($sp)
	addi	$sp, 	$sp, 	24

	jr		$ra				# jump to $ra
