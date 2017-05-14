# ***** DO NOT MODIFY THIS FILE **** #
.include "./cs47_common_macro.asm"
.include "./cs47_proj_macro.asm"

# data section
.data
.align 2
matchMsg: .asciiz "matched"
unmatchMsg: .asciiz "not matched"
charCR: .asciiz "\n"
testD: .word 0xffffffff
var0: .word 0x00000000
var1: .word 0x00000000
var2: .word 0x00000000
var3: .word 0x00000000
testV1Arr: .word 4 16 -13 -2 -6 -18  5 -19 4 -26
testV2Arr: .word 2 -3   5 -8 -6  18 -8   3 3 -64
noTest:	   .word 10
passTest:  .word 0
totalTest: .word 0
opList:	   .byte '/' '*' '-' '+'
testFlag:  .word 0x0
as_msg: .asciiz "(%d %c %d) \t normal => %d \t logical => %d \t [%s]\n"
mul_msg: .asciiz "(%d %c %d) \t normal => HI:%d LO:%d \t\ logical => HI:%d LO:%d \t [%s]\n"
div_msg: .asciiz "(%d %c %d) \t normal => R:%d Q:%d \t\ logical => R:%d Q:%d \t [%s]\n"
finalMSG: .asciiz "*** OVERALL RESULT %s ***\n"
statPASS: .asciiz "PASS"
statFAIL: .asciiz "FAILED"
testStatus: .asciiz "\n\nTotal passed %d / %d\n"

.text
.globl main
#####################################################################
# Main Program
#####################################################################
main:
	add	$s0, $zero, $zero	# $s0 = 0	; used as index
	lw	$s1, noTest
test_loop:
	mul	$t0, $s0, 4
	# $s3 = testV1Arr[$s0]
	la	$t1, testV1Arr
	add	$t1, $t1, $t0
	lw	$s3, 0($t1)
	# $s4 = testV2Arr[$s0]
	la	$t1, testV2Arr
	add	$t1, $t1, $t0
	lw	$s4, 0($t1)
	addi	$s5, $zero, 4
op_loop:
	addi	$t0, $s5, -1
	la	$t1, opList
	add	$t1, $t1,$t0
	lb	$s6, 0($t1)
	# increase number of tests
	lw	$t0, totalTest
	addi	$t0, $t0, 1
	sw	$t0, totalTest
	# normal operation
	or	$a0, $s3, $zero
	or	$a1, $s4, $zero
	or	$a2, $s6, $zero
	ori	$v0, $zero, 0x0
	ori	$v1, $zero, 0x1
	jal	au_normal
	sw	$v0, var0
	sw	$v1, var1
	# logical operation
	or	$a0, $s3, $zero
	or	$a1, $s4, $zero
	or	$a2, $s6, $zero
	ori	$v0, $zero, 0x2
	ori	$v1, $zero, 0x3
	jal	au_logical
	sw	$v0, var2
	sw	$v1, var3
	# Set if mul or div
	# print the result
	lw	$t0, var0
	lw	$t1, var2
	bne	$t0, $t1, main_mismatch
	beq	$s6, '*', main_extra_match
	beq	$s6, '/', main_extra_match
	j	main_L6
main_extra_match:
	lw	$t0, var1
	lw	$t1, var3
	bne	$t0, $t1, main_mismatch
main_L6:
	push_var_address(matchMsg)
	lw	$t0, passTest
	addi	$t0, $t0, 1
	sw	$t0, passTest
	j	main_L5
main_mismatch:
	push_var_address(unmatchMsg)
	ori	$t0, $zero, 0x1
	sw	$t0, testFlag
main_L5:
	push_var_value(var2)
	beq	$s6, '*', main_ins_1
	beq	$s6, '/', main_ins_1
	j	main_L1
main_ins_1:
	push_var_value(var3)	# main_ins_1
main_L1:
	push_var_value(var0)	# main_L1
	beq	$s6, '*', main_ins_2
	beq	$s6, '/', main_ins_2
	j	main_L2
main_ins_2:
	push_var_value(var1) # main_ins_2
main_L2:
	push($s4)	# main_L2
	push($s6)
	push($s3)
	beq	$s6, '*', main_print_mul
	beq	$s6, '/', main_print_div
	call_printf(as_msg)
	j	main_L3
main_print_mul:
	call_printf(mul_msg)	# main_print_mul
	j	main_L3
main_print_div:
	call_printf(div_msg)	# main_print_div
	j	main_L3
main_L3:
	pop($t0)	# main_L3
	pop($t0)
	pop($t0)
	pop($t0)
	pop($t0)
	pop($t0)
	beq	$s6, '*', main_pop_2
	beq	$s6, '/', main_pop_2
	j	main_L4
main_pop_2:
	pop($t0)
	pop($t0)
main_L4:
	addi	$s5, $s5, -1	# main_L4
	bnez	$s5 op_loop
	addi	$s0, $s0, 1
	bne	$s0, $s1, test_loop
	# Test statistics
	lw	$t0, totalTest
	push($t0)
	lw	$t0, passTest
	push($t0)
	call_printf(testStatus)
	pop($t0)
	pop($t0)

	# Final msg
	lw	$t0, testFlag
	beqz	$t0, main_pass
	push_var_address(statFAIL)
	j	main_L7
main_pass:
	push_var_address(statPASS)
main_L7:
	call_printf(finalMSG)
	pop($t0)
	exit
