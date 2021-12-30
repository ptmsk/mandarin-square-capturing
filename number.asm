# -------------------------------------------------------- #
# FUNCTION: DRAW A 1-digit-NUMBER 		                   #
# Input: address = address of top middle of the number	   #
# 		 number  = number need to be drawn		   		   #
# 		 color   = color of the number	    	   		   #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro draw_number(%address, %number, %color)
# reserve registers
		subi	$sp, $sp, 8
		sw		$s0, 0($sp)
		sw		$s1, 4($sp)
# determine number
		move	$s0, %address
		li		$s1, 0
		beq		$s1, %number, draw_num_0
		li		$s1, 1
		beq		$s1, %number, draw_num_1
		li		$s1, 2
		beq		$s1, %number, draw_num_2
		li		$s1, 3
		beq		$s1, %number, draw_num_3
		li		$s1, 4
		beq		$s1, %number, draw_num_4
		li		$s1, 5
		beq		$s1, %number, draw_num_5
		li		$s1, 6
		beq		$s1, %number, draw_num_6
		li		$s1, 7
		beq		$s1, %number, draw_num_7
		li		$s1, 8
		beq		$s1, %number, draw_num_8
		li		$s1, 9
		beq		$s1, %number, draw_num_9
		j		end_draw_num
draw_num_0:
		draw_number_0($s0, %color)
		j		end_draw_num
draw_num_1:
		draw_number_1($s0, %color)
		j		end_draw_num
draw_num_2:
		draw_number_2($s0, %color)
		j		end_draw_num
draw_num_3:
		draw_number_3($s0, %color)
		j		end_draw_num
draw_num_4:
		draw_number_4($s0, %color)
		j		end_draw_num
draw_num_5:
		draw_number_5($s0, %color)
		j		end_draw_num
draw_num_6:
		draw_number_6($s0, %color)
		j		end_draw_num
draw_num_7:
		draw_number_7($s0, %color)
		j		end_draw_num
draw_num_8:
		draw_number_8($s0, %color)
		j		end_draw_num
draw_num_9:
		draw_number_9($s0, %color)
end_draw_num:
# return all registers' value
		lw		$s0, 0($sp)
		lw		$s1, 4($sp)
		addi	$sp, $sp, 8
.end_macro

# -------------------------------------------------------- #
# FUNCTION: DRAW NUMBER 1 		                           #
# Input: address = address of top middle of the number	   #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro draw_number_1(%address, %color)
# reserve registers
		subi	$sp, $sp, 8
		sw		$s0, 0($sp)
		sw		$s1, 4($sp)
# draw num
		move	$s0, %address
		move	$s1, %color
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
# return all registers' value
		lw		$s0, 0($sp)
		lw		$s1, 4($sp)
		addi	$sp, $sp, 8
.end_macro

# -------------------------------------------------------- #
# FUNCTION: DRAW NUMBER 2 		                           #
# Input: address = address of top middle of the number	   #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro draw_number_2(%address, %color)
# reserve registers
		subi	$sp, $sp, 8
		sw		$s0, 0($sp)
		sw		$s1, 4($sp)
# number 2
		move	$s0, %address
		move	$s1, %color
		sw		$s1, 0($s0)
		subi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 8
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		subi	$s0, $s0, 4
		sw		$s1, 0($s0)
		subi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
# return all registers' value
		lw		$s0, 0($sp)
		lw		$s1, 4($sp)
		addi	$sp, $sp, 8
.end_macro

# -------------------------------------------------------- #
# FUNCTION: DRAW NUMBER 3 		                           #
# Input: address = address of top middle of the number	   #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro draw_number_3(%address, %color)
# reserve registers
		subi	$sp, $sp, 8
		sw		$s0, 0($sp)
		sw		$s1, 4($sp)
# number 3
		move	$s0, %address
		move	$s1, %color
		sw		$s1, 0($s0)
		subi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 8
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		subi	$s0, $s0, 4
		sw		$s1, 0($s0)
		subi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1032
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		subi	$s0, $s0, 4
		sw		$s1, 0($s0)
		subi	$s0, $s0, 4
		sw		$s1, 0($s0)
# return all registers' value
		lw		$s0, 0($sp)
		lw		$s1, 4($sp)
		addi	$sp, $sp, 8
.end_macro

# -------------------------------------------------------- #
# FUNCTION: DRAW NUMBER 4 		                           #
# Input: address = address of top middle of the number	   #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro draw_number_4(%address, %color)
# reserve registers
		subi	$sp, $sp, 8
		sw		$s0, 0($sp)
		sw		$s1, 4($sp)
