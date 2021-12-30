# -------------------------------------------------------- #
# --------------------- DATA SEGMENT --------------------- #
# -------------------------------------------------------- #
.data 

base:			.word 	0x10040000
bgr_color:		.word	0xfafafa#0xfbd145
line_color:		.word 	0xFF3c3c#0xe94810
point_color:	.word	0x030187
hl_color:		.word	0x852909
num_color:		.word	0x007f91#0x8A0000 
p_point_color:	.word 	0x852909
word_hl:		.word	0xDC00C8
word_color:		.word	0x5A0044
s_patterns:		.word	0, -5120, 5120, -20, 20,              # the amount need to add (from the middle) 
						-5140, 5140, -5100, 5100, -10240,    # when adding a new soldier in a soldier block
						10240, -40, 40, -10260, 10260, 
						-10220, 10220, -5160, 5160, -5080,
						5080, -10280, 10280, -10200, 10200  
m_patterns:		.word	3048, 3120, 
						-5144, -5120, -5096, -5072,        # the amount need to add (from the middle)
                        11240, 11264, 11288, 11312,	       # when adding a new soldier in mandarin block
                        -10264, -10240, -10216, -10192,
                        16360, 16384, 16408, 16432, 
                        -15384, -15360, -15336, -15312,
                        21480, 21504, 21528, 21552
blocks:			.word	61548, 42232, 42360, 42488, 42616, 42744,	# middle of each block
						62316, 87800, 87672, 87544, 87416, 87288
m_blocks:		.word 	61548, 62316 	# middle of each mandarin block
block_corners:	.word	28732, 28860, 28988, 29116, 29244, 29372, 		# corner of each block, used to make highlight
						29500, 66236, 66108, 65980, 65852, 65724
points_mid:		.word	96372, 58612, 58740, 58868, 58996, 59124,
						97140, 69364, 69236, 69108, 68980, 68852
p1_s_points:	.word 	1392	# position of first soldier in player1's point block
p2_s_points:	.word	115056	# position of first soldier in player2's point block
p1_m_points:	.word 	4420, 4764		# position of mandarins in player1's point block
p2_m_points:	.word	118084, 118428	# position of mandarins in player1's point block
# -------------------------------------------------------- #
# --------------------- CODE SEGMENT --------------------- #f
# -------------------------------------------------------- #
.text
# -------------------------------------------------------- #
# FUNCTION: DRAW INITIAL MSC GAME                          #
# Input: is_pvb = 0.PvP, 1 - vs FRED, 2 - vs EVIE          #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro draw_init(%is_pvb)
# reserve registers
        subi    $sp, $sp, 16
        sw      $a0, 0($sp)
        sw      $a1, 4($sp)
        sw      $a2, 8($sp)
        sw      $a3, 12($sp)
# draw init soldier blocks
		draw_background
        draw_board
        draw_point_block
        draw_player_point
        update_player_point
        update_all_points
        display_player(%is_pvb)
        li      $a0, 1
        li      $a1, 6
        li      $a2, 5
        li      $a3, 0
draw_init_loop:
        beq     $a0, $a1, end_draw_init_loop
        draw_soldiers($a0, $a2, $a3, $a3)
        addi    $a0, $a0, 1
        j       draw_init_loop
end_draw_init_loop:
        li      $a0, 7
        li      $a1, 12
draw_init_loop1:
        beq     $a0, $a1, end_draw_init_loop1
        draw_soldiers($a0, $a2, $a3, $a3)
        addi    $a0, $a0, 1
        j       draw_init_loop1
end_draw_init_loop1:
# draw init mandarin blocks
        li      $a0, 0
        li      $a1, 0
        draw_mandarins($a0, $a1)
        li      $a0, 1
        draw_mandarins($a0, $a1)
# return all registers value
        lw      $a0, 0($sp)
        lw      $a1, 4($sp)
        lw      $a2, 8($sp)
        lw      $a3, 12($sp)
        addi    $sp, $sp, 16
.end_macro

# -------------------------------------------------------- #
# FUNCTION: DRAW SOLDIERS IN A BLOCK                       #
# Input: block_num   = soldier block number (0-11)         #
#        soldier_num = number of soldiers,                 #
#        start_num   = starting number (default 0)         #
#        is_delay    = delay or not (0 - not, 1 - delay)   #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro draw_soldiers(%block_num, %soldier_num, %start_num, %is_delay)
# reserve registers
		subi	$sp, $sp, 28
		sw		$s0, 0($sp)
		sw		$s1, 4($sp)
		sw		$s2, 8($sp)
		sw		$s3, 12($sp)
		sw		$s4, 16($sp)
		sw		$s5, 20($sp)
		sw		$s6, 24($sp)
