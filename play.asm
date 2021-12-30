# -------------------------------------------------------- #
#    ------------------ DATA SEGMENT ------------------    #
# -------------------------------------------------------- #
.data
scatter_success: 	.asciiz "Scatter successfully\n"

# -------------------------------------------------------- #
#    ------------------ CODE SEGMENT ------------------    #
# -------------------------------------------------------- #

# -------------------------------------------------------- #
# FUNCTION: PLAY GAME IN PvP MODE                          #
# -------------------------------------------------------- #
.macro play_pvp
# reserve registers
        subi 	$sp, $sp, 8
        sw	$v0, 0($sp)
        sw      $v1, 4($sp)

        addi 	$v0, $0, 0
        draw_init($0)

loop_play_pvp:
        beqz 	$v0, player1_turn
        j 	show_result

player1_turn:
        player1Turn
        bnez	$v0, show_result

player2_turn:
        player2Turn
        j 	loop_play_pvp

show_result:
        showResult($v1)
# restore registers
        lw	$v0, 0($sp)
        lw      $v1, 4($sp)
        addi	$sp, $sp, 8
.end_macro

# -------------------------------------------------------- #
# FUNCTION: PLAY VS FRED IN PvE MODE                       #
# -------------------------------------------------------- #
.macro play_vs_fred
#reserve registers
        subi 	$sp, $sp, 8
        sw	$v0, 0($sp)
        sw	$v1, 4($sp)
        li	$v0, 1
        draw_init($v0)
        addi 	$v0, $0, 0
loop_play_vs_fred:
        beqz 	$v0, player1_turn
        j 	show_result

player1_turn:
        player1Turn_vs_fred
        bnez	$v0, show_result

b_turn:
        fred_turn
        j 	loop_play_vs_fred

show_result:
        showResult($v1)

end_show_res:
	
# restore registers
        lw	$v0, 0($sp)
        lw	$v1, 4($sp)
        addi	$sp, $sp, 8
.end_macro


# -------------------------------------------------------- #
# FUNCTION: PLAY VS EVIE IN PvE MODE                       #
# -------------------------------------------------------- #
.macro play_vs_evie
#reserve registers
        subi 	$sp, $sp, 8
        sw	$v0, 0($sp)
        sw	$v1, 4($sp)

        li		$v0, 2
        draw_init($v0)
        addi 	$v0, $0, 0
loop_play_vs_evie:
        beqz 	$v0, player1_turn
        j 		show_result

player1_turn:
        player1Turn_vs_evie
        bnez	$v0, show_result

b_turn:
        evie_turn
        j 		loop_play_vs_evie

show_result:
        showResult($v1)

end_show_res:

# restore registers
        lw	$v0, 0($sp)
        lw	$v1, 4($sp)
        addi	$sp, $sp, 8
.end_macro

# -------------------------------------------------------- #
# FUNCTION: READY THE GAME BEFORE                          #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro get_ready
# reserve registers
        subi    $sp, $sp, 16
        sw      $s0, 0($sp)
        sw      $s1, 4($sp)
        sw      $s2, 8($sp)
        sw      $s3, 12($sp)
# read board
        li	$s0, 0
        li	$s1, 12
        la	$s2, board
        li	$s3, 5
ready_loop:
        beq	$s0, $s1, ready_end
        sw	$s3, 0($s2)
        addi	$s0, $s0, 1
        addi	$s2, $s2, 4
        j	ready_loop
ready_end:
# ready point
        la	$s0, player1
        sw	$0, 0($s0)
        sw	$0, 4($s0)
        sw	$0, 8($s0)
        la	$s0, player2
        sw	$0, 0($s0)
        sw	$0, 4($s0)
        sw	$0, 8($s0)
        la	$s0, mandarins
        sw	$0, 0($s0)
        sw	$0, 4($s0)
# restore register
        lw      $s0, 0($sp)
        lw      $s1, 4($sp)
        lw      $s2, 8($sp)
        lw      $s3, 12($sp)
        addi    $sp, $sp, 16
.end_macro