# number 4
		move	$s0, %address
		move	$s1, %color
		subi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 8
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		subi	$s0, $s0, 8
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
# return all registers' value
		lw		$s0, 0($sp)
		lw		$s1, 4($sp)
		addi	$sp, $sp, 8
.end_macro

# -------------------------------------------------------- #
# FUNCTION: DRAW NUMBER 5 		                           #
# Input: address = address of top middle of the number	   #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro draw_number_5(%address, %color)
# reserve registers
		subi	$sp, $sp, 8
		sw		$s0, 0($sp)
		sw		$s1, 4($sp)
# number 5
		move	$s0, %address
		move	$s1, %color
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		subi	$s0, $s0, 8
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		subi	$s0, $s0, 4
		sw		$s1, 0($s0)
		subi	$s0, $s0, 4
		sw		$s1, 0($s0)
# return all registers' value
		lw		$s0, 0($sp)
		lw		$s1, 4($sp)
		addi	$sp, $sp, 8
.end_macro

# -------------------------------------------------------- #
# FUNCTION: DRAW NUMBER 6 		                           #
# Input: address = address of top middle of the number	   #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro draw_number_6(%address, %color)
# reserve registers
		subi	$sp, $sp, 8
		sw		$s0, 0($sp)
		sw		$s1, 4($sp)
# number 6
		move	$s0, %address
		move	$s1, %color
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		subi	$s0, $s0, 8
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		subi	$s0, $s0, 4
		sw		$s1, 0($s0)
		subi	$s0, $s0, 4
		sw		$s1, 0($s0)
		subi	$s0, $s0, 1024
		sw		$s1, 0($s0)
# return all registers' value
		lw		$s0, 0($sp)
		lw		$s1, 4($sp)
		addi	$sp, $sp, 8
.end_macro

# -------------------------------------------------------- #
# FUNCTION: DRAW NUMBER 7 		                           #
# Input: address = address of top middle of the number	   #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro draw_number_7(%address, %color)
# reserve registers
		subi	$sp, $sp, 8
		sw		$s0, 0($sp)
		sw		$s1, 4($sp)
# number 7
		move	$s0, %address
		move	$s1, %color
		sw		$s1, 0($s0)
		subi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 8
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
# return all registers' value
		lw		$s0, 0($sp)
		lw		$s1, 4($sp)
		addi	$sp, $sp, 8
.end_macro

# -------------------------------------------------------- #
# FUNCTION: DRAW NUMBER 8 		                           #
# Input: address = address of top middle of the number	   #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro draw_number_8(%address, %color)
# reserve registers
		subi	$sp, $sp, 8
		sw		$s0, 0($sp)
		sw		$s1, 4($sp)
# number 8
		move	$s0, %address
		move	$s1, %color
		sw		$s1, 0($s0)
		subi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 8
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		subi	$s0, $s0, 8
		sw		$s1, 0($s0)		
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		subi	$s0, $s0, 8
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
# return all registers' value
		lw		$s0, 0($sp)
		lw		$s1, 4($sp)
		addi	$sp, $sp, 8
.end_macro

# -------------------------------------------------------- #
# FUNCTION: DRAW NUMBER 9 		                           #
# Input: address = address of top middle of the number	   #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro draw_number_9(%address, %color)
# reserve registers
		subi	$sp, $sp, 8
		sw		$s0, 0($sp)
		sw		$s1, 4($sp)
# number 9
		move	$s0, %address
		move	$s1, %color
		sw		$s1, 0($s0)
		subiu 	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 8
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		subi	$s0, $s0, 8
		sw		$s1, 0($s0)		
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		subi	$s0, $s0, 8
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
# return all registers' value
		lw		$s0, 0($sp)
		lw		$s1, 4($sp)
		addi	$sp, $sp, 8
.end_macro

# -------------------------------------------------------- #
# FUNCTION: DRAW NUMBER 0 		                           #
# Input: address = address of top middle of the number	   #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro draw_number_0(%address, %color)
# reserve registers
		subi	$sp, $sp, 8
		sw		$s0, 0($sp)
		sw		$s1, 4($sp)
# number 0
		move	$s0, %address
		move	$s1, %color
		sw		$s1, 0($s0)
		subi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 8
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		subi	$s0, $s0, 8
		sw		$s1, 0($s0)		
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 8
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		subi	$s0, $s0, 8
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
# return all registers' value
		lw		$s0, 0($sp)
		lw		$s1, 4($sp)
		addi	$sp, $sp, 8
.end_macro