# load middle of the block
		lw		$s0, base
		la		$s2, blocks
		sll		$s1, %block_num, 2
		add		$s2, $s2, $s1
		lw		$s1, 0($s2)
		add		$s0, $s0, $s1
		move	$s6, $s0
# determine whether soldier or mandarin block
		li		$s1, 0
		beq		%block_num, $s1, draw_m
		li		$s1, 6
		beq		%block_num, $s1, draw_m
# draw soldiers (each soldier is a point) by patterns
		lw		$s1, point_color
		la		$s2, s_patterns
		sll		$s5, %start_num, 2
		move	$s3, %start_num
		add		$s2, $s2, $s5
		add		$s4, %start_num, %soldier_num
s_loop:
		beqz	%is_delay, s_loop_ignore_delay
		delay(200)
s_loop_ignore_delay:
		beq		$s3, $s4, end_s_loop
		move	$s0, $s6
		lw		$s5, 0($s2)
		add		$s0, $s0, $s5
		li		$s5, 3
		draw_point($s0, $s5, $s1)
		addi	$s2, $s2, 4
		addi	$s3, $s3, 1
		j		s_loop
end_s_loop:
		j 		end_draw
draw_m:
# draw soldiers in the mandarin block
		lw		$s1, point_color
		la		$s2, m_patterns
		sll		$s3, %start_num, 2
		add		$s2, $s2, $s3
		move	$s3, %start_num
		add		$s4, %start_num, %soldier_num
ms_loop:
		beqz	%is_delay, ms_loop_ignore_delay
		delay(300)
ms_loop_ignore_delay:
		beq		$s3, $s4, end_ms_loop
		move	$s0, $s6
		lw		$s5, 0($s2)
		add		$s0, $s0, $s5
		li		$s5, 3
		draw_point($s0, $s5, $s1)
		addi	$s3, $s3, 1
		addi	$s2, $s2, 4	
		j		ms_loop
end_ms_loop:
end_draw:
# return reserve
		lw		$s0, 0($sp)
		lw		$s1, 4($sp)
		lw		$s2, 8($sp)
		lw		$s3, 12($sp)
		lw		$s4, 16($sp)
		lw		$s5, 20($sp)
		lw		$s6, 24($sp)
		addi	$sp, $sp, 28
.end_macro

# -------------------------------------------------------- #
# FUNCTION: DRAW MANDARINS                                 #
# Input: block_num   = mandarin block number (0/1)         #
#        is_delay    = delay or not (0 - not, 1 - delay)   #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro draw_mandarins(%block_num, %is_delay)
# reserve registers:
		subi	$sp, $sp, 12
		sw		$a0, 0($sp)
		sw		$a1, 4($sp)
		sw		$s1, 8($sp)
		beqz	%is_delay, draw_mandarin_ignore_delay
		delay(300)
draw_mandarin_ignore_delay:
		sll		$a1, %block_num, 2
		la		$a0, m_blocks
		add		$a0, $a0, $a1
		lw		$a1, 0($a0)
		lw		$a0, base
		add		$a1, $a0, $a1
		li		$a0, 9
		lw		$s1, point_color
		draw_point($a1, $a0, $s1)
# return reserve
		lw		$a0, 0($sp)
		lw		$a1, 4($sp)
		lw		$s1, 8($sp)
		addi	$sp, $sp, 12
.end_macro

# -------------------------------------------------------- #
# FUNCTION: REMOVE SOLDIERS/MANDARINS IN A BLOCK           #
# Input: block_num   =  block number (0 - 11)              #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro remove_block(%block_num)
# reserve registers
		subi	$sp, $sp, 28
		sw		$s0, 0($sp)
		sw		$s1, 4($sp)
		sw		$s2, 8($sp)
		sw		$s3, 12($sp)
		sw		$s4, 16($sp)
		sw		$s5, 20($sp)
		sw		$s6, 24($sp)
# load middle of the block
		sll		$s1, %block_num, 2
		la		$s2, blocks
		add		$s2, $s2, $s1
		lw		$s1, 0($s2)
		lw		$s0, base
		add		$s0, $s0, $s1
		move	$s6, $s0
		delay(500)
# determine whether soldier or mandarin block
		li		$s1, 0
		beq		%block_num, $s1, remove_m_block
		li		$s1, 6
		beq		%block_num, $s1, remove_m_block
# remove all point by redrawing each point by background color
		lw		$s1, bgr_color
		la		$s2, s_patterns
		li		$s3, 0
		li		$s4, 25
