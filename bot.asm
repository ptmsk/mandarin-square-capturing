.data
        board_reserve:	.word       5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5
        bot_reserve:	.word       0, 0, 0         # soldiers, mandarins, loans
        hooman_board:       .word       5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5
        player1_reserve:    .word       0, 0, 0
        hooman_reserve:     .word       0, 0, 0
        m_reserve:		.word		0, 0
        mh_reserve:         .word       0, 0

# -------------------------------------------------------- #
# FUNCTION: FRED TURN TO MOVE     	                   #
# OUTPUT: STATUS OF GAME                                   #
# $v0 : 0 - CONT, 1 - ENDED                                #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro fred_turn
# reserve registers
        subi    $sp, $sp, 28
		sw		$a0, 0($sp)
		sw		$a1, 4($sp)
        sw      $s0, 8($sp)
        sw      $s1, 12($sp)
        sw      $t0, 16($sp)
        sw      $t1, 20($sp)
        sw      $t2, 24($sp)

# forecast selection
		li      $a0, 1
		highlight_word($0, $a0)
		delay(1000)
		fred_forecast
		move    $a0, $v1
        move    $a1, $v0
# time to move
        p2move($a0, $a1)
        move    $a0, $v0

# check if capture
        p2Capture($a0, $a1)

# check end game
		highlight_word($0, $0)
        check_end_game
        beqz    $v0, game_continue

game_ended:
        addi    $v0, $0, 1
        addi    $v1, $0, 0
        j       end_fred_turn

game_continue:
# Check if scattering
        p1_scattering
        fred_scattering

end_fred_turn:
# restore registers
		lw		$a0, 0($sp)
		lw		$a1, 4($sp)
        lw      $s0, 8($sp)
        lw      $s1, 12($sp)
        lw      $t0, 16($sp)
        lw      $t1, 20($sp)
        lw      $t2, 24($sp)
        addi    $sp, $sp, 28
.end_macro

# -------------------------------------------------------- #
# FUNCTION: CALCULATE FRED MOVE		                       #
# return direction in $v0 and chosen block in $v1		   #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro fred_forecast
# reserve registers
        subi    $sp, $sp, 48
        sw      $t8, 0($sp)
        sw      $t9, 4($sp)  
        sw      $s2, 8($sp)  
        sw      $s3, 12($sp)  
        sw      $s4, 16($sp)  
        sw      $s5, 20($sp)  
        sw      $t3, 24($sp)  
        sw      $a0, 28($sp) 
        sw      $a1, 32($sp)
        sw      $t0, 36($sp)
        sw      $t1, 40($sp) 
		sw      $t2, 44($sp) 
# choose a direction
		li	$t8, 6
		li	$t9, 12
		li	$s2, 0
		li	$t0, 7	        # block num
		li	$t1, 0	        # direction
		li	$t2, -500	# point received

        la	$a0, player2
		lw	$t3, 0($a0)
		lw	$s3, 4($a0)
		mul	$s3, $s3, 5
		add	$t3, $t3, $s3   # reserved point

# reserved data
# reserved board
        la      $a0, board
        la      $a1, board_reserve
        addi    $s3, $a0, 48
reserved_board:
        beq     $a0, $s3, end_reserved_board
        lw      $s4, 0($a0)
        sw      $s4, 0($a1)
        addi    $a0, $a0, 4
        addi    $a1, $a1, 4
        j       reserved_board
end_reserved_board:
# reserve mandarins status
		la	$a0, mandarins
		la	$a1, m_reserve
		lw	$s4, 0($a0)
		sw	$s4, 0($a1)
		lw	$s4, 4($a0)
		sw	$s4, 4($a1)
# reserve player
		la	$a0, player2
		la	$a1, bot_reserve
        addi    $s3, $a0, 12
reserve_point:
		beq	$a0, $s3, end_reserve_point
		lw	$s4, 0($a0)
		sw	$s4, 0($a1)
		addi    $a0, $a0, 4
		addi    $a1, $a1, 4
		j	reserve_point
end_reserve_point:
        la      $a0, board
choose_direction:
        addi    $t8, $t8, 1
		beq	$t8, $t9, end_choose_direction
# check empty block
		sll     $s3, $t8, 2
		add	$s3, $a0, $s3
		lw	$s4, 0($s3)
        beqz    $s4, choose_direction
# popup selection
next:
		move    $a0, $t8
        move    $a1, $s2
# time to move
        botmove($a0, $a1)
        move    $a0, $v0
# check if capture
        botCapture($a0, $a1)
# check whether gain more point or not
        is_end_game
        beq    $v0, 1, player_win
        bge    $v0, 2, continue
fred_win:
        move    $t0, $t8
	move    $t1, $s2
        li      $t8, 11         # end game
        li      $s2, 0
        j       restore
player_win:
        li      $s3, -100
        j       compare
continue:
        la	$s3, player2
		lw	$s4, 0($s3)
		lw	$s5, 4($s3)
		mul	$s5, $s5, 5
		add	$s4, $s4, $s5	# point updated
        beq     $v0, 2, compare

# Check scattering
        la      $a0, board
        addi    $a0, $a0, 28
        addi    $a1, $a0, 20
check_scatter:
        beq     $a0, $a1, scatter_sub
        lw      $s3, 0($a0)
        bne     $s3, 0, compare
        addi    $a0, $a0, 4
        j       check_scatter
scatter_sub:
        addi      $s4, $s4, -5

compare:
		sub		$s3, $s4, $t3	# point received
		sub		$s4, $s3, $t2
		addi	$s4, $s4, 1
		blez	$s4, update
		move	$t0, $t8
		move	$t1, $s2
		move	$t2, $s3
# update
update:
		beqz	$s2, update_direction
		j		update_block
update_direction:
		li		$s2, 1
		j		restore
update_block:
		li	$s2, 0
restore:
# restore data
# restore board
		la		$a1, board
		la		$a0, board_reserve
        addi    $s3, $a0, 48
restore_board:
        beq		$a0, $s3, end_restore_board
		lw		$s4, 0($a0)
		sw		$s4, 0($a1)
		addi	$a0, $a0, 4
		addi	$a1, $a1, 4
		j		restore_board
end_restore_board:
# restore mandarins status
		la		$a0, mandarins
        la		$a1, m_reserve
		lw		$s4, 0($a1)
		sw		$s4, 0($a0)
		lw		$s4, 4($a1)
		sw		$s4, 4($a0)
# restore player
		la		$a1, player2
		la		$a0, bot_reserve
        addi    $s3, $a0, 12
restore_point:
		beq		$a0, $s3, end_restore_point
		lw		$s4, 0($a0)
		sw		$s4, 0($a1)
		addi	$a0, $a0, 4
		addi	$a1, $a1, 4
		j		restore_point
end_restore_point:
        la      $a0, board
        beq     $s2, 1, next
		j		choose_direction
end_choose_direction:
		move	$v0, $t1
		move	$v1, $t0
# restore registers
        lw      $t8, 0($sp)
        lw      $t9, 4($sp)  
        lw      $s2, 8($sp)  
        lw      $s3, 12($sp)  
        lw      $s4, 16($sp)  
        lw      $s5, 20($sp)  
        lw      $t3, 24($sp)  
        lw      $a0, 28($sp) 
        lw      $a1, 32($sp)
        lw      $t0, 36($sp)
        lw      $t1, 40($sp) 
		lw      $t2, 44($sp)
		addi    $sp, $sp, 48 
.end_macro	

# -------------------------------------------------------- #
# FUNCTION: MOVE A SOLDIERS BY BOT'S CHOICE                #
# INPUT: $a0, $a1                                          #
# %block_num = the block bot chosen (7 - 11)   			   #
# $direction = 0 for left, 1 for right                     #
# OUTPUT: $v0 = the next block of last accessed block      #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro botmove(%block_num, %direction)
# reserve registers
        subi    $sp, $sp, 24
        sw      $s0, 0($sp)
        sw      $a0, 4($sp)  
        sw      $a1, 8($sp)  
        sw      $t1, 12($sp)  
        sw      $t2, 16($sp)  
        sw      $s1, 20($sp)
# Getting data
        la      $s0, board
        addi    $a0, %block_num, 0
        addi    $a1, %direction, 0
        addi    $t1, $0, 6