# -------------------------------------------------------- #
# FUNCTION: PLAYER1 TURN TO MOVE                           #
# OUTPUT: STATUS OF GAME                                   #
# $v0 : 0 - CONT, 1 - ENDED                                #
# $v1 : 1 - NORMAL ENDING                                  #
#     : 2 - PLAYER2 QUIT                                   #
#     : 3 - PLAYER1 QUIT                                   #  
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro player1Turn
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
        beq     $v0, -1, player1_quit
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
        addi    $v1, $0, 1
        j       end_player1_turn

player1_quit:
        addi    $v0, $0, 1
        addi    $v1, $0, 3
        j       end_player1_turn

game_continue:
# check if scattering
        p1_scattering
        p2_scattering
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
# FUNCTION: PLAYER2 TURN TO MOVE                           #
# OUTPUT: STATUS OF GAME                                   #
# $v0 : 0 - CONT, 1 - ENDED                                #
# $v1 : 1 - NORMAL ENDING                                  #
#     : 2 - PLAYER2 QUIT                                   #
#     : 3 - PLAYER1 QUIT                                   #  
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro player2Turn
# reserve registers
        subi    $sp, $sp, 36
        sw      $a0, 0($sp)
        sw      $a1, 4($sp)
        sw      $a2, 8($sp)
        sw      $t0, 12($sp)
        sw      $t1, 16($sp)
        sw      $t2, 20($sp)
        sw      $s0, 24($sp)
        sw      $s1, 28($sp)
        sw      $a3, 32($sp)

# getting data
        addi    $a2, $0, 2
        addi    $a3, $0, 1
# popup selection
        draw_lower_block_number
        highlight_word($a2, $a3)
        player2fig
        beq     $v0, -1, player2_quit
        move    $a0, $v1
        move    $a1, $v0
        remove_lower_block_number

# time to move
        p2move($a0, $a1)
        move    $a0, $v0

# check if capture
        p2Capture($a0, $a1)

# check end game
        highlight_word($a2, $0)
        check_end_game
        beqz    $v0, game_continue # Game status: continue

game_ended:
        addi    $v0, $0, 1
        addi    $v1, $0, 1
        j       end_player2_turn

player2_quit:
        addi    $v0, $0, 1
        addi    $v1, $0, 2
        j       end_player2_turn


game_continue:
# check if scattering
        p1_scattering
        p2_scattering
        
end_player2_turn:

# restore registers
        lw      $a0, 0($sp)
        lw      $a1, 4($sp)
        lw      $a2, 8($sp)
        lw      $t0, 12($sp)
        lw      $t1, 16($sp)
        lw      $t2, 20($sp)
        lw      $s0, 24($sp)
        lw      $s1, 28($sp)
        lw      $a3, 32($sp)
        addi    $sp, $sp, 36
.end_macro

# -------------------------------------------------------- #
# FUNCTION: MOVE A SOLDIER CLOCKWISE                       #
# INPUT: $a0                                               #
# %block_num = the block player chosen (1 - 5 & 6 - 10)    #
# OUTPUT: $v0 = the next block of last accessed block      #
# Reserve: all register used                               #
# -------------------------------------------------------- #

.macro mcw(%block_num)
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
        highlight($a0, $0) 
        delay(100)
        highlight($a0, $a1)
        delay(100)
        highlight($a0, $0) 
        delay(100)
        highlight($a0, $a1)
        delay(100)
        highlight($a0, $0) 
        remove_block($a0)
        update_point($a0)
        delay(100)
        highlight($a0, $a1)

movecw:
        beq     $t2, 0, end_movecw
        addi    $a0, $a0, 1
        div     $a0, $t3
        mfhi    $a0
        sll     $t1, $a0, 2
        add     $s1, $s0, $t1
        lw      $a2, 0($s1)  
        highlight($a0, $0) 
        beqz    $a0, if_first_mandarin
        beq     $a0, $t4,if_second_mandarin

if_normal:
        draw_soldiers($a0, $a1, $a2, $a1)
        j       end_if
if_first_mandarin:
        la      $s2, mandarins
        lw      $t5, 0($s2)
        bnez    $t5, if_normal
        addi    $a2, $a2, -5
        draw_soldiers($a0, $a1, $a2, $a1)
        addi    $a2, $a2, 5
        j       end_if

