# Add you macro definition here - do not touch cs47_common_macro.asm"
#<------------------ MACRO DEFINITIONS ---------------------->#
.text

.macro extract_nth_bit($extract_source, $extract_bit_pos)
    #Caller RTE Store
    addi        $sp,  $sp,          -20
    sw          $fp,                20($sp)
    sw          $ra,                16($sp)
    sw          $extract_source     12($sp)
    sw          $extract_bit_pos,   8($sp)
    addi        $fp,  $sp,          20

    srlv        $v0,  $extract_source,    $extract_bit_pos      # Shift
    and         $v0,  $v0,          1                           # AND 1

    #Caller RTE restore
    lw          $fp,                20($sp)
    lw          $ra,                16($sp)
    lw          $extract_source,    12($sp)
    lw          $extract_bit_pos,   8($sp)
    addi        $sp,  $sp,          20
.end_macro

.macro insert_to_nth_bit($insert_source, $insert_bit_pos, $insert_bit_value)
    # Caller RTE Store
    addi        $sp,  $sp,          -24
    sw          $fp,                24($sp)
    sw          $ra,                20($sp)
    sw          $insert_source      16($sp)
    sw          $insert_bit_pos,    12($sp)
    sw          $insert_bit_value   8($sp)
    addi        $fp,  $sp,          24

    li      $t0,    1
    sllv    $t0,    $t0,    $insert_bit_pos
    not     $t0,    $t0
    and     $t0,    $insert_source, $t0
    sllv    $insert_bit_value,    $insert_bit_value,    $insert_bit_pos
    or      $v0,    $insert_bit_value,    $insert_source

    #Caller RTE restore
    lw          $fp,                24($sp)
    lw          $ra,                20($sp)
    lw          $insert_source,     16($sp)
    lw          $insert_bit_pos,    12($sp)
    lw          $insert_bit_value   8($sp)
    addi        $sp,  $sp,          24
.end_macro

.macro oneBitAdder($bit_a, $bit_b, $carry)
    addi        $sp,    $sp,        -24
    sw          $fp,                24($sp)
    sw          $ra,                20($sp)
    sw          $bit_a              16($sp)
    sw          $bit_b,             12($sp)
    sw          $carry              8($sp)
    addi        $fp,    $sp,        24


    xor		$t1,	$bit_a,	  $bit_b			   # $t5 = a xor b
    xor		$v0,	$t1,      $carry			   # $t6 = c xor (a xor b)
    and 	$t3,	$bit_a,   $bit_b 	           # $t7 = ab
    and 	$t4,	$carry,	  $t1				   # $t6 = c(a xor b)
    or 		$v1,	$t4,      $t3				   # $t6 = c(a xor b) + ab


    lw          $fp,                24($sp)
    lw          $ra,                20($sp)
    lw          $bit_a,             16($sp)
    lw          $bit_b,             12($sp)
    lw          $carry              8($sp)
    addi        $sp,  $sp,          24
.end_macro

.macro twos_complement($twos_comp_num)
    addi    $sp,    $sp,    -20
    sw      $fp,            20($sp)
    sw      $ra,            16($sp)
    sw      $twos_comp_num, 12($sp)
    sw      $a1             8($sp)
    addi    $fp,    $sp,    20

    not     $twos_comp_num, $twos_comp_num      # not of num

    move    $a0,    $twos_comp_num              # prepare argument num
    li      $a1,    1                           # prepare argument 1
    li		$a2, 	'+'
    jal     au_logical                          # num + 1

    lw      $fp,            20($sp)
    lw      $ra,            16($sp)
    lw      $twos_comp_num, 12($sp)
    lw      $a1             8($sp)
    addi    $sp,    $sp,    20
.end_macro

.macro twos_complement_if_neg($twos_comp_if_neg)
    addi    $sp,    $sp,        -16
    sw      $fp,                16($sp)
    sw      $ra,                12($sp)
    sw      $twos_comp_if_neg,  8($sp)
    addi    $fp,    $sp,        16

    bgez    $twos_comp_if_neg,  greater_than    # branch if num >= 0
    move    $a0,    $twos_comp_if_neg           # prepare argument num
    twos_complement($a0)                        # get twos comp of num
    j       end
    greater_than:
    move    $v0,    $twos_comp_if_neg
    end:

    lw      $fp,                16($sp)
    lw      $ra,                12($sp)
    lw      $twos_comp_if_neg,  8($sp)
    addi    $sp,    $sp,        16
.end_macro