move_loop_cond:
        beqz    $a0, move_loop_end
        beq     $a0, $t1, move_loop_end
        sll     $t2, $a0, 2
        add     $s1, $s0, $t2
        lw      $t2, 0($s1)
        beqz    $t2, move_loop_end
        beqz    $a1, move_left
move_right:
        bot_mccw($a0)
        move    $a0, $v0
        j       move_loop_cond
move_left:
        bot_mcw($a0)
        move    $a0, $v0
        j       move_loop_cond
move_loop_end:
# return value
        move    $v0, $a0
# restore registers
        lw      $s0, 0($sp)
        lw      $a0, 4($sp)  
        lw      $a1, 8($sp)  
        lw      $t1, 12($sp)  
        lw      $t2, 16($sp)  
        lw      $s1, 20($sp)
        addi    $sp, $sp, 24
.end_macro


# -------------------------------------------------------- #
# FUNCTION: MOVE A SOLDIERS CLOCKWISE                      #
# INPUT: $a0                                               #
# %block_num = the block chosen (7 - 11)                   #
# OUTPUT: $v0 = the next block of last accessed block      #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro bot_mcw(%block_num)
# reserve registers
        subi    $sp, $sp, 44
        sw      $s0, 0($sp)
        sw      $a0, 4($sp)  
        sw      $t1, 8($sp)  
        sw      $s1, 12($sp)  
        sw      $t2, 16($sp)  
        sw      $t3, 20($sp)  
        sw      $a1, 24($sp)  
        sw      $a2, 28($sp) 
        sw      $t4, 32($sp)
        sw      $s2, 36($sp)
        sw      $t5, 40($sp) 

# Getting data
        la      $s0, board
        addi    $a0, %block_num, 0
        sll     $t1, $a0, 2
        add     $s1, $s0, $t1
        lw      $t2, 0($s1)
        sw      $zero, 0($s1)
        addi    $t3, $0, 12
        addi    $a1, $0, 1
        addi    $t4, $0, 6
movecw:
        beq     $t2, 0, end_movecw
        addi    $a0, $a0, 1
        div     $a0, $t3
        mfhi    $a0
        sll     $t1, $a0, 2
        add     $s1, $s0, $t1
        lw      $a2, 0($s1)  
        beqz    $a0, if_first_mandarin
        beq     $a0, $t4,if_second_mandarin
if_normal:
        j       end_if
if_first_mandarin:
        la      $s2, mandarins
        lw      $t5, 0($s2)
        bnez    $t5, if_normal
        j       end_if
if_second_mandarin:
        la      $s2, mandarins
        lw      $t5, 4($s2)
        bnez    $t5, if_normal
        j       end_if
end_if:
        addi    $a2, $a2, 1
        sw      $a2, 0($s1)
        addi    $t2, $t2, -1
        j       movecw
end_movecw:
# return the output
        addi    $a0, $a0, 1
        div     $a0, $t3
        mfhi    $a0
        move    $v0, $a0
# restore registers
        lw      $s0, 0($sp)
        lw      $a0, 4($sp)  
        lw      $t1, 8($sp)  
        lw      $s1, 12($sp)  
        lw      $t2, 16($sp)  
        lw      $t3, 20($sp)  
        lw      $a1, 24($sp)  
        lw      $a2, 28($sp) 
        lw      $t4, 32($sp)
        lw      $s2, 36($sp)
        lw      $t5, 40($sp)
        addi    $sp, $sp, 44
.end_macro


# -------------------------------------------------------- #
# FUNCTION: MOVE A SOLDIERS COUNTER CLOCKWISE              #
# INPUT: $a0                                               #
# %block_num = the block chosen (7 - 11)                   #
# OUTPUT: $v0 = the next block of last accessed block      #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro bot_mccw(%block_num)
# reserve registers
        subi    $sp, $sp, 48
        sw      $s0, 0($sp)
        sw      $a0, 4($sp)  
        sw      $t1, 8($sp)  
        sw      $s1, 12($sp)  
        sw      $t2, 16($sp)  
        sw      $t3, 20($sp)  
        sw      $a1, 24($sp)  
        sw      $a2, 28($sp) 
        sw      $t0, 32($sp)
        sw      $t4, 36($sp)
        sw      $s2, 40($sp)
        sw      $t5, 44($sp) 
# Getting data & remove the chosen block
        la      $s0, board
        addi    $a0, %block_num, 0
        sll     $t1, $a0, 2
        add     $s1, $s0, $t1
        lw      $t2, 0($s1)
        sw		$zero, 0($s1)
        addi    $t3, $0, 12
        addi    $t4, $0, 6
        addi    $a1, $0, 1
        sub     $t0, $t3, $a0
moveccw:
        beq     $t2, 0, end_moveccw        
        div     $t0, $t3
        mfhi    $t0
        addi    $t0, $t0, 1
        sub     $a0, $t3, $t0
        sll     $t1, $a0, 2
        add     $s1, $s0, $t1
        lw      $a2, 0($s1)  
        beqz    $a0, if_first_mandarin
        beq     $a0, $t4, if_second_mandarin
if_normal:
        j       end_if
if_first_mandarin:
        la      $s2, mandarins
        lw      $t5, 0($s2)
        bnez    $t5, if_normal
        j       end_if
if_second_mandarin:
        la      $s2, mandarins
        lw      $t5, 4($s2)
        bnez    $t5, if_normal
        j       end_if
end_if:
        addi    $a2, $a2, 1
        sw      $a2, 0($s1)
        addi    $t2, $t2, -1
        j       moveccw
end_moveccw:
# return the output
        div     $t0, $t3
        mfhi    $t0
        addi    $t0, $t0, 1
        sub     $a0, $t3, $t0
        move    $v0, $a0
# restore registers
        lw      $s0, 0($sp)
        lw      $a0, 4($sp)  
        lw      $t1, 8($sp)  
        lw      $s1, 12($sp)  
        lw      $t2, 16($sp)  
        lw      $t3, 20($sp)  
        lw      $a1, 24($sp)  
        lw      $a2, 28($sp) 
        lw      $t0, 32($sp)
        lw      $t4, 36($sp)
        lw      $s2, 40($sp)
        lw      $t5, 44($sp)
        addi    $sp, $sp, 48
.end_macro

# -------------------------------------------------------- #
# FUNCTION: CAPTURE BLOCKS CLOCKWISE                       #
# INPUT: $a0, $a1                                          #
# %block_num = the block fred chosen (7 - 11)    		   #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro bot_cpcw(%block_num)
# reserve registers
        subi    $sp, $sp, 48
        sw      $s0, 0($sp)
        sw      $s1, 4($sp)
        sw      $s2, 8($sp)
        sw      $s3, 12($sp)
        sw      $t0, 16($sp)
        sw      $t1, 20($sp)
        sw      $t2, 24($sp)
        sw      $t3, 28($sp)
        sw      $t4, 32($sp)
        sw      $a0, 36($sp)
        sw      $a1, 40($sp)
        sw      $a2, 44($sp)

# getting data
        la      $s0, board
        addi    $a0, %block_num, 0
        addi    $a2, $0, 1
        addi    $t0, $0, 12
        addi    $t1, $0, 6
        addi    $a1, $0, 1
        la      $s2, player2
capture_loop_cond:
        sll     $t2, $a0, 2
        add     $s1, $s0, $t2
        lw      $t2, 0($s1)
        bnez    $t2, capture_loop_end
        addi    $a0, $a0, 1
        div     $a0, $t0
        mfhi    $a0
        sll     $t2, $a0, 2
        add     $s1, $s0, $t2
        lw      $t2, 0($s1)
        beqz    $t2, capture_loop_end
        beqz    $a0, capture_first_mandarins
        beq     $a0, $t1, capture_second_mandarins
        
capture_soldiers:
        lw      $t3, 0($s2)        
        add     $t3, $t3, $t2
        sw      $t3, 0($s2)
        sw		$0, 0($s1)
        addi    $a0, $a0, 1
        div     $a0, $t0
        mfhi    $a0
        j       capture_loop_cond
        
capture_first_mandarins: 
        la      $s3, mandarins
        lw      $t4, 0($s3)
        bnez    $t4, capture_soldiers
        slti    $t4, $t2, 10
        beq     $t4, $a1, capture_loop_end
        lw      $t3, 4($s2)
        addi    $t3, $t3, 1
        sw      $t3, 4($s2)
        addi    $t4, $a2, 1
        sw      $t4, 0($s3)
        addi    $t2, $t2, -5
        j       capture_soldiers        
        