remove_s_loop:
		beq		$s3, $s4, end_rs_loop
		move	$s0, $s6
		lw		$s5, 0($s2)
		add		$s0, $s0, $s5
		li		$s5, 3
		draw_point($s0, $s5, $s1)
		addi	$s2, $s2, 4
		addi	$s3, $s3, 1
		j		remove_s_loop
end_rs_loop:
		j		end_remove
remove_m_block:
# remove 9x9 points of the mandarin
		lw		$s1, bgr_color
		li		$s2, 9
		draw_point($s0, $s2, $s1)
# remove the rest soldiers of the block
		lw		$s1, bgr_color
		la		$s2, m_patterns
		li		$s3, 0
		li		$s4, 26
remove_sm_loop:
		beq		$s3, $s4, end_rsm_loop
		move	$s0, $s6
		lw		$s5, 0($s2)
		add		$s0, $s0, $s5
		li		$s5, 3
		draw_point($s0, $s5, $s1)
		addi	$s2, $s2, 4
		addi	$s3, $s3, 1
		j		remove_sm_loop
end_rsm_loop:
end_remove:
# return reserve
		lw		$s0, 0($sp)
		lw		$s1, 4($sp)
		lw		$s2, 8($sp)
		lw		$s3, 12($sp)
		lw		$s4, 16($sp)
		lw		$s5, 20($sp)
		lw		$s6, 24($sp)
		addi	$sp, $sp, 28
.end_macro

# -------------------------------------------------------- #
# FUNCTION: ADD MANDARIN TO PLAYER POINT                   #
# Input: mandarin_num = mandarin number (0-1)              #
# 		 player_num   = player number (0-1)                #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro add_mandarin(%player_num, %mandarin_num)
# reserve registers
        subi    $sp, $sp, 12
        sw      $s0, 0($sp)
        sw      $s1, 4($sp)
        sw      $s2, 8($sp)
# check wheter adding to player 1 or 2
		beqz	%player_num, add_m_p1
		la		$s1, p2_m_points
		j		add_m_p1_end
add_m_p1:
		la		$s1, p1_m_points
add_m_p1_end:
# draw mandarin (each soldier is made up of 9x9 points)
		sll		$s2, %mandarin_num, 2
		add		$s1, $s1, $s2
		lw		$s2, 0($s1)
		lw		$s0, base
		add		$s0, $s0, $s2
		lw		$s1, point_color
		li		$s2, 9
		draw_point($s0, $s2, $s1)

# return all registers value
        lw      $s0, 0($sp)
        lw      $s1, 4($sp)
        lw      $s2, 8($sp)
        addi    $sp, $sp, 12
.end_macro

# -------------------------------------------------------- #
# FUNCTION: DRAW MSC BOARD                                 #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro draw_board
# reserve registers
		subi	$sp, $sp, 20
		sw		$s0, 0($sp)
		sw		$s1, 4($sp)	
		sw		$s2, 8($sp)
		sw		$s3, 12($sp)
		sw		$s4, 16($sp)
# load top left corner of the black board
		lw	$s0, base
		lw		$s1, line_color
		move	$s2, $s0
# Draw upper line
		li		$s3, 0
		li		$s4, 224
		addi	$s0, $s0, 28732	# add to get top left corner of the msc board
upper_line_loop:
		beq		$s4, $s3, end_upper_line
		sw		$s1, 0($s0)
		addi	$s3, $s3, 1
		add		$s0, $s0, 4
		j 		upper_line_loop
end_upper_line:	

# Draw lower line
		move	$s0, $s2
		li		$s3, 0
		li		$s4, 224
		addi	$s0, $s0, 102460 # add to get the first point of the lower line
lower_line_loop:
		beq		$s4, $s3, end_lower_line
		sw		$s1, 0($s0)
		addi	$s3, $s3, 1
		add		$s0, $s0, 4
		j 		lower_line_loop
end_lower_line:

# Draw horizonal line
		move	$s0, $s2    
		li		$s3, 0
		li		$s4, 584
		addi	$s0, $s0, 28732
hor_line_loop:
		beq		$s4, $s3, end_hor_line
		sw		$s1, 0($s0)
		addi	$s3, $s3, 1
		add		$s0, $s0, 128
		j 		hor_line_loop
end_hor_line:

# Draw middle line
		move	$s0, $s2
		li		$s3, 0
		li		$s4, 160
		addi	$s0, $s0, 65724 # add to get the first point of the middle line
mid_line_loop:
		beq		$s4, $s3, mid_hor_line
		sw		$s1, 0($s0)
		addi	$s3, $s3, 1
		add		$s0, $s0, 4
		j 		mid_line_loop