# -------------------------------------------------------- #
# FUNCTION: REMOVE DISPLAY NUMBER		                   #
# Input: address = address of top middle of the number	   #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro remove_num(%address)
# reserve registers
		subi	$sp, $sp, 8
		sw		$s0, 0($sp)
		sw		$s1, 4($sp)
# number 8
		move	$s0, %address
		lw		$s1, bgr_color
		sw		$s1, 0($s0)
		subi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 8
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		subi	$s0, $s0, 8
		sw		$s1, 0($s0)		
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		subi	$s0, $s0, 8
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
# return all registers' value
		lw		$s0, 0($sp)
		lw		$s1, 4($sp)
		addi	$sp, $sp, 8
.end_macro

# -------------------------------------------------------- #
# FUNCTION: DRAW THE WORDS 'PLAYER 1' AND 'PLAYER 2'       #
# Input: contain_bot = 0.vs player, 1. vs fred, 2. vs evie #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro display_player(%contain_bot)
# reserve registers
		subi	$sp, $sp, 16
		sw		$s0, 0($sp)
		sw		$a0, 4($sp)
		sw		$a1, 8($sp)
		sw		$t0, 12($sp)
# player 1
		move	$t0, %contain_bot
		lw		$s0, base
		lw		$a1, word_color
		addi	$s0, $s0, 7344
		li		$a0, 1
		draw_player($s0, $a0, $a1)
# check whether play vs bot or not
		li		$a0, 1
		beq		$a0, $t0, draw_vs_fred
		li		$a0, 2
		beq		$a0, $t0, draw_vs_evie
		lw		$s0, base
		addi	$s0, $s0, 118960
		li		$a0, 2
		draw_player($s0, $a0, $a1)
		j		end_display_player
draw_vs_fred:
		draw_fred($a1)
		j		end_display_player
draw_vs_evie:
		draw_evie($a1)
end_display_player:
# return all registers' value
		lw		$s0, 0($sp)
		lw		$a0, 4($sp)
		lw		$a1, 8($sp)
		lw		$t0, 12($sp)
		addi	$sp, $sp, 16
.end_macro

# -------------------------------------------------------- #
# FUNCTION: DRAW THE WORDS 'PLAYER 1' AND 'PLAYER 2'       #
# Input: word_num = 0.fred, 1. player1, 2.player2, 3. evie #
# 		 is_highlight = highlight or not (0 - not/1 - hl)  #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro highlight_word(%word_num, %is_highlight)
# reserve registers
		subi	$sp, $sp, 16
		sw		$s0, 0($sp)
		sw		$a0, 4($sp)
		sw		$a1, 8($sp)
		sw		$a2, 12($sp)
# check is highlight or not
		beqz	%is_highlight, highlight_color
		lw		$a1, word_hl
		j		begin_highlight
highlight_color:
		lw		$a1, word_color
begin_highlight:
# bot
		li		$s0, 0
		beq		$s0, %word_num, highlight_fred
		li		$s0, 3
		beq		$s0, %word_num, highlight_evie
		li		$s0, 1
		beq		$s0, %word_num, highlight_player1
		li		$s0, 2
		beq		$s0, %word_num, highlight_player2
		j		end_hl_word
highlight_fred:
		draw_fred($a1)
		j		end_hl_word
highlight_evie:
		draw_evie($a1)
		j		end_hl_word
highlight_player1:
		lw		$a0, base
		addi	$a0, $a0, 7344
		li		$a2, 1
		draw_player($a0, $a2, $a1)
		j		end_hl_word
highlight_player2:
		lw		$a0, base
		addi	$a0, $a0, 118960
		li		$a2, 2
		draw_player($a0, $a2, $a1)
		j		end_hl_word
end_hl_word:
# return all registers' value
		lw		$s0, 0($sp)
		lw		$a0, 4($sp)
		lw		$a1, 8($sp)
		lw		$a1, 12($sp)
		addi	$sp, $sp, 16
.end_macro

# -------------------------------------------------------- #
# FUNCTION: DRAW THE WORD 'PLAYER' 		                   #
# Input: address = address of top-left corner			   #
# 		 player_num = player number			  			   #
# 		 color   = color of words			  			   #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro draw_player(%address, %player_num, %color)
# reserve registers
		subi	$sp, $sp, 12
		sw		$s0, 0($sp)
		sw		$s1, 4($sp)
		sw		$s2, 8($sp)
# load address
		move	$s0, %address
		move	$s1, %color
# P
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		subi	$s0, $s0, 8
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1016
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
# L
		addi	$s0, $s0, 16
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		subi	$s0, $s0, 1032
		sw		$s1, 0($s0)
		subi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		subi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		subi	$s0, $s0, 1024
		sw		$s1, 0($s0)