.macro twos_complement_64bit($twos_comp_64_lo, $twos_comp_64_hi)
    addi    $sp,    $sp,        -28
    sw      $fp,                28($sp)
    sw      $ra,                24($sp)
    sw      $twos_comp_64_lo,   20($sp)
    sw      $twos_comp_64_hi,   16($sp)
    sw      $s0,                12($sp)
    sw      $s1,                8($sp)
    addi    $fp,    $sp,        28

    not     $s0,    $twos_comp_64_lo    # not lo
    not     $s1,    $twos_comp_64_hi    # not hi

    move    $a0,    $s0                 # prepare argument lo
    li      $a1,    1                   # prepare argument 1
    li		$a2, 	'+'
    jal     au_logical                  # lo + 1
    move    $s0,    $v0                 # save lo + 1
    move    $t0,    $v1                             # save co bit

    move    $a0,    $s1                 # prepare argument hi
    move    $a1,    $t0                 # prepare argument co
    li		$a2, 	'+'
    jal     au_logical                  # hi + co
    move    $s1,    $v0                 # save hi + co

    move    $v0,    $s0
    move    $v1,    $s1

    lw      $fp,                28($sp)
    lw      $ra,                24($sp)
    lw      $twos_comp_64_lo,   20($sp)
    lw      $twos_comp_64_hi,   16($sp)
    lw      $s0,                12($sp)
    lw      $s1,                8($sp)
    addi    $sp,    $sp,        28
.end_macro

.macro bit_replicator($bit_to_replicate)
    addi    $sp,    $sp,        -16
    sw      $fp,                16($sp)
    sw      $ra,                12($sp)
    sw      $bit_to_replicate,  8($sp)
    addi    $fp,    $sp,        16

    li      $t0,    0                               # $t0 = 32 0's
    beqz    $bit_to_replicate, replicate_zero       # if bit is zero, jump
    li      $t0,    0xFFFFFFFF                      # $t0 = 32 1's
    replicate_zero:
    move    $v0,    $t0

    lw      $fp,                16($sp)
    lw      $ra,                12($sp)
    lw      $bit_to_replicate,  8($sp)
    addi    $sp,    $sp,        16
.end_macro

.macro mul_unsigned($multiplicand, $multiplier)
    addi    $sp,    $sp,        -48
    sw      $fp,                48($sp)
    sw      $ra,                44($sp)
    sw      $multiplicand,      40($sp)
    sw      $multiplier,        36($sp)
    sw 		$s0					32($sp)
	sw 		$s1,				28($sp)
	sw 		$s2,				24($sp)
	sw 		$s3,				20($sp)
	sw 		$s4,				16($sp)
	sw 		$s5,				12($sp)
	sw 		$s6,				8($sp)
    addi    $fp,    $sp,        48

    move    $s0,    $zero           # I = 0
    move    $s1,    $zero           # H = 0
    move    $s2,    $multiplier     # L = multiplier
    move    $s4,    $multiplicand   # M = multiplicand

    mul_unsigned_loop:
    move    $a0,    $s2             # prepare argument L
    move    $a1,    $zero           # prepare argument 0

    extract_nth_bit($a0, $a1)       # get LSB from L

    move    $t0,    $v0             # save LSB from L

    move    $a0,    $t0             # prepare argument LSB from L

    bit_replicator($a0)             # replicate LSB from L

    move    $s5,    $v0             # R = {32{L[0]}}

    and     $s6,    $s4,    $s5     # X = M & R

    move    $a0,    $s1             # prepare argument H
    move    $a1,    $s6             # prepare argument X
    li		$a2, 	'+'

    jal     au_logical              # add logical H + X

    move    $s1,    $v0             # H = H + X

    srl     $s2,    $s2,    1       # L = L >> 1

    move    $a0,    $s1             # prepare argument H
    move    $a1,    $zero           # prepare argument 0

    extract_nth_bit($a0, $a1)       # get LSB of H

    move    $a2,    $v0             # prepare argument LSB of H
    move    $a0,    $s2             # prepare argument L
    li      $a1,    31              # prepare argument 31

    insert_to_nth_bit($a0, $a1, $a2)    # insert LSB of H into MSB of L

    move    $s2,    $v0             # save L

    srl     $s1,    $s1,    1       # H = H >> 1

    add     $s0,    $s0,    1       # I = I + 1

    beq     $s0,    32,     exit_mul_unsigned_loop  # if I == 32, exit loop

    j       mul_unsigned_loop       # else loop

    exit_mul_unsigned_loop:

    move    $v0,    $s2             # $v0 = lo
    move    $v1,    $s1             # $v1 = hi

    lw      $fp,                48($sp)
    lw      $ra,                44($sp)
    lw      $multiplicand,      40($sp)
    lw      $multiplier,        36($sp)
    lw 		$s0					32($sp)
	lw 		$s1,				28($sp)
	lw 		$s2,				24($sp)
	lw 		$s3,				20($sp)
	lw 		$s4,				16($sp)
	lw 		$s5,				12($sp)
	lw 		$s6,				8($sp)
    addi    $sp,    $sp,        48