if_second_mandarin:
        la      $s2, mandarins
        lw      $t5, 4($s2)
        bnez    $t5, if_normal
        addi    $a2, $a2, -5
        draw_soldiers($a0, $a1, $a2, $a1)
        addi    $a2, $a2, 5
        j       end_if

end_if:
        addi    $a2, $a2, 1
        sw      $a2, 0($s1)
        addi    $t2, $t2, -1
        update_point($a0)
        highlight($a0, $a1)
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
# FUNCTION: MOVE A SOLDIER COUNTER CLOCKWISE               #
# INPUT: $a0                                               #
# %block_num = the block player chosen (1 - 5 & 6 - 10)    #
# OUTPUT: $v0 = the next block of last accessed block      #
# Reserve: all register used                               #
# -------------------------------------------------------- #

.macro mccw(%block_num)
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
        highlight($a0, $0) 
        delay(100)
        highlight($a0, $a1)
        delay(100)
        highlight($a0, $0) 
        delay(100)
        highlight($a0, $a1)
        delay(100)
        highlight($a0, $0) 
        remove_block($a0)
        update_point($a0)
        delay(100)
        highlight($a0, $a1)
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
        highlight($a0, $0)
        beqz    $a0, if_first_mandarin
        beq     $a0, $t4, if_second_mandarin

if_normal:
        draw_soldiers($a0, $a1, $a2, $a1)
        j       end_if
if_first_mandarin:
        la      $s2, mandarins
        lw      $t5, 0($s2)
        bnez    $t5, if_normal
        addi    $a2, $a2, -5
        draw_soldiers($a0, $a1, $a2, $a1)
        addi    $a2, $a2, 5
        j       end_if

if_second_mandarin:
        la      $s2, mandarins
        lw      $t5, 4($s2)
        bnez    $t5, if_normal
        addi    $a2, $a2, -5
        draw_soldiers($a0, $a1, $a2, $a1)
        addi    $a2, $a2, 5
        j       end_if

end_if:
        addi    $a2, $a2, 1
        sw      $a2, 0($s1)
        addi    $t2, $t2, -1
        update_point($a0)
        highlight($a0, $a1)
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
# FUNCTION: MOVE A SOLDIER BY PLAYER2'S CHOICE             #
# INPUT: $a0, $a1                                          #
# %block_num = the block player chosen (1 - 5 & 6 - 10)    #
# $direction = 0 for left, 1 for right                     #
# OUTPUT: $v0 = the next block of last accessed block      #
# Reserve: all register used                               #
# -------------------------------------------------------- #

.macro p2move(%block_num, %direction)
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
        mccw($a0)
        move    $a0, $v0
        j       move_loop_cond

move_left:
        mcw($a0)
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
# FUNCTION: MOVE A soldierS BY PLAYER1'S CHOICE            #
# INPUT: $a0, $a1                                          #
# %block_num = the block player chosen (1 - 5 & 6 - 10)    #
# $direction = 0 for left, 1 for right                     #
# OUTPUT: $v0 = the next block of last accessed block      #
# Reserve: all register used                               #
# -------------------------------------------------------- #

.macro p1move(%block_num, %direction)
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
        mcw($a0)
        move    $a0, $v0
        j       move_loop_cond

move_left:
        mccw($a0)
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
# FUNCTION: CAPTURE BLOCKS CLOCKWISE                       #
# INPUT: $a0, $a1                                          #
# %block_num = the block player chosen (1 - 5 & 6 - 10)    #
# %player = Player 1/2  (0-1)                              #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro cpcw(%block_num, %player)
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
        add     $a2, $0, %player
        addi    $t0, $0, 12
        addi    $t1, $0, 6
        addi    $a1, $0, 1
        beqz    $a2, player1_cp

player2_cp:
        la      $s2, player2
        j       capture_loop_cond
player1_cp:
        la      $s2, player1