mid_hor_line:
# return all reserved registers value
		lw		$s0, 0($sp)
		lw		$s1, 4($sp)	
		lw		$s2, 8($sp)
		lw		$s3, 12($sp)
		lw		$s4, 16($sp)
		addi	$sp, $sp, 20
.end_macro

# -------------------------------------------------------- #
# FUNCTION: HIGHLIGHT A BLOCK							   #
# Input: block_num = block number (0 - 11)				   # 
# 		 is_de_hl = highlight (0) or "dehiglight" (1)	   # 
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro highlight(%block_num, %is_de_hl)
# reserve registers
        subi    $sp, $sp, 28
        sw      $s0, 0($sp)
        sw      $s1, 4($sp)
        sw      $s2, 8($sp)
        sw      $s3, 12($sp)
        sw		$s4, 16($sp)
        sw		$s5, 20($sp)
        sw		$s6, 24($sp)
# load corner of the block
		la		$s0, block_corners
		sll		$s1, %block_num, 2
		add		$s0, $s0, $s1
		lw		$s1, 0($s0)
		lw		$s0, base
		add		$s0, $s1, $s0
		move	$s6, $s0
# check whether soldier hor mandarin block	
		li		$s1, 0
		beq		%block_num, $s1, highlight_m
		li		$s1, 6
		beq		%block_num, $s1, highlight_m
highlight_s:
# draw vertical line
		beqz	%is_de_hl, s_hl
		lw		$s1, line_color
		j		endif_s_hl
s_hl:
		lw		$s1, hl_color
endif_s_hl:
		li		$s2, 0
		li		$s3, 33
loop_hl_s_ver:
		beq		$s2, $s3, end_loop_hl_s_ver
		sw		$s1, 0($s0)
		addi	$s0, $s0, 36864
		sw		$s1, 0($s0)
		addi	$s0, $s0, -36860
		addi	$s2, $s2, 1
		j		loop_hl_s_ver
end_loop_hl_s_ver:
# draw horizontal line
		move	$s0, $s6
		add		$s0, $s0, 1024
		li		$s2, 0
		li		$s3, 36

loop_hl_s_hor:
		beq		$s2, $s3, end_loop_hl_s_hor
		sw		$s1, 0($s0)
		addi	$s0, $s0, 128
		sw		$s1, 0($s0)
		addi	$s0, $s0, 896
		addi	$s2, $s2, 1
		j		loop_hl_s_hor
end_loop_hl_s_hor:
		j		end_highlight

# highlight mandarin block
highlight_m:
# draw vertical line
		beqz	%is_de_hl, m_hl
		lw		$s1, line_color
		j		endif_m_hl
m_hl:
		lw		$s1, hl_color
endif_m_hl:
		li		$s2, 0
		li		$s3, 33
loop_hl_m_ver:
		beq		$s2, $s3, end_loop_hl_m_ver
		sw		$s1, 0($s0)
		addi	$s0, $s0, 73728
		sw		$s1, 0($s0)
		addi	$s0, $s0, -73724
		addi	$s2, $s2, 1
		j		loop_hl_m_ver
end_loop_hl_m_ver:
# draw horizontal line
		move	$s0, $s6
		add		$s0, $s0, 1024
		li		$s2, 0
		li		$s3, 72

loop_hl_m_hor:
		beq		$s2, $s3, end_loop_hl_m_hor
		sw		$s1, 0($s0)
		addi	$s0, $s0, 128
		sw		$s1, 0($s0)
		addi	$s0, $s0, 896
		addi	$s2, $s2, 1
		j		loop_hl_m_hor
end_loop_hl_m_hor:
end_highlight:
# return all registers value
        lw      $s0, 0($sp)
        lw      $s1, 4($sp)
        lw      $s2, 8($sp)
        lw      $s3, 12($sp)
        lw		$s4, 16($sp)
        lw		$s5, 20($sp)
        lw		$s6, 24($sp)
        addi    $sp, $sp, 28
.end_macro

# -------------------------------------------------------- #
# FUNCTION: DELAY A TIME of miliseconds                    #
# Input: block_num   = soldier block number (0 - 9)        #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro delay(%miliseconds)
		subi	$sp, $sp, 4
		sw		$a0, 0($sp)
		
		li		$v0, 32
		li 		$a0, %miliseconds
		syscall
		
		lw		$a0, 0($sp)
		addi	$sp, $sp, 4
.end_macro


# -------------------------------------------------------- #
# FUNCTION: DRAW BACKGROUND OF MSC GAME                    #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro draw_background
# reserve registers
        subi    $sp, $sp, 16
        sw      $s0, 0($sp)
        sw      $s1, 4($sp)
        sw      $s2, 8($sp)
        sw      $s3, 12($sp)