capture_second_mandarins:
        la      $s3, mandarins
        lw      $t4, 4($s3)
        bnez    $t4, capture_soldiers
        slti    $t4, $t2, 10
        beq     $t4, $a1, capture_loop_end
        lw      $t3, 4($s2)
        addi    $t3, $t3, 1
        sw      $t3, 4($s2)
        addi    $t4, $a2, 1
        sw      $t4, 4($s3)
        addi    $t2, $t2, -5
        j       capture_soldiers   
capture_loop_end:

# restore register
        lw      $s0, 0($sp)
        lw      $s1, 4($sp)
        lw      $s2, 8($sp)
        lw      $s3, 12($sp)
        lw      $t0, 16($sp)
        lw      $t1, 20($sp)
        lw      $t2, 24($sp)
        lw      $t3, 28($sp)
        lw      $t4, 32($sp)
        lw      $a0, 36($sp)
        lw      $a1, 40($sp)
        lw      $a2, 44($sp)
        addi    $sp, $sp, 48
.end_macro

# -------------------------------------------------------- #
# FUNCTION: CAPTURE BLOCKS COUNTER CLOCKWISE               #
# INPUT: $a0, $a1                                          #
# %block_num = the block bot chosen (7 - 11)  			   #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro bot_cpccw(%block_num)
# reserve registers
        subi    $sp, $sp, 52
        sw      $s0, 0($sp)
        sw      $s1, 4($sp)
        sw      $s2, 8($sp)
        sw      $s3, 12($sp)
        sw      $t0, 16($sp)
        sw      $t1, 20($sp)
        sw      $t2, 24($sp)
        sw      $t3, 28($sp)
        sw      $t4, 32($sp)
        sw      $a0, 36($sp)
        sw      $a1, 40($sp)
        sw      $a2, 44($sp)
        sw      $t5, 48($sp)

# getting data
        la      $s0, board
        addi    $a0, %block_num, 0
        addi    $a2, $0, 1
        addi    $t0, $0, 12
        addi    $t1, $0, 6
        addi    $a1, $0, 1
        sub     $t5, $t0, $a0
        la      $s2, player2
capture_loop_cond:
        sll     $t2, $a0, 2
        add     $s1, $s0, $t2
        lw      $t2, 0($s1)
        bnez    $t2, capture_loop_end
        div     $t5, $t0
        mfhi    $t5
        addi    $t5, $t5, 1
        sub     $a0, $t0, $t5
        sll     $t2, $a0, 2
        add     $s1, $s0, $t2
        lw      $t2, 0($s1)
        beqz    $t2, capture_loop_end
        beqz    $a0, capture_first_mandarins
        beq     $a0, $t1, capture_second_mandarins
capture_soldiers:
        lw      $t3, 0($s2)        
        add     $t3, $t3, $t2
        sw      $t3, 0($s2)
        sw	$0, 0($s1)
        div     $t5, $t0
        mfhi    $t5
        addi    $t5, $t5, 1
        sub     $a0, $t0, $t5
        j       capture_loop_cond
        
capture_first_mandarins: 
        la      $s3, mandarins
        lw      $t4, 0($s3)
        bnez    $t4, capture_soldiers
        slti    $t4, $t2, 10
        beq     $t4, $a1, capture_loop_end
        lw      $t3, 4($s2)
        addi    $t3, $t3, 1
        sw      $t3, 4($s2)
        addi    $t4, $a2, 1
        sw      $t4, 0($s3)
        addi    $t2, $t2, -5
        j       capture_soldiers        

capture_second_mandarins:
        la      $s3, mandarins
        lw      $t4, 4($s3)
        bnez    $t4, capture_soldiers
        slti    $t4, $t2, 10
        beq     $t4, $a1, capture_loop_end

        lw      $t3, 4($s2)
        addi    $t3, $t3, 1
        sw      $t3, 4($s2)
        addi    $t4, $a2, 1
        sw      $t4, 4($s3)
        addi    $t2, $t2, -5
        j       capture_soldiers   

capture_loop_end:

# restore register
        lw      $s0, 0($sp)
        lw      $s1, 4($sp)
        lw      $s2, 8($sp)
        lw      $s3, 12($sp)
        lw      $t0, 16($sp)
        lw      $t1, 20($sp)
        lw      $t2, 24($sp)
        lw      $t3, 28($sp)
        lw      $t4, 32($sp)
        lw      $a0, 36($sp)
        lw      $a1, 40($sp)
        lw      $a2, 44($sp)
        lw      $t5, 48($sp)
        addi    $sp, $sp, 52
.end_macro

# -------------------------------------------------------- #
# FUNCTION: BOT CAPTURE A BLOCK                       	   #
# INPUT: $a0, $a1                                          #
# %block_num = the block bot chosen (7 - 11)    		   #
# $direction = 0 for left, 1 for right                     #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro botCapture(%block_num, %direction)
# reserve registers
        subi    $sp, $sp, 16
        sw      $s0, 0($sp)
        sw      $a0, 4($sp)
        sw      $a1, 8($sp)
        sw      $a2, 12($sp)

# getting data
        la      $s0, board
        addi    $a0, %block_num, 0
        addi    $a1, %direction, 0
        addi    $a2, $0, 1
        beqz    $a1, capture_left

capture_right:
        bot_cpccw($a0)
        j       capture_end
capture_left:
        bot_cpcw($a0)
capture_end:
# restore register
        sw      $s0, 0($sp)
        sw      $a0, 4($sp)
        sw      $a1, 8($sp)
        sw      $a2, 12($sp)
        addi    $sp, $sp, 16
.end_macro


# -------------------------------------------------------- #
# FUNCTION: END GAME STATUS                                #
# OUTPUT: $v0 						   #
# 0 - BOT WIN   					   #
# 1 - PLAYER WIN                                           #
# 2 - DRAW MATCH                                           #
# 3 - THE GAME IS CONTINUE                                 #
# -------------------------------------------------------- #

.macro is_end_game

# reserve registers
        subi    $sp, $sp, 24
        sw      $s0, 0($sp)
        sw      $s1, 4($sp)  
        sw      $s2, 8($sp)  
        sw      $t1, 12($sp)  
        sw      $t2, 16($sp)  
        sw      $t0, 20($sp)

# Getting data
        la      $s0, board
        lw	$t1, 0($s0)
        lw      $t2, 24($s0)
	add 	$t2, $t2, $t1
        beqz	$t2, return_true
        li      $v0, 3
	j	end_checking

return_true:
	la 	$s1, player1
	la 	$s2, player2
        # Calculate difference between bot and player1
        lw      $t0, 0($s2)
        lw      $t1, 4($s2)
        mul     $t1, $t1, 5
        add     $t0, $t0, $t1
        lw      $t1, 8($s2)
        sub     $t0, $t0, $t1

        lw      $t1, 0($s1)
        sub     $t0, $t0, $t1
        lw      $t1, 4($s1)
        mul     $t1, $t1, 5
        sub     $t0, $t0, $t1
        lw      $t1, 8($s1)
        add     $t0, $t0, $t1

        addi    $s1, $s0, 24
player_collect:        
        addi    $s0, $s0, 4
        beq     $s0, $s1, end_player_collect
        lw      $t1, 0($s0)
        sub     $t0, $t0, $t1
        j       player_collect
end_player_collect:
        addi    $s1, $s0, 24

bot_collect:
	addi    $s0, $s0, 4
        beq     $s0, $s1, end_bot_collect
        lw      $t1, 0($s0)
        add     $t0, $t0, $t1
        j       bot_collect
end_bot_collect:
        beqz    $t0, draw_match
        slti    $t1, $t0, 0
        beqz    $t1, bot_win
        li      $v0, 1
        j       end_checking
draw_match:
        li      $v0, 2
        j       end_checking
bot_win:
        li      $v0, 0

end_checking:
#restore registers
        lw      $s0, 0($sp)
        lw      $s1, 4($sp)  
        lw      $s2, 8($sp)  
        lw      $t1, 12($sp)  
        lw      $t2, 16($sp)  
        lw      $t0, 20($sp)
	addi    $sp, $sp, 24