capture_loop_cond:
        sll     $t2, $a0, 2
        add     $s1, $s0, $t2
        lw      $t2, 0($s1)
        bnez    $t2, capture_loop_end
        highlight($a0, $0)
        delay(300)
        highlight($a0, $a1)
        addi    $a0, $a0, 1
        div     $a0, $t0
        mfhi    $a0
        sll     $t2, $a0, 2
        add     $s1, $s0, $t2
        lw      $t2, 0($s1)
        beqz    $t2, capture_loop_speacial_end
        beqz    $a0, capture_first_mandarins
        beq     $a0, $t1, capture_second_mandarins

capture_soldiers:
        lw      $t3, 0($s2)        
        highlight($a0, $0) 
        delay(100)
        highlight($a0, $a1)
        delay(100)
        highlight($a0, $0) 
        delay(100)
        highlight($a0, $a1)
        delay(100)
        highlight($a0, $0) 
        remove_block($a0)
        delay(100)
        highlight($a0, $a1)
        add_soldiers($a2, $t3, $t2)
        add     $t3, $t3, $t2
        sw      $t3, 0($s2)
        sw	$0, 0($s1)
        update_point($a0)
        addi    $a0, $a0, 1
        div     $a0, $t0
        mfhi    $a0
        update_player_point
        j       capture_loop_cond
        
capture_first_mandarins: 
        la      $s3, mandarins
        lw      $t4, 0($s3)
        bnez    $t4, capture_soldiers
        slti    $t4, $t2, 10
        beq     $t4, $a1, capture_loop_speacial_end
        highlight($a0, $0) 
        delay(100)
        highlight($a0, $a1)
        delay(100)
        highlight($a0, $0) 
        delay(100)
        highlight($a0, $a1)
        lw      $t3, 4($s2)
        add_mandarin($a2, $t3)
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
        beq     $t4, $a1, capture_loop_speacial_end
        highlight($a0, $0) 
        delay(100)
        highlight($a0, $a1)
        delay(100)
        highlight($a0, $0) 
        delay(100)
        highlight($a0, $a1)
        lw      $t3, 4($s2)
        add_mandarin($a2, $t3)
        addi    $t3, $t3, 1
        sw      $t3, 4($s2)
        addi    $t4, $a2, 1
        sw      $t4, 4($s3)
        addi    $t2, $t2, -5
        j       capture_soldiers   

capture_loop_speacial_end:
        highlight($a0, $0)
        delay(300)
        highlight($a0, $a1)

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
# %block_num = the block player chosen (1 - 5 & 6 - 10)    #
# %player = Player 1/2  (0-1)                              #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro cpccw(%block_num, %player)
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
        add     $a2, $0, %player
        addi    $t0, $0, 12
        addi    $t1, $0, 6
        addi    $a1, $0, 1
        sub     $t5, $t0, $a0
        beqz    $a2, player1_cp

player2_cp:
        la      $s2, player2
        j       capture_loop_cond
player1_cp:
        la      $s2, player1

capture_loop_cond:
        sll     $t2, $a0, 2
        add     $s1, $s0, $t2
        lw      $t2, 0($s1)
        bnez    $t2, capture_loop_end
        highlight($a0, $0)
        delay(300)
        highlight($a0, $a1)
        div     $t5, $t0
        mfhi    $t5
        addi    $t5, $t5, 1
        sub     $a0, $t0, $t5
        sll     $t2, $a0, 2
        add     $s1, $s0, $t2
        lw      $t2, 0($s1)
        beqz    $t2, capture_loop_speacial_end
        beqz    $a0, capture_first_mandarins
        beq     $a0, $t1, capture_second_mandarins

capture_soldiers:
        lw      $t3, 0($s2)        
        highlight($a0, $0) 
        delay(100)
        highlight($a0, $a1)
        delay(100)
        highlight($a0, $0) 
        delay(100)
        highlight($a0, $a1)
        delay(100)
        highlight($a0, $0) 
        remove_block($a0)
        delay(100)
        highlight($a0, $a1)
        add_soldiers($a2, $t3, $t2)
        add     $t3, $t3, $t2
        sw      $t3, 0($s2)
        sw	$0, 0($s1)
        update_point($a0)
        div     $t5, $t0
        mfhi    $t5
        addi    $t5, $t5, 1
        sub     $a0, $t0, $t5
        update_player_point
        j       capture_loop_cond
        