.end_macro

.macro mul_signed($signed_mcnd, $signed_mplr)
    addi    $sp,    $sp,        -52
    sw      $fp,                52($sp)
    sw      $ra,                48($sp)
    sw      $signed_mcnd,       44($sp)
    sw      $signed_mplr,       40($sp)
    sw 		$s0					36($sp)
    sw 		$s1,				32($sp)
    sw 		$s2,				28($sp)
    sw 		$s3,				24($sp)
    sw 		$s4,				20($sp)
    sw 		$s5,				16($sp)
    sw 		$s6,				12($sp)
    sw      $s7,                8($sp)
    addi    $fp,    $sp,        52

    move    $s0,    $signed_mcnd    # N1
    move    $s1,    $signed_mplr    # N2

    move    $a0,    $s0             # prepare argument N1
    twos_complement_if_neg($a0)     # get twos comp if N1 is negative
    move    $s2,    $v0             # positive N1

    move    $a0,    $s1             # prepare argument N2
    twos_complement_if_neg($a0)     # get twos comp if N2 is negative
    move    $s3,    $v0             # positive N2

    move    $a0,    $s2             # prepare argument N1
    move    $a1,    $s3             # prepare argument N2
    mul_unsigned($a0, $a1)          # unsigned multiplication of N1 and N2
    move    $s4,    $v0             # Rlo
    move    $s5,    $v1             # Rhi

    move    $a0,    $s0             # prepare argument original N1
    li      $a1,    31              # prepare argument 31
    extract_nth_bit($a0, $a1)       # get MSB of original N1
    move    $s6,    $v0             # save MSB of original N1

    move    $a0,    $s1             # prepare argument original N2
    li      $a1,    31              # prepare argument 31
    extract_nth_bit($a0, $a1)       # get MSB or original N2
    move    $s7,    $v0             # save MSB of orignal N2

    xor     $s0,    $s6,    $s7         # S = $a0[31] xor $a1[31]

    beqz    $s0,    positive            # if S == 0, jump to positive

    move    $a0,    $s4                 # prepare argument Rlo
    move    $a1,    $s5                 # prepare argument Rhi

    twos_complement_64bit($a0, $a1)     # get twos comp 64 bit

    move    $s4,    $v0                 # save Rlo
    move    $s5,    $v1                 # save Rhi

    positive:

    move    $v0,    $s4                 # return Rlo
    move    $v1,    $s5                 # return Rhi

    lw      $fp,                52($sp)
    lw      $ra,                48($sp)
    lw      $signed_mcnd,       44($sp)
    lw      $signed_mplr,       40($sp)
    lw 		$s0					36($sp)
    lw 		$s1,				32($sp)
    lw 		$s2,				28($sp)
    lw 		$s3,				24($sp)
    lw 		$s4,				20($sp)
    lw 		$s5,				16($sp)
    lw 		$s6,				12($sp)
    lw      $s7,                8($sp)
    addi    $sp,    $sp,        52
.end_macro