# draw init soldier blocks
        lw	    $s0, base
        lw      $s1, bgr_color
        li      $s2, 0
        li      $s3, 32768
draw_background_loop:
        beq     $s2, $s3, end_draw_background_loop
        sw		$s1, 0($s0)
        addi	$s0, $s0, 4
        addi	$s2, $s2, 1
        j       draw_background_loop
end_draw_background_loop:
# return all registers value
        lw      $s0, 0($sp)
        lw      $s1, 4($sp)
        lw      $s2, 8($sp)
        lw      $s3, 12($sp)
        addi    $sp, $sp, 16
.end_macro

# -------------------------------------------------------- #
# FUNCTION: DRAW POINT BLOCK OF MSC GAME                   #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro draw_point_block
# reserve registers
        subi    $sp, $sp, 16
        sw      $s0, 0($sp)
        sw      $s1, 4($sp)
        sw      $s2, 8($sp)
        sw      $s3, 12($sp)
# draw vertical line
        lw      $s0, base
        lw      $s1, line_color
        li      $s2, 0
        li      $s3, 101
        addi	$s0, $s0, 17720 
draw_point_block_loop:
        beq     $s2, $s3, end_draw_point_block_loop
        sw		$s1, 0($s0)
        addi	$s0, $s0, 95232
        sw		$s1, 0($s0)
        subi	$s0, $s0, 95228
        addi	$s2, $s2, 1
        j       draw_point_block_loop
end_draw_point_block_loop:
# draw horizontal block
		lw		$s0, base
		addi	$s0, $s0, 312
		li		$s2, 0
		li		$s3, 17
loop_draw_hor_pb:
		beq		$s2, $s3, end_loop_draw_hor_pb
		sw		$s1, 0($s0)
		addi	$s0, $s0, 400
		sw		$s1, 0($s0)
		addi	$s0, $s0, 113664
		sw		$s1, 0($s0)
		subi	$s0, $s0, 400
		sw		$s1, 0($s0)
		subi	$s0, $s0, 112640
		addi	$s2, $s2, 1
		j		loop_draw_hor_pb
end_loop_draw_hor_pb:
# return all registers value
        lw      $s0, 0($sp)
        lw      $s1, 4($sp)
        lw      $s2, 8($sp)
        lw      $s3, 12($sp)
        addi    $sp, $sp, 16
.end_macro

# -------------------------------------------------------- #
# FUNCTION: ADD SOLDIERS TO PLAYER POINT                   #
# Input: player_num   = player number (0-1)                #
# 		 starting_num = starting number, default 0 (0-1)   #
# 		 soldier_num  = number of soldiers                 #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro add_soldiers(%player_num, %starting_num, %soldier_num)
# reserve registers
        subi    $sp, $sp, 28
        sw      $s0, 0($sp)
        sw      $s1, 4($sp)
        sw      $s2, 8($sp)
        sw      $s3, 12($sp)
        sw		$s4, 16($sp)
        sw		$s5, 20($sp)
        sw		$s6, 24($sp)
# check wheter adding to player 1 or 2
		beqz	%player_num, add_s_p1
		lw		$s1, p2_s_points
		j		add_s_p1_end
add_s_p1:
		lw		$s1, p1_s_points
add_s_p1_end:
		lw		$s0, base
		add		$s0, $s0, $s1
		move	$s6, $s0
		move	$s2, %starting_num
		add		$s3, %starting_num, %soldier_num
		lw		$s1, point_color
add_p:
		delay(150)
		beq		$s2, $s3, end_add_p
		move	$s0, $s6
		li		$s5, 15
		div		$s2, $s5
		mfhi	$s4		# remainder		
		mflo	$s5		# quotient
		mul		$s4, $s4, 20
		sll		$s5, $s5, 12
		add		$s0, $s0, $s4
		add		$s0, $s0, $s5
		li		$s4, 3
		draw_point($s0, $s4, $s1)
		addi	$s2, $s2, 1
		j		add_p
end_add_p:

# return all registers value
        lw      $s0, 0($sp)
        lw      $s1, 4($sp)
        lw      $s2, 8($sp)
        lw      $s3, 12($sp)
        lw		$s4, 16($sp)
        lw		$s5, 20($sp)
        lw		$s6, 24($sp)
        addi    $sp, $sp, 28
.end_macro