.end_macro

# -------------------------------------------------------- #
# FUNCTION: FRED SCATTERING				   #
# -------------------------------------------------------- #
.macro fred_scattering
# reserve registers
        subi    $sp, $sp, 40
        sw      $s0, 0($sp)
        sw      $s1, 4($sp)  
        sw      $s2, 8($sp)  
        sw      $t0, 12($sp)  
        sw      $t1, 16($sp)  
        sw      $t2, 20($sp)  
        sw      $t3, 24($sp)  
        sw      $a0, 28($sp) 
        sw      $a1, 32($sp)
        sw      $v0, 36($sp)

# getting data
        la   	$s0, board
        la	    $s1, player1
        la	    $s2, player2
        li	    $t0, 1
        li	    $t1, 24
        li 	    $t4, 44
	
check_scatter:
        ble	    $t4, $t1, mes
        add	    $t2, $t4, $s0
        lw 	    $t3, 0($t2)
        bnez	$t3, end_not_scatter
        subi	$t4, $t4, 4
        j 	    check_scatter
	
mes:
        fill_side_fred
        lw  	$t1, 0($s2)
        li  	$t2, 5
        blt 	$t1, $t2, update_soldiers
        remove_soldier_points($t0, $t1, $t2)
        subi	$t1, $t1, 5
        sw  	$t1, 0($s2)
        li  	$t0, 1
        li  	$t1, 6
        li  	$t4, 11
        j   	scatter
	
update_soldiers:	
        fill_side_borrow_fred
        lw	    $t3, 0($s1)
        remove_soldier_points($0, $t3, $t2)
        subi	$t3, $t3, 5
        sw  	$t3, 0($s1)
        lw  	$t3, 8($s2)
        addi	$t3, $t3, 5
        sw  	$t3, 8($s2)
        
        li  	$t0, 1
        li  	$t1, 6
        li  	$t4, 11

scatter:
        ble 	$t4, $t1, end
        sll 	$t3, $t4, 2
        add 	$t2, $t3, $s0
        sw   	$t0, 0($t2)	
        highlight($t4, $0)
        draw_soldiers($t4, $t0, $0, $t0)
        update_point($t4)
        highlight($t4, $t0)
        subi	$t4, $t4, 1
        j   	scatter
end:
        
        la  	$a0, scatter_success
        la  	$a1, 1
        li  	$v0, 55
        syscall
        update_player_point

end_not_scatter:
# restore registers
	    lw      $s0, 0($sp)
        lw      $s1, 4($sp)  
        lw      $s2, 8($sp)  
        lw      $t0, 12($sp)  
        lw      $t1, 16($sp)  
        lw      $t2, 20($sp)  
        lw      $t3, 24($sp)  
        lw      $a0, 28($sp) 
        lw      $a1, 32($sp)
        lw      $v0, 36($sp)
        addi    $sp, $sp, 40	

.end_macro


# -------------------------------------------------------- #
# FUNCTION: EVIE SCATTERING				   #
# -------------------------------------------------------- #
.macro evie_scattering
# reserve registers
        subi    $sp, $sp, 40
        sw      $s0, 0($sp)
        sw      $s1, 4($sp)  
        sw      $s2, 8($sp)  
        sw      $t0, 12($sp)  
        sw      $t1, 16($sp)  
        sw      $t2, 20($sp)  
        sw      $t3, 24($sp)  
        sw      $a0, 28($sp) 
        sw      $a1, 32($sp)
        sw      $v0, 36($sp)

# getting data
        la   	$s0, board
        la	    $s1, player1
        la	    $s2, player2
        li	    $t0, 1
        li	    $t1, 24
        li 	    $t4, 44
	
check_scatter:
        ble	    $t4, $t1, mes
        add	    $t2, $t4, $s0
        lw 	    $t3, 0($t2)
        bnez	$t3, end_not_scatter
        subi	$t4, $t4, 4
        j 	    check_scatter
	
mes:
        fill_side_evie
        lw  	$t1, 0($s2)
        li  	$t2, 5
        blt 	$t1, $t2, update_soldiers
        remove_soldier_points($t0, $t1, $t2)
        subi	$t1, $t1, 5
        sw  	$t1, 0($s2)
        li  	$t0, 1
        li  	$t1, 6
        li  	$t4, 11
        j   	scatter
	
update_soldiers:	
        fill_side_borrow_evie
        lw	    $t3, 0($s1)
        remove_soldier_points($0, $t3, $t2)
        subi	$t3, $t3, 5
        sw  	$t3, 0($s1)
        lw  	$t3, 8($s2)
        addi	$t3, $t3, 5
        sw  	$t3, 8($s2)
        
        li  	$t0, 1
        li  	$t1, 6
        li  	$t4, 11

scatter:
        ble 	$t4, $t1, end
        sll 	$t3, $t4, 2
        add 	$t2, $t3, $s0
        sw   	$t0, 0($t2)	
        highlight($t4, $0)
        draw_soldiers($t4, $t0, $0, $t0)
        update_point($t4)
        highlight($t4, $t0)
        subi	$t4, $t4, 1
        j   	scatter
end:
        
        la  	$a0, scatter_success
        la  	$a1, 1
        li  	$v0, 55
        syscall
        update_player_point

end_not_scatter:
# restore registers
	    lw      $s0, 0($sp)
        lw      $s1, 4($sp)  
        lw      $s2, 8($sp)  
        lw      $t0, 12($sp)  
        lw      $t1, 16($sp)  
        lw      $t2, 20($sp)  
        lw      $t3, 24($sp)  
        lw      $a0, 28($sp) 
        lw      $a1, 32($sp)
        lw      $v0, 36($sp)
        addi    $sp, $sp, 40	
.end_macro


# -------------------------------------------------------- #
# FUNCTION: PLAYER1 TURN TO MOVE                           #
# OUTPUT: STATUS OF GAME                                   #
# $v0 : 0 - CONT, 1 - ENDED                                #
# $v1 : 1 - NORMAL ENDING                                  #
#     : 4 - PLAYER QUIT                                    #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro player1Turn_vs_fred
# reserve registers
        subi    $sp, $sp, 32
        sw      $a0, 0($sp)
        sw      $a1, 4($sp)
        sw      $a2, 8($sp)
        sw      $t0, 12($sp)
        sw      $t1, 16($sp)
        sw      $t2, 20($sp)
        sw      $s0, 24($sp)
        sw      $s1, 28($sp)
# getting data
        addi    $a2, $0, 1
# popup selection
        draw_upper_block_number
        highlight_word($a2, $a2)
        player1fig
        beq     $v0, -1, player_quit
        move    $a0, $v1
        move    $a1, $v0
        remove_upper_block_number

# time to move
        p1move($a0, $a1)
        move    $a0, $v0

# check if capture
        p1Capture($a0, $a1)

# check end game
        highlight_word($a2, $0)
        check_end_game
        beqz    $v0, game_continue # Game status: continue

game_ended:
        addi    $v0, $0, 1
        addi    $v1, $0, 0
        j       end_player1_turn

player_quit:
        addi    $v0, $0, 1
        addi    $v1, $0, 4
        j       end_player1_turn

game_continue:
# check if scattering
        p1_scattering
        fred_scattering
end_player1_turn:

# restore registers
        lw      $a0, 0($sp)
        lw      $a1, 4($sp)
        lw      $a2, 8($sp)
        lw      $t0, 12($sp)
        lw      $t1, 16($sp)
        lw      $t2, 20($sp)
        lw      $s0, 24($sp)
        lw      $s1, 28($sp)
        addi    $sp, $sp, 32
.end_macro

# -------------------------------------------------------- #
# FUNCTION: PLAYER1 TURN TO MOVE                           #
# OUTPUT: STATUS OF GAME                                   #
# $v0 : 0 - CONT, 1 - ENDED                                #
# $v1 : 1 - NORMAL ENDING                                  #
#     : 4 - PLAYER QUIT                                    #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro player1Turn_vs_evie
# reserve registers
        subi    $sp, $sp, 32
        sw      $a0, 0($sp)
        sw      $a1, 4($sp)
        sw      $a2, 8($sp)
        sw      $t0, 12($sp)
        sw      $t1, 16($sp)
        sw      $t2, 20($sp)
        sw      $s0, 24($sp)
        sw      $s1, 28($sp)