capture_first_mandarins: 
        la      $s3, mandarins
        lw      $t4, 0($s3)
        bnez    $t4, capture_soldiers
        slti    $t4, $t2, 10
        beq     $t4, $a1, capture_loop_speacial_end
        highlight($a0, $0) 
        delay(100)
        highlight($a0, $a1)
        delay(100)
        highlight($a0, $0) 
        delay(100)
        highlight($a0, $a1)
        lw      $t3, 4($s2)
        add_mandarin($a2, $t3)
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
        beq     $t4, $a1, capture_loop_speacial_end
        highlight($a0, $0) 
        delay(100)
        highlight($a0, $a1)
        delay(100)
        highlight($a0, $0) 
        delay(100)
        highlight($a0, $a1)
        lw      $t3, 4($s2)
        add_mandarin($a2, $t3)
        addi    $t3, $t3, 1
        sw      $t3, 4($s2)
        addi    $t4, $a2, 1
        sw      $t4, 4($s3)
        addi    $t2, $t2, -5
        j       capture_soldiers   

capture_loop_speacial_end:
        highlight($a0, $0)
        delay(300)
        highlight($a0, $a1)

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
# FUNCTION: PLAYER1 CAPTURE A BLOCK                        #
# INPUT: $a0, $a1                                          #
# %block_num = the block player chosen (1 - 5 & 6 - 10)    #
# $direction = 0 for left, 1 for right                     #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro p1Capture(%block_num, %direction)
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
        cpcw($a0, $0)
        j       capture_end

capture_left:
        cpccw($a0, $0)

capture_end:

# restore register
        sw      $s0, 0($sp)
        sw      $a0, 4($sp)
        sw      $a1, 8($sp)
        addi    $sp, $sp, 12
.end_macro

# -------------------------------------------------------- #
# FUNCTION: PLAYER1 CAPTURE A BLOCK                        #
# INPUT: $a0, $a1                                          #
# %block_num = the block player chosen (1 - 5 & 6 - 10)    #
# $direction = 0 for left, 1 for right                     #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro p2Capture(%block_num, %direction)
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
        cpccw($a0, $a2)
        j       capture_end

capture_left:
        cpcw($a0, $a2)

capture_end:

# restore register
        sw      $s0, 0($sp)
        sw      $a0, 4($sp)
        sw      $a1, 8($sp)
        sw      $a2, 12($sp)
        addi    $sp, $sp, 16
.end_macro


# -------------------------------------------------------- #
# FUNCTION: ENDGAMECHECKER                                 #
# OUTPUT: $v0 						   #
# 0 - THE GAME IS CONTINUE                                 #
# 1 - THE GAME IS OVER					   #
# -------------------------------------------------------- #
.macro check_end_game
# reserve registers
        subi    $sp, $sp, 32 
        sw      $s0, 0($sp)
        sw      $s1, 4($sp)  
        sw      $s2, 8($sp)  
        sw      $t1, 12($sp)  
        sw      $t2, 16($sp)  
        sw      $t3, 20($sp)
		sw		$t4, 24($sp)
		sw		$t5, 28($sp)

# Getting data
    	la      $s0, board
   	lw		$t1, 0($s0)
	lw		$t2, 24($s0)
	add 	$t2, $t2, $t1
    	beqz	$t2, return_true 
	j		return_false

return_true:
        addi	$v0, $v0, 1
        la 		$s1, player1
        la 		$s2, player2
        li		$t1, 5
        li		$t5, 11

sum_soldiers_player1:
        ble		$t1, $0, sum_soldiers_player2
        sll		$t4, $t1, 2
        add		$t2, $t4, $s0
        lw		$t3, 0($t2)
        beqz	$t3, sum_end1
        lw		$t4, 0($s1)
        highlight($t1, $0)
        remove_block($t1)
        add_soldiers($0, $t4, $t3)
        update_player_point
        highlight($t1, $v0)
        add		$t4, $t4, $t3
        sw		$t4, 0($s1)
        sw		$0, 0($t2)
        update_point($t1)