# A
		addi	$s0, $s0, 20
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1020
		sw		$s1, 0($s0)
		addi	$s0, $s0, 8
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, -4
		sw		$s1, 0($s0)
		addi	$s0, $s0, -4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 8
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, -8
		sw		$s1, 0($s0)
# Y
		addi	$s0, $s0, 20
		sw		$s1, 0($s0)
		addi	$s0, $s0, -1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, -1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, -1028
		sw		$s1, 0($s0)
		addi	$s0, $s0, 8
		sw		$s1, 0($s0)
		addi	$s0, $s0, -1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, -8
		sw		$s1, 0($s0)
# E
		addi	$s0, $s0, 16
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1016
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1016
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
# R
		addi	$s0, $s0, 8
		sw		$s1, 0($s0)
		addi	$s0, $s0, 8
		sw		$s1, 0($s0)
		addi	$s0, $s0, -1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, -8
		sw		$s1, 0($s0)
		addi	$s0, $s0, -1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, -1028
		sw		$s1, 0($s0)
		addi	$s0, $s0, 8
		sw		$s1, 0($s0)
		addi	$s0, $s0, -1028
		sw		$s1, 0($s0)
		addi	$s0, $s0, -4
		sw		$s1, 0($s0)
# num
		addi	$s0, $s0, 28
		li		$s2, 1
		beq		%player_num, $s2, draw_player1
		draw_number_2($s0, $s1)
		j		end_draw_player
draw_player1:
		draw_number_1($s0, $s1)
end_draw_player:
# return all registers' value
		lw		$s0, 0($sp)
		lw		$s1, 4($sp)
		lw		$s2, 8($sp)
		addi	$sp, $sp, 12
.end_macro

# -------------------------------------------------------- #
# FUNCTION: DRAW THE WORD 'FRED'						   #
# Input: color   = color of words			  			   #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro draw_fred(%color)
# reserve registers
		subi	$sp, $sp, 8
		sw		$s0, 0($sp)
		sw		$s1, 4($sp)
# load position
		lw		$s0, base
		addi	$s0, $s0, 119016
		move	$s1, %color
# F
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1016
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1016
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
# R
		addi	$s0, $s0, 16
		sw		$s1, 0($s0)
		addi	$s0, $s0, 8
		sw		$s1, 0($s0)
		addi	$s0, $s0, -1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, -8
		sw		$s1, 0($s0)
		addi	$s0, $s0, -1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, -1020
		sw		$s1, 0($s0)
		addi	$s0, $s0, -8
		sw		$s1, 0($s0)
		addi	$s0, $s0, -1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
# E
		addi	$s0, $s0, 12
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1016
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1016
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
# D
		addi	$s0, $s0, -4088
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1020
		sw		$s1, 0($s0)
		addi	$s0, $s0, 8
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, -8
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 8
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1020
		sw		$s1, 0($s0)
		addi	$s0, $s0, -4
		sw		$s1, 0($s0)
# return all registers' value
		lw		$s0, 0($sp)
		lw		$s1, 4($sp)
		addi	$sp, $sp, 8
.end_macro

# -------------------------------------------------------- #
# FUNCTION: DRAW THE WORD 'EVIE'						   #
# Input: color   = color of words			  			   #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro draw_evie(%color)
# reserve registers
		subi	$sp, $sp, 8
		sw		$s0, 0($sp)
		sw		$s1, 4($sp)
# load position
		lw		$s0, base
		addi	$s0, $s0, 119016
		move	$s1, %color
# E
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1016
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1016
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
# V
		addi	$s0, $s0, 12
		sw		$s1, 0($s0)
		addi	$s0, $s0, -1028
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, -1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, -8
		sw		$s1, 0($s0)
		addi	$s0, $s0, -1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 8
		sw		$s1, 0($s0)
		addi	$s0, $s0, -1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, -8
		sw		$s1, 0($s0)
# I
		addi	$s0, $s0, 16
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1020
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, -4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 8
		sw		$s1, 0($s0)
# E
		addi	$s0, $s0, 8
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, -1032
		sw		$s1, 0($s0)
		addi	$s0, $s0, -1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, -1032
		sw		$s1, 0($s0)
		addi	$s0, $s0, -1024
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
		addi	$s0, $s0, 4
		sw		$s1, 0($s0)
# return all registers' value
		lw		$s0, 0($sp)
		lw		$s1, 4($sp)
		addi	$sp, $sp, 8
.end_macro