# -------------------------------------------------------- #
# FUNCTION: REMOVE SOLDIER POINTS WHEN BORROWING		   #
# Input: player_num    = player number (0-1)               #
# 		 current_point = number of points an player known  #
# 		 soldier_num   = number of soldiers 	           #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro remove_soldier_points(%player_num, %current_point, %soldier_num)
# reserve registers
        subi    $sp, $sp, 28
        sw      $s0, 0($sp)
        sw      $s1, 4($sp)
        sw      $s2, 8($sp)
        sw      $s3, 12($sp)
        sw		$s4, 16($sp)
        sw		$s5, 20($sp)
        sw		$s6, 24($sp)
# check wheter adding to player 1 or 2
		beqz	%player_num, remove_s_p1
		lw		$s1, p2_s_points
		j		remove_s_p1_end
remove_s_p1:
		lw		$s1, p1_s_points
remove_s_p1_end:
		lw		$s0, base
		add		$s0, $s1, $s0
		move	$s6, $s0
		addi	$s2, %current_point, -1
		sub		$s3, $s2, %soldier_num
		lw		$s1, bgr_color
remove_s:
		delay(200)
		beq		$s2, $s3, end_remove_s
		move	$s0, $s6
		li		$s5, 15
		div		$s2, $s5
		mfhi	$s4		# remainder		
		mflo	$s5		# quotient
		mul		$s4, $s4, 20
		sll		$s5, $s5, 12
		add		$s0, $s0, $s4
		add		$s0, $s0, $s5
		li		$s4, 3
		draw_point($s0, $s4, $s1)
		subi	$s2, $s2, 1
		j		remove_s
end_remove_s:

# return all registers value
        lw      $s0, 0($sp)
        lw      $s1, 4($sp)
        lw      $s2, 8($sp)
        lw      $s3, 12($sp)
        lw		$s4, 16($sp)
        lw		$s5, 20($sp)
        lw		$s6, 24($sp)
        addi    $sp, $sp, 28
.end_macro

# -------------------------------------------------------- #
# FUNCTION: DRAW A SQUARED POINT                           #
# Input: address = address of top-left corner 			   #
#        width   = width of that point (by pixel)   	   #
#        color   = color of pixel					 	   #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro draw_point(%address, %width, %color)
# reserve registers
        subi    $sp, $sp, 24
        sw      $s0, 0($sp)
        sw      $s1, 4($sp)
        sw      $s2, 8($sp)
        sw      $s3, 12($sp)
        sw		$s4, 16($sp)
        sw		$s5, 20($sp)
# load corner of the point
		move	$s0, %address
		move	$s3, %width
		sll		$s5, %width, 2
		move	$s1, %color
		li		$s2, 0
draw_point_loop1:
		beq		$s2, $s3, end_draw_point_loop1
		li		$s4, 0
draw_point_loop2:
		beq		$s4, $s3, end_draw_point_loop2
		sw		$s1, 0($s0)
		addi	$s4, $s4, 1
		addi	$s0, $s0, 4
		j		draw_point_loop2
end_draw_point_loop2:
		addi	$s2, $s2, 1
		addi	$s0, $s0, 1024
		sub		$s0, $s0, $s5
		j		draw_point_loop1
end_draw_point_loop1:
# return all registers value
        lw      $s0, 0($sp)
        lw      $s1, 4($sp)
        lw      $s2, 8($sp)
        lw      $s3, 12($sp)
        lw		$s4, 16($sp)
        lw		$s5, 20($sp)
        addi    $sp, $sp, 24
.end_macro

# -------------------------------------------------------- #
# FUNCTION: UPDATE ALL POINT IN THE TABLE				   #
# Input: block_num = block number                   	   #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro update_all_points
# reserve registers
        subi    $sp, $sp, 8
        sw      $s0, 0($sp)
        sw      $s1, 4($sp)
# load block point
		li		$s0, 0
		li		$s1, 12
update_point_loop:
		beq		$s0, $s1, end_update_point_loop
		update_point($s0)
		addi	$s0, $s0, 1
		j		update_point_loop
end_update_point_loop:
# return all registers value
        lw      $s0, 0($sp)
        lw      $s1, 4($sp)
        addi    $sp, $sp, 8
.end_macro


# -------------------------------------------------------- #
# FUNCTION: UPDATE POINT IN THE TABLE                      #
# Input: block_num = block number                   	   #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro update_point(%block_num)
# reserve registers
        subi    $sp, $sp, 20
        sw      $s0, 0($sp)
        sw      $s1, 4($sp)
        sw      $s2, 8($sp)
        sw      $a1, 12($sp)
        sw      $a2, 16($sp)
# load block point
		move	$s1, %block_num
		sll		$s2, $s1, 2
		la		$s0, board
		add		$s0, $s0, $s2
		lw		$s2, 0($s0)