sum_end1:
        subi	$t1, $t1, 1
        j	 	sum_soldiers_player1
	
sum_soldiers_player2:
        ble		$t5, 6, pay_loan
        sll		$t4, $t5, 2
        add		$t2, $t4, $s0
        lw		$t3, 0($t2)
        beqz	$t3, sum_end2
        lw		$t4, 0($s2)
        highlight($t5, $0)
        remove_block($t5)
        add_soldiers($v0, $t4, $t3)
        update_player_point
        highlight($t5, $v0)
        add		$t4, $t4, $t3
        sw		$t4, 0($s2)
        sw		$0, 0($t2)
        update_point($t5)
sum_end2:
        subi	$t5, $t5, 1
        j 		sum_soldiers_player2

pay_loan:
        lw  	$t1, 8($s1)
        bnez 	$t1, pay_loan_player1
        lw  	$t1, 8($s2)
        bnez 	$t1, pay_loan_player2
        j   	end

pay_loan_player1:
        lw	$t2, 0($s1)
        sub 	$t2, $t2, $t1
        sw	$t2, 0($s1)
        lw  	$t3, 0($s2)
        add	$t3, $t3, $t1
        sw	$t3, 0($s2)
        sw	$zero, 8($s1)

        lw	$t1, 8($s2)
        bnez 	$t1, pay_loan_player2
        j	end

pay_loan_player2:
        lw  	$t2, 0($s2)
        sub 	$t2, $t2, $t1
        sw  	$t2, 0($s2)
        lw	$t3, 0($s1)
        add	$t3, $t3, $t1
        sw	$t3, 0($s1)
        sw	$zero, 8($s2)
        j 	end
	
return_false:
        add 	$v0, $0, $0
        j	end_checking

end:

end_checking:
# restore registers
	
        lw      $s0, 0($sp)
        lw      $s1, 4($sp)  
        lw      $s2, 8($sp)  
        lw      $t1, 12($sp)  
        lw      $t2, 16($sp)  
        lw      $t3, 20($sp)
        lw	$t4, 24($sp)		
        lw	$t5, 28($sp)
        addi    $sp, $sp, 32

.end_macro

# -------------------------------------------------------- #
# FUNCTION: PLAYER 1 SCATTERING				   #
# -------------------------------------------------------- #

.macro p1_scattering
#reserve registers
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

#getting data
        la   	$s0, board
        la  	$s1, player1
        la  	$s2, player2
        li  	$t0, 1
        li  	$t1, 20
	
check_scatter:
        ble	$t1, $zero, mes
        add 	$t2, $t1, $s0
        lw  	$t3, 0($t2)
        bnez	$t3, end_not_scatter
        subi	$t1, $t1, 4
        j 	check_scatter
	
mes:
        fill_side
        lw	$t1, 0($s1)
        li	$t2, 5
        blt 	$t1, $t2, update_soldiers
        remove_soldier_points($0, $t1, $t2)
        subi	$t1, $t1, 5
        sw	$t1, 0($s1)
        li	$t1, 5
        j	scatter
	
update_soldiers:	
        fill_side_borrow
        lw  	$t3, 0($s2)
        remove_soldier_points($t0, $t3, $t2)
        subi	$t3, $t3, 5
        sw	    $t3, 0($s2)
        lw	    $t3, 8($s1)
        addi	$t3, $t3, 5
        sw  	$t3, 8($s1)	
        li	    $t1, 5

scatter:
        ble 	$t1, $zero, end
        sll 	$t3, $t1, 2
        add 	$t2, $t3, $s0
        sw  	$t0, 0($t2)
        highlight($t1, $0)
        draw_soldiers($t1, $t0, $0, $0)
        delay(100)
        update_point($t1)
        highlight($t1, $t0)
        subi	$t1, $t1, 1
        j 	    scatter

end:
        la	    $a0, scatter_success
        la	    $a1, 1
        li	    $v0, 55
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
# FUNCTION: PLAYER 2 SCATTERING				   #
# -------------------------------------------------------- #
.macro p2_scattering
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
        fill_side
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
        fill_side_borrow
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
        draw_soldiers($t4, $t0, $0, $0)
        delay(100)
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