# getting data
        addi    $a2, $0, 1
# popup selection
        draw_upper_block_number
        highlight_word($a2, $a2)
        player1fig
        beq     $v0, -1, player_quit
        move    $a0, $v1
        move    $a1, $v0
        remove_upper_block_number

# time to move
        p1move($a0, $a1)
        move    $a0, $v0

# check if capture
        p1Capture($a0, $a1)

# check end game
        highlight_word($a2, $0)
        check_end_game
        beqz    $v0, game_continue # Game status: continue

game_ended:
        addi    $v0, $0, 1
        addi    $v1, $0, 0
        j       end_player1_turn

player_quit:
        addi    $v0, $0, 1
        addi    $v1, $0, 4
        j       end_player1_turn

game_continue:
# check if scattering
        p1_scattering
        evie_scattering
end_player1_turn:

# restore registers
        lw      $a0, 0($sp)
        lw      $a1, 4($sp)
        lw      $a2, 8($sp)
        lw      $t0, 12($sp)
        lw      $t1, 16($sp)
        lw      $t2, 20($sp)
        lw      $s0, 24($sp)
        lw      $s1, 28($sp)
        addi    $sp, $sp, 32
.end_macro


# -------------------------------------------------------- #
# FUNCTION: EVIE TURN TO MOVE                       #
# OUTPUT: STATUS OF GAME                                   #
# $v0 : 0 - CONT, 1 - P1WIN, 2 - P2WIN, 3 - DRAW           #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro evie_turn
# reserve registers
        subi    $sp, $sp, 28
	sw	$a0, 0($sp)
	sw	$a1, 4($sp)
        sw      $s0, 8($sp)
        sw      $s1, 12($sp)
        sw      $t0, 16($sp)
        sw      $t1, 20($sp)
        sw      $t2, 24($sp)

# forecast selection
	li      $a0, 1
        li      $t0, 3
	highlight_word($t0, $a0)
	delay(1000)
	evie_forecast
	move    $a0, $v1
        move    $a1, $v0
# time to move
        p2move($a0, $a1)
        move    $a0, $v0

# check if capture
        p2Capture($a0, $a1)

# check end game
	highlight_word($t0, $0)
        check_end_game
        beqz    $v0, game_continue

game_ended:
        addi    $v0, $0, 1
        addi    $v1, $0, 0
        j       end_evie_turn

game_continue:
#Check if scattering
        p1_scattering
        p2_scattering

end_evie_turn:
# restore registers
	lw	$a0, 0($sp)
	lw	$a1, 4($sp)
        lw      $s0, 8($sp)
        lw      $s1, 12($sp)
        lw      $t0, 16($sp)
        lw      $t1, 20($sp)
        lw      $t2, 24($sp)
        addi    $sp, $sp, 28
.end_macro

# -------------------------------------------------------- #
# FUNCTION: CALCULATE EVIE MOVE		           #
# return direction in $v0 and chosen block in $v1          #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro evie_forecast
# reserve register
        subi    $sp, $sp, 48
        sw      $t0, 0($sp)
        sw      $t1, 4($sp)
        sw      $t2, 8($sp)
        sw      $t3, 12($sp)
        sw      $t8, 16($sp)
        sw      $t9, 20($sp)  
        sw      $s2, 24($sp)  
        sw      $s3, 28($sp)  
        sw      $s4, 32($sp)  
        sw      $s5, 36($sp)
        sw      $a0, 40($sp)
        sw      $a1, 44($sp)
# choose a direction
	li      $t8, 6
	li	$t9, 12
	li	$s2, 0
	li	$t0, 7	# block num
	li	$t1, 0	# direction
	li	$t2, -500	# max difference between current received
                                # points and next player's max received point
        la      $a0, player2
        lw      $t3, 0($a0)
        lw      $s3, 4($a0)
        mul     $s3, $s3, 5
        add     $t3, $t3, $s3   # reserved points

# reserved data
# reserved board
        la      $a0, board
        la      $a1, board_reserve
        addi    $s3, $a0, 48
reserved_board:
        beq     $a0, $s3, end_reserved_board
        lw      $s4, 0($a0)
        sw      $s4, 0($a1)
        addi    $a0, $a0, 4
        addi    $a1, $a1, 4
        j       reserved_board
end_reserved_board:
# reserve mandarins status
	la	$a0, mandarins
	la	$a1, m_reserve
	lw	$s4, 0($a0)
	sw	$s4, 0($a1)
	lw	$s4, 4($a0)
	sw	$s4, 4($a1)
# reserve player
        la      $a0, player1
        la      $a1, player1_reserve
        addi    $s3, $a0, 12
reserved_player1:
        beq     $a0, $s3, end_reserved_player1
        lw      $s4, 0($a0)
        sw      $s4, 0($a1)
        addi    $a0, $a0, 4
        addi    $a1, $a1, 4
        j       reserved_player1
end_reserved_player1:
# reserve evie
	la	$a0, player2
	la	$a1, bot_reserve
        addi    $s3, $a0, 12
reserve_point:
	beq	$a0, $s3, end_reserve_point
	lw	$s4, 0($a0)
	sw	$s4, 0($a1)
	addi    $a0, $a0, 4
	addi    $a1, $a1, 4
	j	reserve_point
end_reserve_point:
        la      $a0, board
choose_direction:
        addi    $t8, $t8, 1
        beq     $t8, $t9, end_choose_direction
        sll     $s3, $t8, 2
	add	$s3, $a0, $s3
	lw	$s4, 0($s3)
        beqz    $s4, choose_direction
# popup selection
next:
	move    $a0, $t8
        move    $a1, $s2
# time to move
        botmove($a0, $a1)
        move    $a0, $v0
# check if capture
        botCapture($a0, $a1)

# check end game
        is_end_game
        beq    $v0, 1, player_win
        bge    $v0, 2, continue
evie_win:
        move    $t0, $t8
	move    $t1, $s2
        li      $t8, 11         # end game
        li      $s2, 0
        j       restore
player_win:
        li      $s4, -100
        j       compare
continue:
        la	$s3, player2
	lw	$s4, 0($s3)
	lw	$s5, 4($s3)
	mul	$s5, $s5, 5
	add	$s4, $s4, $s5	# point updated
        sub     $s4, $s4, $t3   # point received
        beq     $v0, 2, compare

# scattering
        prep1_scattering
        beq     $v0, 0, next_scattering
        addi    $s4, $s4, 5
next_scattering:
        bot_scattering
        beq     $v0, 0, compare
        subi    $s4, $s4, 5

compare:
# check whether gain more point or not
        max_playerget
        sub     $s4, $s4, $v0   # current difference points
        slt     $s3, $t2, $s4
        beqz    $s3, update
        move    $t0, $t8
	move	$t1, $s2
        move    $t2, $s4
# update
update:
        beqz	$s2, update_direction
	j	update_block
update_direction:
	li	$s2, 1
	j	restore
update_block:
	li	$s2, 0
restore:
# restore data
# restore board
	la	$a1, board
	la	$a0, board_reserve
        addi    $s3, $a0, 48
restore_board:
        beq	$a0, $s3, end_restore_board
	lw	$s4, 0($a0)
	sw	$s4, 0($a1)
	addi	$a0, $a0, 4
	addi	$a1, $a1, 4
	j	restore_board
end_restore_board:
# restore mandarins status
	la	$a0, mandarins
        la	$a1, m_reserve
	lw	$s4, 0($a1)
	sw	$s4, 0($a0)
	lw	$s4, 4($a1)
	sw	$s4, 4($a0)
# restore player
        la      $a1, player1
        la      $a0, player1_reserve
        addi    $s3, $a0, 12
restore_player1:
        beq     $a0, $s3, end_restore_player1
        lw      $s4, 0($a0)
        sw      $s4, 0($a1)
        addi    $a0, $a0, 4
        addi    $a1, $a1, 4
        j       restore_player1
end_restore_player1:
# restore evie
	la	$a1, player2
	la	$a0, bot_reserve
        addi    $s3, $a0, 12
restore_point:
	beq	$a0, $s3, end_restore_point
	lw	$s4, 0($a0)
	sw	$s4, 0($a1)
	addi	$a0, $a0, 4
	addi	$a1, $a1, 4
	j	restore_point
end_restore_point:
        la      $a0, board
        beq      $s2, 1, next
	j	choose_direction