# determine position in the board
		sll		$s1, $s1, 2
		la		$s0, points_mid
		add		$s0, $s0, $s1
		lw		$s1, 0($s0)
		lw		$s0, base
		add		$s0, $s0, $s1
# determine two digits of the point
		li		$s1, 10
		div		$s2, $s1
		mfhi	$a2		# remainder
		mflo	$a1		# quotent
		remove_num($s0)
		lw		$s2, num_color
		draw_number($s0, $a1, $s2)
		addi	$s0, $s0, 16
		remove_num($s0)
		draw_number($s0, $a2, $s2)
# return all registers value
        lw      $s0, 0($sp)
        lw      $s1, 4($sp)
        lw      $s2, 8($sp)
        lw      $a1, 12($sp)
        lw      $a2, 16($sp)
        addi    $sp, $sp, 20
.end_macro

# -------------------------------------------------------- #
# FUNCTION: DRAW PLAYER POINT BLOCK                        #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro draw_player_point
# reserve registers
        subi    $sp, $sp, 16
        sw      $s0, 0($sp)
        sw      $s1, 4($sp)
        sw      $s2, 8($sp)
        sw      $s3, 12($sp)
# load corner of the block
		lw		$s0, base
		addi	$s0, $s0, 2784
		lw		$s1, line_color
		li		$s2, 0
		li		$s3, 12
loop_player_point_ver:
		beq		$s2, $s3, end_loop_player_point_ver
		sw		$s1, 0($s0)
		addi	$s0, $s0, 12288
		sw		$s1, 0($s0)
		addi	$s0, $s0, 101376
		sw		$s1, 0($s0)
		addi	$s0, $s0, 12288
		sw		$s1, 0($s0)
		addi	$s0, $s0, -125948
		addi	$s2, $s2, 1
		j		loop_player_point_ver
end_loop_player_point_ver:

# draw horizontal line
		lw		$s0, base
		addi	$s0, $s0, 2784
		li		$s2, 0
		li		$s3, 13
loop_player_point_hor:
		beq		$s2, $s3, end_loop_player_point_hor
		sw		$s1, 0($s0)
		addi	$s0, $s0, 48
		sw		$s1, 0($s0)
		addi	$s0, $s0, 113664
		sw		$s1, 0($s0)
		subi	$s0, $s0, 48
		sw		$s1, 0($s0)
		addi	$s0, $s0, -112640
		addi	$s2, $s2, 1
		j		loop_player_point_hor
end_loop_player_point_hor:
# return all registers value
        lw      $s0, 0($sp)
        lw      $s1, 4($sp)
        lw      $s2, 8($sp)
        lw      $s3, 12($sp)
        addi    $sp, $sp, 16
.end_macro

# -------------------------------------------------------- #
# FUNCTION: UPDATE PLAYER POINT                            #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro update_player_point
# reserve registers
        subi    $sp, $sp, 20
        sw      $s0, 0($sp)
        sw      $s1, 4($sp)
        sw      $s2, 8($sp)
        sw      $a1, 12($sp)
        sw		$a2, 16($sp)
# player1
		la		$s0, player1
		lw		$s1, 0($s0)
		lw		$s2, 4($s0)
		mul		$s2, $s2, 5
		add		$s1, $s1, $s2
		li		$s2, 10
		div		$s1, $s2
		mfhi	$a2		# remainder
		mflo	$a1		# quotient
		lw		$s0, base
		addi	$s0, $s0, 6896
		lw		$s2, num_color
		remove_num($s0)
		draw_number($s0, $a1, $s2)
		addi	$s0, $s0, 16
		remove_num($s0)
		draw_number($s0, $a2, $s2)
# player 2
		la		$s0, player2
		lw		$s1, 0($s0)
		lw		$s2, 4($s0)
		mul		$s2, $s2, 5
		add		$s1, $s1, $s2
		li		$s2, 10
		div		$s1, $s2
		mfhi	$a2		# remainder
		mflo	$a1		# quotient
		lw		$s0, base
		addi	$s0, $s0, 120560
		lw		$s2, num_color
		remove_num($s0)
		draw_number($s0, $a1, $s2)
		addi	$s0, $s0, 16
		remove_num($s0)
		draw_number($s0, $a2, $s2)
# return all registers value
        lw      $s0, 0($sp)
        lw      $s1, 4($sp)
        lw      $s2, 8($sp)
        lw      $a1, 12($sp)
        lw		$a2, 16($sp)
        addi    $sp, $sp, 20
.end_macro