.macro div_unsigned($unsigned_dvnd, $unsigned_dvsr)
    addi    $sp,    $sp,        -36
    sw      $fp,                36($sp)
    sw      $ra,                32($sp)
    sw      $unsigned_dvnd,     28($sp)
    sw      $unsigned_dvsr,     24($sp)
    sw      $s0,                20($sp)
    sw      $s1,                16($sp)
    sw      $s2,                12($sp)
    sw      $s3,                8($sp)
    addi    $fp,    $sp,        36

    move    $s0,    $zero           # I
    move    $s1,    $unsigned_dvnd  # Q
    move    $s2,    $unsigned_dvsr  # D
    move    $s3,    $zero           # R

    div_unsigned_loop:
    sll     $s3,    $s3,    1       # R = R << 1

    move    $a0,    $s1             # prepare argument Q
    li      $a1,    31              # prepare argument 31
    extract_nth_bit($a0, $a1)       # get MSB of Q

    move    $a0,    $s3             # prepare argument R
    move    $a1,    $zero           # prepare argument 0
    move    $a2,    $v0             # prepare argument MSB of Q
    insert_to_nth_bit($a0, $a1, $a2)    # R[0] = Q[31]
    move    $s3,    $v0             # save R

    sll     $s1,    $s1,    1       # Q = Q << 1

    move    $a0,    $s3             # prepare argument R
    move    $a1,    $s2             # prepare argument D
    li      $a2,    '-'             # prepare argument -
    jal     au_logical              # R - D
    move    $t0,    $v0             # S = R - D

    bltz    $t0,    yes             # if s is negative jump to yes

    move    $s3,    $t0             # R = S

    move    $a0,    $s1             # prepare argument Q
    move    $a1,    $zero           # prepare argument 0
    li      $a2,    1               # prepare argument 1
    insert_to_nth_bit($a0, $a1, $a2)    # insert 1 into Q[0]
    move    $s1,    $v0             # save Q

    yes:

    add     $s0,    $s0,    1       # I = I + 1

    beq     $s0,    32,     exit_div_unsigned_loop

    j       div_unsigned_loop

    exit_div_unsigned_loop:

    move    $v0,    $s1
    move    $v1,    $s3

    lw      $fp,                36($sp)
    lw      $ra,                32($sp)
    lw      $unsigned_dvnd,     28($sp)
    lw      $unsigned_dvsr,     24($sp)
    lw      $s0,                20($sp)
    lw      $s1,                16($sp)
    lw      $s2,                12($sp)
    lw      $s3,                8($sp)
    addi    $sp,    $sp,        36
.end_macro

.macro div_signed($signed_dvnd, $signed_dvsr)
    addi    $sp,    $sp,        -52
    sw      $fp,                52($sp)
    sw      $ra,                48($sp)
    sw      $signed_dvnd,       44($sp)
    sw      $signed_dvsr,       40($sp)
    sw 		$s0					36($sp)
    sw 		$s1,				32($sp)
    sw 		$s2,				28($sp)
    sw 		$s3,				24($sp)
    sw 		$s4,				20($sp)
    sw 		$s5,				16($sp)
    sw 		$s6,				12($sp)
    sw      $s7,                8($sp)
    addi    $fp,    $sp,        52

    move    $s0,    $signed_dvnd    # N1
    move    $s1,    $signed_dvsr    # N2

    move    $a0,    $s0             # prepare argument N1
    twos_complement_if_neg($a0)     # make N1 positive
    move    $s2,    $v0             # save N1

    move    $a0,    $s1             # prepare argument N2
    twos_complement_if_neg($a0)      # make N2 positive
    move    $s3,    $v0             # save N2

    move    $a0,    $s2             # prepare argument N1
    move    $a1,    $s3             # prepare argument N2
    div_unsigned($a0, $a1)          # N1 / N2
    move    $s4,    $v0             # Q
    move    $s5,    $v1             # R

    move    $a0,    $s0             # prepare argument orignal N1
    li      $a1,    31              # prepare argument 31
    extract_nth_bit($a0, $a1)       # get MSB of orignal N1
    move    $s6,    $v0             # save MSB of orignal N1

    move    $a0,    $s1             # prepare argument orignal N2
    li      $a1,    31              # prepare argument 31
    extract_nth_bit($a0, $a1)       # get MSB of orignal N2
    move    $s7,    $v0             # save MSB of orignal N2

    xor     $t0,    $s6,    $s7     # S

    beqz    $t0,    div_signed_Q_pos    # if S == 0, Q is positive

    move    $a0,    $s4                 # prepare argument Q
    twos_complement($a0)                # get twos_complement of Q
    move    $s4,    $v0                 # Q

    div_signed_Q_pos:

    beqz    $s6,    div_signed_R_pos    # is MSB of N1 is 0, R is positive

    move    $a0,    $s5                 # prepare argument R
    twos_complement($a0)                # get twos_complement of R
    move    $s5,    $v0                 # R

    div_signed_R_pos:

    move    $v0,    $s4                 # return Q
    move    $v1,    $s5                 # return R

    lw      $fp,                52($sp)
    lw      $ra,                48($sp)
    lw      $signed_dvnd,       44($sp)
    lw      $signed_dvsr,       40($sp)
    lw 		$s0					36($sp)
    lw 		$s1,				32($sp)
    lw 		$s2,				28($sp)
    lw 		$s3,				24($sp)
    lw 		$s4,				20($sp)
    lw 		$s5,				16($sp)
    lw 		$s6,				12($sp)
    lw      $s7,                8($sp)
    addi    $sp,    $sp,        52
.end_macro