end_choose_direction:
	move	$v0, $t1
	move	$v1, $t0
# restore registers
        lw      $t0, 0($sp)
        lw      $t1, 4($sp)
        lw      $t2, 8($sp)
        lw      $t3, 12($sp)
        lw      $t8, 16($sp)
        lw      $t9, 20($sp)  
        lw      $s2, 24($sp)  
        lw      $s3, 28($sp)  
        lw      $s4, 32($sp)  
        lw      $s5, 36($sp)
        lw      $a0, 40($sp)
        lw      $a1, 44($sp)
        addi    $sp, $sp, 48
.end_macro


# -------------------------------------------------------- #
# FUNCTION: CALCULATE MAXIMUM POINTS OF PLAYER 1           #
# return maximum point in $v0                   	   #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro max_playerget
# reserve register
        subi    $sp, $sp, 40
        sw      $t8, 0($sp)
        sw      $t9, 4($sp)  
        sw      $s2, 8($sp)  
        sw      $s3, 12($sp)  
        sw      $s4, 16($sp)  
        sw      $s5, 20($sp)
        sw      $a0, 24($sp) 
        sw      $a1, 28($sp)
        sw      $t0, 32($sp)
        sw      $t1, 36($sp) 
# Choose direction:
        li      $t8, 0
        li      $t9, 6
        li      $s2, 0
        li      $t0, -500          # max received points

        la      $a0, player1
        lw      $t1, 0($a0)
        lw      $s3, 4($a0)
        mul     $s3, $s3, 5
        add     $t1, $t1, $s3   # reserved points

# reserved data
# reserved board
        la      $a0, board
        la      $a1, hooman_board
        addi    $s3, $a0, 48
reserved_board:
        beq     $a0, $s3, end_reserved_board
        lw      $s4, 0($a0)
        sw      $s4, 0($a1)
        addi    $a0, $a0, 4
        addi    $a1, $a1, 4
        j       reserved_board
end_reserved_board:
# reserve mandarins status
	la	$a0, mandarins
	la	$a1, mh_reserve
	lw	$s4, 0($a0)
	sw	$s4, 0($a1)
	lw	$s4, 4($a0)
	sw	$s4, 4($a1)
# reserve player
	la	$a0, player1
	la	$a1, hooman_reserve
	addi    $s3, $a0, 12
reserve_point:
	beq	$a0, $s3, end_reserve_point
	lw	$s4, 0($a0)
	sw	$s4, 0($a1)
	addi	$a0, $a0, 4
	addi	$a1, $a1, 4
	j	reserve_point
end_reserve_point:
        la      $a0, board
   
choose_direction:
        addi    $t8, $t8, 1
        beq     $t8, $t9, end_choose_direction
# check empty block
        sll     $s3, $t8, 2
	add	$s3, $a0, $s3
	lw	$s4, 0($s3)
        beqz    $s4, choose_direction

# popup selection
next:
	move    $a0, $t8
        move    $a1, $s2
# time to move
        prep1move($a0, $a1)
        move    $a0, $v0
# check if capture
        prep1Capture($a0, $a1)      

# check end game
        is_end_game
        beq     $v0, 1, player_win
        bge     $v0, 2, continue
bot_win:
        li      $s4, -100
        j       compare
player_win:
        li      $t0, 150        # end game
        li      $t8, 5
        li      $s2, 0
        j       restore
continue:
        la      $s3, player1
        lw      $s4, 0($s3)
        lw      $s5, 4($s3)
        mul     $s5, $s5, 5
        add     $s4, $s4, $s5   # point updated
        beq     $v0, 2, compare

# Check scattering
        la      $a0, board
        addi    $a0, $a0, 4
        addi    $a1, $a0, 20
check_scatter:
        beq     $a0, $a1, scatter_sub
        lw      $s3, 0($a0)
        bne     $s3, 0, compare
        addi    $a0, $a0, 4
        j       check_scatter
scatter_sub:
        addi      $s4, $s4, -5

compare:
# check whether gain more point or not
        slt     $s3, $t0, $s4
        beqz    $s3, update
        move    $t0, $s4 
# update
update:
	beqz    $s2, update_direction
	j	update_block
update_direction:
	li	$s2, 1
	j	restore
update_block:
	li	$s2, 0
restore:
# restore data
# restore board
	la	$a1, board
	la	$a0, hooman_board
        addi    $s3, $a0, 48
restore_board:
	beq	$a0, $s3, end_restore_board
	lw	$s4, 0($a0)
	sw	$s4, 0($a1)
	addi	$a0, $a0, 4
	addi	$a1, $a1, 4
	j	restore_board
end_restore_board:
# restore mandarins status
	la	$a0, mandarins
	la	$a1, mh_reserve
	lw	$s5, 0($a1)
	sw	$s5, 0($a0)
	lw	$s5, 4($a1)
	sw	$s5, 4($a0)
# restore player
	la	$a1, player1
	la	$a0, hooman_reserve
        addi    $s3, $a0, 12
restore_point:
	beq	$a0, $s3, end_restore_point
	lw	$s4, 0($a0)
	sw	$s4, 0($a1)
	addi	$a0, $a0, 4
	addi	$a1, $a1, 4
	j	restore_point
end_restore_point:
        la      $a0, board
        beq     $s2, 1, next
	j	choose_direction
end_choose_direction:
        sub     $t0, $t0, $t1
        move    $v0, $t0
# restore register
        lw      $t8, 0($sp)
        lw      $t9, 4($sp)  
        lw      $s2, 8($sp)  
        lw      $s3, 12($sp)  
        lw      $s4, 16($sp)  
        lw      $s5, 20($sp)
        lw      $a0, 24($sp) 
        lw      $a1, 28($sp)
        lw      $t0, 32($sp)
        lw      $t1, 36($sp) 
        addi    $sp, $sp, 40
.end_macro


# -------------------------------------------------------- #
# FUNCTION: MOVE A SOLDIERS BY PLAYER 1'S CHOICE           #
# INPUT: $a0, $a1                                          #
# %block_num = the block bot chosen (1 - 5)   		   #
# $direction = 0 for left, 1 for right                     #
# OUTPUT: $v0 = the next block of last accessed block      #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro prep1move(%block_num, %direction)
# reserve registers
        subi    $sp, $sp, 24
        sw      $s0, 0($sp)
        sw      $a0, 4($sp)  
        sw      $a1, 8($sp)  
        sw      $t1, 12($sp)  
        sw      $t2, 16($sp)  
        sw      $s1, 20($sp)
# Getting data
        la      $s0, board
        addi    $a0, %block_num, 0
        addi    $a1, %direction, 0
        addi    $t1, $0, 6
move_loop_cond:
        beqz    $a0, move_loop_end
        beq     $a0, $t1, move_loop_end
        sll     $t2, $a0, 2
        add     $s1, $s0, $t2
        lw      $t2, 0($s1)
        beqz    $t2, move_loop_end
        beqz    $a1, move_left

move_right:
        premcw($a0)
        move    $a0, $v0
        j       move_loop_cond

move_left:
        premccw($a0)
        move    $a0, $v0
        j       move_loop_cond

move_loop_end:

# return value
        move    $v0, $a0
# restore registers
        lw      $s0, 0($sp)
        lw      $a0, 4($sp)  
        lw      $a1, 8($sp)  
        lw      $t1, 12($sp)  
        lw      $t2, 16($sp)  
        lw      $s1, 20($sp)
        addi    $sp, $sp, 24
.end_macro

# -------------------------------------------------------- #
# FUNCTION: MOVE A SOLDIERS CLOCKWISE                      #
# INPUT: $a0                                               #
# %block_num = the block chosen (1 - 5)                    #
# OUTPUT: $v0 = the next block of last accessed block      #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro premcw(%block_num)
# reserve registers
        subi    $sp, $sp, 44
        sw      $s0, 0($sp)
        sw      $a0, 4($sp)  
        sw      $t1, 8($sp)  
        sw      $s1, 12($sp)  
        sw      $t2, 16($sp)  
        sw      $t3, 20($sp)  
        sw      $a1, 24($sp)  
        sw      $a2, 28($sp) 
        sw      $t4, 32($sp)
        sw      $s2, 36($sp)
        sw      $t5, 40($sp) 