# -------------------------------------------------------- #
# FUNCTION: DRAW UPPER BLOCK NUMBER                        #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro draw_upper_block_number
# reserve registers
        subi    $sp, $sp, 16
        sw      $s0, 0($sp)
        sw      $s1, 4($sp)
        sw      $a1, 8($sp)
        sw      $a2, 12($sp)
# draw upper block number
		lw		$s0, base
		addi	$s0, $s0, 22780
		li		$a1, 1
		li		$s1, 6
draw_block_number_loop1:
		beq		$a1, $s1, end_draw_block_number_loop1
		lw		$a2, p_point_color
		draw_number($s0, $a1, $a2)
		highlight($a1, $0)
		addi	$s0, $s0, 128
		addi	$a1, $a1, 1
		j		draw_block_number_loop1
end_draw_block_number_loop1:
# return all registers value
        lw      $s0, 0($sp)
        lw      $s1, 4($sp)
        lw      $a1, 8($sp)
        lw      $a2, 12($sp)
        addi    $sp, $sp, 16
.end_macro

# -------------------------------------------------------- #
# FUNCTION: REMOVE UPPER BLOCK NUMBER                      #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro remove_upper_block_number
# reserve registers
        subi    $sp, $sp, 16
        sw      $s0, 0($sp)
        sw      $s1, 4($sp)
        sw      $a1, 8($sp)
        sw		$a2, 12($sp)
# draw upper block number
		lw		$s0, base
		addi	$s0, $s0, 22780
		li		$a1, 1
		li		$s1, 6
		li		$a2, 1
remove_block_number_loop1:
		beq		$a1, $s1, end_remove_block_number_loop1
		remove_num($s0)
		highlight($a1, $a2)
		addi	$s0, $s0, 128
		addi	$a1, $a1, 1
		j		remove_block_number_loop1
end_remove_block_number_loop1:
# return all registers value
        lw      $s0, 0($sp)
        lw      $s1, 4($sp)
        lw      $a1, 8($sp)
        lw		$a2, 12($sp)
        addi    $sp, $sp, 16
.end_macro

# -------------------------------------------------------- #
# FUNCTION: REMOVE LOWER BLOCK NUMBER                        #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro remove_lower_block_number
# reserve registers
        subi    $sp, $sp, 16
        sw      $s0, 0($sp)
        sw      $s1, 4($sp)
        sw      $a1, 8($sp)
        sw		$a2, 12($sp)
# draw lower block number
		lw		$s0, base
		addi	$s0, $s0, 105212
		li		$a1, 6
		li		$s1, 10
		li		$a2, 1
remove_block_number_loop2:
		beq		$a1, $s1, end_remove_block_number_loop2
		remove_num($s0)
		addi	$a1, $a1, 1
		subi	$s0, $s0, 128
		highlight($a1, $a2)
		j		remove_block_number_loop2
end_remove_block_number_loop2:
		addi	$a1, $a1, 1
		highlight($a1, $a2)
		subi	$s0, $s0, 8
		remove_num($s0)
		addi	$s0, $s0, 16
		remove_num($s0)
# return all registers value
        lw      $s0, 0($sp)
        lw      $s1, 4($sp)
        lw      $a1, 8($sp)
        lw		$a2, 12($sp)
        addi    $sp, $sp, 16
.end_macro

# -------------------------------------------------------- #
# FUNCTION: DRAW LOWER BLOCK NUMBER                        #
# Reserve: all register used                               #
# -------------------------------------------------------- #
.macro draw_lower_block_number
# reserve registers
        subi    $sp, $sp, 16
        sw      $s0, 0($sp)
        sw      $s1, 4($sp)
        sw      $a1, 8($sp)
        sw      $a2, 12($sp)
# draw lower block number
		lw		$s0, base
		addi	$s0, $s0, 105212
		li		$a1, 6
		li		$s1, 10
draw_block_number_loop2:
		beq		$a1, $s1, end_draw_block_number_loop2
		lw		$a2, p_point_color
		draw_number($s0, $a1, $a2)
		addi	$a1, $a1, 1
		highlight($a1, $0)
		subi	$s0, $s0, 128
		j		draw_block_number_loop2
end_draw_block_number_loop2:
		addi	$a1, $a1, 1
		highlight($a1, $0)
		lw		$a2, p_point_color
		subi	$s0, $s0, 8
		draw_number_1($s0, $a2)
		addi	$s0, $s0, 16
		draw_number_0($s0, $a2)
# return all registers value
        lw      $s0, 0($sp)
        lw      $s1, 4($sp)
        lw      $a1, 8($sp)
        lw      $a2, 12($sp)
        addi    $sp, $sp, 16
.end_macro