# Getting data
        la      $s0, board
        addi    $a0, %block_num, 0
        sll     $t1, $a0, 2
        add     $s1, $s0, $t1
        lw      $t2, 0($s1)
        sw	$zero, 0($s1)
        addi    $t3, $0, 12
        addi    $a1, $0, 1
        addi    $t4, $0, 6
movecw:
        beq     $t2, 0, end_movecw
        addi    $a0, $a0, 1
        div     $a0, $t3
        mfhi    $a0
        sll     $t1, $a0, 2
        add     $s1, $s0, $t1
        lw      $a2, 0($s1)  
        beqz    $a0, if_first_mandarin
        beq     $a0, $t4,if_second_mandarin

if_normal:
        j       end_if
if_first_mandarin:
        la      $s2, mandarins
        lw      $t5, 0($s2)
        bnez    $t5, if_normal
        j       end_if

if_second_mandarin:
        la      $s2, mandarins
        lw      $t5, 4($s2)
        bnez    $t5, if_normal
        j       end_if

end_if:
        addi    $a2, $a2, 1
        sw      $a2, 0($s1)
        addi    $t2, $t2, -1
        j       movecw
    
end_movecw:
# return the output
        addi    $a0, $a0, 1
        div     $a0, $t3
        mfhi    $a0
        move    $v0, $a0
# restore registers
        lw      $s0, 0($sp)
        lw      $a0, 4($sp)  
        lw      $t1, 8($sp)  
        lw      $s1, 12($sp)  
        lw      $t2, 16($sp)  
        lw      $t3, 20($sp)  
        lw      $a1, 24($sp)  
        lw      $a2, 28($sp) 
        lw      $t4, 32($sp)
        lw      $s2, 36($sp)
        lw      $t5, 40($sp)
        addi    $sp, $sp, 44
.end_macro


# -------------------------------------------------------- #
# FUNCTION: MOVE A SOLDIERS COUNTER CLOCKWISE              #
# INPUT: $a0                                               #
# %block_num = the block chosen (1 - 5)                   #
# OUTPUT: $v0 = the next block of last accessed block      #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro premccw(%block_num)
# reserve registers
        subi    $sp, $sp, 48
        sw      $s0, 0($sp)
        sw      $a0, 4($sp)  
        sw      $t1, 8($sp)  
        sw      $s1, 12($sp)  
        sw      $t2, 16($sp)  
        sw      $t3, 20($sp)  
        sw      $a1, 24($sp)  
        sw      $a2, 28($sp) 
        sw      $t0, 32($sp)
        sw      $t4, 36($sp)
        sw      $s2, 40($sp)
        sw      $t5, 44($sp) 

# Getting data & remove the chosen block
        la      $s0, board
        addi    $a0, %block_num, 0
        sll     $t1, $a0, 2
        add     $s1, $s0, $t1
        lw      $t2, 0($s1)
        sw	$zero, 0($s1)
        addi    $t3, $0, 12
        addi    $t4, $0, 6
        addi    $a1, $0, 1
        sub     $t0, $t3, $a0
moveccw:
        beq     $t2, 0, end_moveccw        
        div     $t0, $t3
        mfhi    $t0
        addi    $t0, $t0, 1
        sub     $a0, $t3, $t0
        sll     $t1, $a0, 2
        add     $s1, $s0, $t1
        lw      $a2, 0($s1)  
        beqz    $a0, if_first_mandarin
        beq     $a0, $t4, if_second_mandarin

if_normal:
        j       end_if
if_first_mandarin:
        la      $s2, mandarins
        lw      $t5, 0($s2)
        bnez    $t5, if_normal
        j       end_if

if_second_mandarin:
        la      $s2, mandarins
        lw      $t5, 4($s2)
        bnez    $t5, if_normal
        j       end_if

end_if:
        addi    $a2, $a2, 1
        sw      $a2, 0($s1)
        addi    $t2, $t2, -1
        j       moveccw
    
end_moveccw:
# return the output
        div     $t0, $t3
        mfhi    $t0
        addi    $t0, $t0, 1
        sub     $a0, $t3, $t0
        move    $v0, $a0
# restore registers
        lw      $s0, 0($sp)
        lw      $a0, 4($sp)  
        lw      $t1, 8($sp)  
        lw      $s1, 12($sp)  
        lw      $t2, 16($sp)  
        lw      $t3, 20($sp)  
        lw      $a1, 24($sp)  
        lw      $a2, 28($sp) 
        lw      $t0, 32($sp)
        lw      $t4, 36($sp)
        lw      $s2, 40($sp)
        lw      $t5, 44($sp)
        addi    $sp, $sp, 48
.end_macro


# -------------------------------------------------------- #
# FUNCTION: BOT CAPTURE A BLOCK                       	   #
# INPUT: $a0, $a1                                          #
# %block_num = the block bot chosen (1 - 5) 		   #
# $direction = 0 for left, 1 for right                     #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro prep1Capture(%block_num, %direction)
# reserve registers
        subi    $sp, $sp, 12
        sw      $s0, 0($sp)
        sw      $a0, 4($sp)
        sw      $a1, 8($sp)

# getting data
        la      $s0, board
        addi    $a0, %block_num, 0
        addi    $a1, %direction, 0
        beqz    $a1, capture_left

capture_right:
        precpcw($a0)
        j       capture_end

capture_left:
        precpccw($a0)

capture_end:

# restore register
        lw      $s0, 0($sp)
        lw      $a0, 4($sp)
        lw      $a1, 8($sp)
        addi    $sp, $sp, 12
.end_macro


# -------------------------------------------------------- #
# FUNCTION: CAPTURE BLOCKS CLOCKWISE                       #
# INPUT: $a0, $a1                                          #
# %block_num = the block bot chosen (1 - 5)    		   #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro precpcw(%block_num)
# reserve registers
        subi    $sp, $sp, 48
        sw      $s0, 0($sp)
        sw      $s1, 4($sp)
        sw      $s2, 8($sp)
        sw      $s3, 12($sp)
        sw      $t0, 16($sp)
        sw      $t1, 20($sp)
        sw      $t2, 24($sp)
        sw      $t3, 28($sp)
        sw      $t4, 32($sp)
        sw      $a0, 36($sp)
        sw      $a1, 40($sp)
        sw      $a2, 44($sp)

# getting data
        la      $s0, board
        addi    $a0, %block_num, 0
        add     $a2, $0, 1
        addi    $t0, $0, 12
        addi    $t1, $0, 6
        addi    $a1, $0, 1
        la      $s2, player1

capture_loop_cond:
        sll     $t2, $a0, 2
        add     $s1, $s0, $t2
        lw      $t2, 0($s1)
        bnez    $t2, capture_loop_end
        addi    $a0, $a0, 1
        div     $a0, $t0
        mfhi    $a0
        sll     $t2, $a0, 2
        add     $s1, $s0, $t2
        lw      $t2, 0($s1)
        beqz    $t2, capture_loop_end
        beqz    $a0, capture_first_mandarins
        beq     $a0, $t1, capture_second_mandarins

capture_soldiers:
        lw      $t3, 0($s2)        
        add     $t3, $t3, $t2
        sw      $t3, 0($s2)
        sw	$0, 0($s1)
        addi    $a0, $a0, 1
        div     $a0, $t0
        mfhi    $a0
        j       capture_loop_cond
        
capture_first_mandarins: 
        la      $s3, mandarins
        lw      $t4, 0($s3)
        bnez    $t4, capture_soldiers
        slti    $t4, $t2, 10
        beq     $t4, $a1, capture_loop_end
        lw      $t3, 4($s2)
        addi    $t3, $t3, 1
        sw      $t3, 4($s2)
        addi    $t4, $a2, 1
        sw      $t4, 0($s3)
        addi    $t2, $t2, -5
        j       capture_soldiers        


capture_second_mandarins:
        la      $s3, mandarins
        lw      $t4, 4($s3)
        bnez    $t4, capture_soldiers
        slti    $t4, $t2, 10
        beq     $t4, $a1, capture_loop_end
        lw      $t3, 4($s2)
        addi    $t3, $t3, 1
        sw      $t3, 4($s2)
        addi    $t4, $a2, 1
        sw      $t4, 4($s3)
        addi    $t2, $t2, -5
        j       capture_soldiers   

capture_loop_end:

# restore register
        lw      $s0, 0($sp)
        lw      $s1, 4($sp)
        lw      $s2, 8($sp)
        lw      $s3, 12($sp)
        lw      $t0, 16($sp)
        lw      $t1, 20($sp)
        lw      $t2, 24($sp)
        lw      $t3, 28($sp)
        lw      $t4, 32($sp)
        lw      $a0, 36($sp)
        lw      $a1, 40($sp)
        lw      $a2, 44($sp)
        addi    $sp, $sp, 48
.end_macro


# -------------------------------------------------------- #
# FUNCTION: CAPTURE BLOCKS COUNTER CLOCKWISE               #
# INPUT: $a0, $a1                                          #
# %block_num = the block bot chosen (1 - 5)                #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro precpccw(%block_num)
# reserve registers
        subi    $sp, $sp, 52
        sw      $s0, 0($sp)
        sw      $s1, 4($sp)
        sw      $s2, 8($sp)
        sw      $s3, 12($sp)
        sw      $t0, 16($sp)
        sw      $t1, 20($sp)
        sw      $t2, 24($sp)
        sw      $t3, 28($sp)
        sw      $t4, 32($sp)
        sw      $a0, 36($sp)
        sw      $a1, 40($sp)
        sw      $a2, 44($sp)
        sw      $t5, 48($sp)

# getting data
        la      $s0, board
        addi    $a0, %block_num, 0
        addi    $a2, $0, 1
        addi    $t0, $0, 12
        addi    $t1, $0, 6
        addi    $a1, $0, 1
        sub     $t5, $t0, $a0
        la      $s2, player1
capture_loop_cond:
        sll     $t2, $a0, 2
        add     $s1, $s0, $t2
        lw      $t2, 0($s1)
        bnez    $t2, capture_loop_end
        div     $t5, $t0
        mfhi    $t5
        addi    $t5, $t5, 1
        sub     $a0, $t0, $t5
        sll     $t2, $a0, 2
        add     $s1, $s0, $t2
        lw      $t2, 0($s1)
        beqz    $t2, capture_loop_end
        beqz    $a0, capture_first_mandarins
        beq     $a0, $t1, capture_second_mandarins
capture_soldiers:
        lw      $t3, 0($s2)        
        add     $t3, $t3, $t2
        sw      $t3, 0($s2)
        sw	$0, 0($s1)
        div     $t5, $t0
        mfhi    $t5
        addi    $t5, $t5, 1
        sub     $a0, $t0, $t5
        j       capture_loop_cond
        
capture_first_mandarins: 
        la      $s3, mandarins
        lw      $t4, 0($s3)
        bnez    $t4, capture_soldiers
        slti    $t4, $t2, 10
        beq     $t4, $a1, capture_loop_end
        lw      $t3, 4($s2)
        addi    $t3, $t3, 1
        sw      $t3, 4($s2)
        addi    $t4, $a2, 1
        sw      $t4, 0($s3)
        addi    $t2, $t2, -5
        j       capture_soldiers        

capture_second_mandarins:
        la      $s3, mandarins
        lw      $t4, 4($s3)
        bnez    $t4, capture_soldiers
        slti    $t4, $t2, 10
        beq     $t4, $a1, capture_loop_end

        lw      $t3, 4($s2)
        addi    $t3, $t3, 1
        sw      $t3, 4($s2)
        addi    $t4, $a2, 1
        sw      $t4, 4($s3)
        addi    $t2, $t2, -5
        j       capture_soldiers   

capture_loop_end:

# restore register
        lw      $s0, 0($sp)
        lw      $s1, 4($sp)
        lw      $s2, 8($sp)
        lw      $s3, 12($sp)
        lw      $t0, 16($sp)
        lw      $t1, 20($sp)
        lw      $t2, 24($sp)
        lw      $t3, 28($sp)
        lw      $t4, 32($sp)
        lw      $a0, 36($sp)
        lw      $a1, 40($sp)
        lw      $a2, 44($sp)
        lw      $t5, 48($sp)
        addi    $sp, $sp, 52
.end_macro


# -------------------------------------------------------- #
# FUNCTION: PLAYER 1 SCATTERING for prediction      	   #
# $v0 = 0 if not scattering, 1 if scattering		   #
# -------------------------------------------------------- #
.macro prep1_scattering
#reserve registers
	subi    $sp, $sp, 28
        sw      $s0, 0($sp)
        sw      $s1, 4($sp)  
        sw      $s2, 8($sp)  
        sw      $t0, 12($sp)  
        sw      $t1, 16($sp)  
        sw      $t2, 20($sp)  
        sw      $t3, 24($sp)  
       
#getting data
	la 	$s0, board
	la	$s1, player1
	la	$s2, player2
	li	$t0, 1
	li	$t1, 20
        li      $v0, 0
	
check_scatter:
	ble	$t1, $zero, mes
	add	$t2, $t1, $s0
	lw 	$t3, 0($t2)
	bnez	$t3, end
	subi	$t1, $t1, 4
	j 	check_scatter
mes:
        li      $v0, 1
	lw	$t1, 0($s1)
	li	$t2, 5
	blt	$t1, $t2, update_soldiers
	subi	$t1, $t1, 5
	sw	$t1, 0($s1)
	li	$t1, 5
	j	scatter
	
update_soldiers:	
	lw	$t3, 0($s2)
	subi	$t3, $t3, 5
	sw	$t3, 0($s2)
	lw	$t3, 8($s1)
	addi	$t3, $t3, 5
	sw	$t3, 8($s1)	
	li	$t1, 5

scatter:
	ble	$t1, $zero, end
	sll	$t3, $t1, 2
	add	$t2, $t3, $s0
	sw 	$t0, 0($t2)
	subi	$t1, $t1, 1
	j 	scatter
end:
#restore registers
	lw      $s0, 0($sp)
        lw      $s1, 4($sp)  
        lw      $s2, 8($sp)  
        lw      $t0, 12($sp)  
        lw      $t1, 16($sp)  
        lw      $t2, 20($sp)  
        lw      $t3, 24($sp)  
        addi    $sp, $sp, 28
.end_macro


# -------------------------------------------------------- #
# FUNCTION: BOT SCATTERING                                 #
# $v0 = 0 if not scattering, 1 if scattering		   #
# -------------------------------------------------------- #

.macro bot_scattering
#reserve registers
	subi    $sp, $sp, 32
        sw      $s0, 0($sp)
        sw      $s1, 4($sp)  
        sw      $s2, 8($sp)  
        sw      $t0, 12($sp)  
        sw      $t1, 16($sp)  
        sw      $t2, 20($sp)  
        sw      $t3, 24($sp)  
        sw      $t4, 28($sp)
       
#getting data
	la 	$s0, board
	la	$s1, player1
	la	$s2, player2
	li	$t0, 1
	li	$t1, 24
	li 	$t4, 44
        li      $v0, 0
	
check_scatter:
	ble	$t4, $t1, mes
	add	$t2, $t4, $s0
	lw 	$t3, 0($t2)
	bnez	$t3, end
	subi	$t4, $t4, 4
	j 	check_scatter
mes:
        li      $v0, 1
	lw	$t1, 0($s2)
	li	$t2, 5
	blt	$t1, $t2, update_soldiers
	subi	$t1, $t1, 5
	sw	$t1, 0($s2)
	li	$t0, 1
	li	$t1, 6
	li	$t4, 11
	j	scatter
	
update_soldiers:	
	lw	$t3, 0($s1)
	subi	$t3, $t3, 5
	sw	$t3, 0($s1)
	lw	$t3, 8($s2)
	addi	$t3, $t3, 5
	sw	$t3, 8($s2)
	
	li	$t0, 1
	li	$t1, 6
	li	$t4, 11

scatter:
	ble	$t4, $t1, end
	sll	$t3, $t4, 2
	add	$t2, $t3, $s0
	sw 	$t0, 0($t2)	
	subi	$t4, $t4, 1
	j 	scatter

end:
#restore registers
	lw      $s0, 0($sp)
        lw      $s1, 4($sp)  
        lw      $s2, 8($sp)  
        lw      $t0, 12($sp)  
        lw      $t1, 16($sp)  
        lw      $t2, 20($sp)  
        lw      $t3, 24($sp)  
        lw      $t4, 28($sp)
        addi    $sp, $sp, 32
.end_macro
