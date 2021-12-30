.data
	welcome:			.asciiz		"Welcome to Mandarin Square Capturing Game!\n  - 0 to read the rule\n  - 1 to skip rules and play games"
	rule_description: 	.ascii		"  ========================================================= RULE DESCRIPTION =========================================================\n"
						.ascii		"* SETUP:\nEach player places one Mandarin piece in the Mandarin square as well as five citizen pieces in each of the rice field squares.\n"
						.ascii		"* OBJECTIVE:\n- The game ends when all the pieces are captured.\n- If both Mandarin pieces are captured, the remaining citizen pieces belong to the player "
						.ascii		"controlling the side that these pieces are on.\n- Whichever player has more pieces is the winner (a Mandarin piece is equal to five citizen pieces).\n"
						.ascii		"* SCATTERING:\n- The first player takes up all the pieces of any rice field square on his/her side of the board and distributes one piece per square, "
						.ascii		"starting at the next square in either direction.\n   When all pieces are distributed, the player repeats by taking up the pieces of the following square and distributing them.\n\n"
						.ascii		"                       |---------|    1    |    2    |    3    |    4    |    5    |---------|             "
						.ascii		"| * NOTE: In this game, we would like to impose some conventions that make the game easier to play\n"
						.ascii		"                       |    M    |--------|--------|--------|--------|--------|    M    |             "
						.ascii		"|            -   Player 1 owns 5 squares from 1 to 5 on his/her side.\n"
						.ascii		"                       |---------|   10   |    9    |    8    |    7    |    6    |---------|             "
						.ascii		"|            -   Player 2 owns 5 squares from 6 to 10 on his/her side.\n\n"
						.ascii		"- If his/her side of the board is empty, he/she must use five previously-won pieces to place one piece in each square on his/her side before repeating the distribution.\n  "
						.ascii		"(If he/she do not possess any pieces, he/she must borrow a piece from the other player and return it when counting the points at the end of the game.)\n"
						.ascii		"* CAPTURING:\n- When the next square to be distributed is empty, the player wins all the pieces in the square after that.\n"
						.ascii		"- When the next square is an empty Mandarin square, or the next two squares are empty, it becomes the other player's turn.\n- In some game variations, "
						.asciiz		"the Mandarin square can contain little citizen pieces called Young Mandarin which may not be captured.\n------------------------------\nARE YOU READY??? LET'S START..."
	choose_square:		.asciiz		"Choose square to play (choose a number from 1 to 10):"
	player1_turn:		.asciiz		"Player 1 turn! Please choose a number from 1 to 5:"
	player2_turn:		.asciiz		"Player 2 turn! Please choose a number from 6 to 10:"
	choose_direction: 	.asciiz		"Choose 0 to go left, 1 to go right:"
	empty_block:		.asciiz		"Please do not choose empty block! Enter again:"
	invalid_input:		.asciiz		"Invalid input @@ Please enter again:"
	empty_soldier:		.asciiz		"Side is empty!!!\nPlace a soldier in each square on side by captured soldier!"
	borrow_soldier:		.asciiz		"Side is empty!!! Don't have enough soldiers @@\nBorrow soldiers from other player to fill side..."
	show_result1:		.asciiz		"No more soldier on the mandarin squares, the game is over"
	show_result2:		.asciiz		"Player 2 quits the game. Player 1 wins!"
	show_result3:		.asciiz		"Player 1 quits the game. Player 2 wins!"
	show_result4:		.asciiz		"Player quits the game. Bot wins!"
	scoreboard:			.ascii		"||===============SCOREBOARD===============||\n"
						.ascii		"         PLAYER 1: +00                                    BOT: +00\n"
						.asciiz		"                WIN                                                   WIN \n||==========================================||"
	choosemode:			.asciiz		"Please choose game mode:\n  - 0 to play PvP\n  - 1 to play PvE\n"
	choosebot:			.asciiz		"Please choose your oponent:\n  - 1 to play with Fred\n  - 2 to play with Evie\n"
	newline:			.asciiz		"\n"
	thanks_mess:		.asciiz		"Thank you for playing our game!"
	empty_soldier_fred:	.asciiz		"Fred's side is empty!!!\nPlacing a soldier in each square on his side by his captured soldier!"
	borrow_soldier_fred:.asciiz		"Fred's side is empty!!! He doesn't have enough soldiers @@\nBorrow soldiers from you to fill his side..."
	empty_soldier_evie:	.asciiz		"Evie's side is empty!!!\nPlacing a soldier in each square on his side by her captured soldier!"
	borrow_soldier_evie:.asciiz		"Evie's side is empty!!! She doesn't have enough soldiers @@\nBorrow soldiers from you to fill her side..."


# startmess: pop up welcome message
# return at $v0: -1 if choosing cancel, 0 if displaying rules, 1 to skipping
.macro	startmess
# reserve register
	subi	$sp, $sp, 8
	sw		$a0, 0($sp)
	sw		$a1, 4($sp)

	la 		$a0, welcome
	li 		$v0, 51

loop_start:
	syscall
	beq		$a1, 0, check_valid			# Ok status
	beq		$a1, -2, end_cancel			# Cancel was chosen
	la		$a0, invalid_input			# invalid input
	j		loop_start					# jump to loop_start
	

check_valid:							# Check 0 or 1
	beq		$a0, 0, end_start			# 0 for pop up rules
	beq		$a0, 1, end_start			# 1 for skip rules and start game
	la		$a0, invalid_input
	j		loop_start					# invalid input

end_cancel:
	addi	$a0, $zero, -1
end_start:
	addi	$v0, $a0, 0
# restore register
	lw 		$a0, 0($sp)
	lw		$a1, 4($sp)
	addi	$sp, $sp, 8
.end_macro


# displayRules: pop up rule_description
.macro	displayRules
# reserve register
	subi	$sp, $sp, 8
	sw		$a0, 0($sp)
	sw		$a1, 4($sp)

	la		$a0, rule_description
	la		$a1, 1
	li		$v0, 55
	syscall

# restore register
	lw 		$a0, 0($sp)
	lw		$a1, 4($sp)
	addi	$sp, $sp, 8
.end_macro

# displayRules: pop up rule_description
.macro thanks
# reserve register
	subi	$sp, $sp, 8
	sw		$a0, 0($sp)
	sw		$a1, 4($sp)

	la		$a0, thanks_mess
	la		$a1, 1
	li		$v0, 55
	syscall

# restore register
	lw 		$a0, 0($sp)
	lw		$a1, 4($sp)
	addi	$sp, $sp, 8
.end_macro

# player2fig: pop up window to obtain player2's choice
# board: address of board
# return direction in $v0 and chosen block in $v1
# if cancel was chosen, $v0 = -1
.macro	player2fig
# reserve register
	subi	$sp, $sp, 12
	sw		$a0, 0($sp)
	sw		$a1, 4($sp)
	sw		$t0, 8($sp)

# Choose block
	la		$a0, player2_turn
	li		$v0, 51
	j		Player2Loop

invalid_in:
	la		$a0, invalid_input

Player2Loop:
	syscall
	beq		$a1, 0, cont				# Ok status
	beq		$a1, -2, cancel_player2		# Cancel was chosen
	j		invalid_in					# Invalid input

cont:
	slti	$t0, $a0, 6
	beq		$t0, 1, invalid_in			# if ($a0 < 6) goto invalid_in
	slti	$t0, $a0, 11				# if ($a0 >= 11) goto invalid_in
	beq		$t0, 0, invalid_in

	addi	$v1, $a0, 1					# $v1 holds chosen block

# Test empty block
	sll		$t0, $v1, 2
	la		$a0, board
	add		$a0, $a0, $t0
	lw		$t0, 0($a0)
	bne		$t0, 0, not_empty
	la		$a0, empty_block
	j		Player2Loop

not_empty:
# Choose direction
	la		$a0, choose_direction		# $a0 holds direction
	syscall
	beq		$a1, -2, cancel_player2		# Cancel was chosen
	bne		$a1, 0, not_empty
	beq		$a0, 0, end_player2			# 0 for go left
	beq		$a0, 1, end_player2			# 1 for go right
	j		not_empty					# invalid choice

cancel_player2:
	addi	$a0, $zero, -1

end_player2:
# save to return register
	addi	$v0, $a0, 0
# restore register
	lw		$a0, 0($sp)
	lw		$a1, 4($sp)
	lw		$t0, 8($sp)
	addi	$sp, $sp, 12
.end_macro


# player1fig: pop up window to obtain player1's choice
# board: address of board
# return direction in $v0 and chosen block in $v1
# if cancel was chosen, $v0 = -1
.macro player1fig
# reserve register
	subi	$sp, $sp, 12
	sw		$a0, 0($sp)
	sw		$a1, 4($sp)
	sw		$t0, 8($sp)

# Choose block
	la		$a0, player1_turn
	li		$v0, 51
	j		Player1Loop

invalid_in:
	la		$a0, invalid_input

Player1Loop:
	syscall
	beq		$a1, 0, cont				# Ok status
	beq		$a1, -2, cancel_player1			# Cancel was chosen
	j		invalid_in					# Invalid input

cont:
	slti	$t0, $a0, 1
	beq		$t0, 1, invalid_in			# if ($a0 < 1) goto invalid_in
	slti	$t0, $a0, 6					# if ($a0 >= 5) goto invalid_in
	beq		$t0, 0, invalid_in

	addi	$v1, $a0, 0					# $v1 holds chosen block

# Test empty block
	sll		$t0, $v1, 2
	la		$a0, board
	add		$a0, $a0, $t0
	lw		$t0, 0($a0)
	bne		$t0, 0, not_empty
	la		$a0, empty_block
	j		Player1Loop

not_empty:
# Choose direction
	la		$a0, choose_direction		# $a0 holds direction
	syscall
	beq		$a1, -2, cancel_player1		# Cancel was chosen
	bne		$a1, 0, not_empty
	beq		$a0, 0, end_player1			# 0 for go left
	beq		$a0, 1, end_player1			# 1 for go right
	j		not_empty					# invalid choice

cancel_player1:
	addi	$a0, $zero, -1

end_player1:
# save to return register
	addi	$v0, $a0, 0
# restore register
	lw		$a0, 0($sp)
	lw		$a1, 4($sp)
	lw		$t0, 8($sp)
	addi	$sp, $sp, 12
.end_macro


# fill_side: pop up window about your side but you have enough soldiers to fill your side
.macro fill_side
# reserve register
	subi	$sp, $sp, 12
	sw		$a0, 0($sp)
	sw		$a1, 4($sp)
	sw		$v0, 8($sp)

	la		$a0, empty_soldier
	la		$a1, 2
	li		$v0, 55
	syscall

# restore register
	lw		$a0, 0($sp)
	lw		$a1, 4($sp)
	lw		$v0, 8($sp)
	addi	$sp, $sp, 12
.end_macro

# fill_side: pop up window about your side but you have enough soldiers to fill your side
.macro fill_side_fred
# reserve register
	subi	$sp, $sp, 12
	sw		$a0, 0($sp)
	sw		$a1, 4($sp)
	sw		$v0, 8($sp)

	la		$a0, empty_soldier_fred
	la		$a1, 2
	li		$v0, 55
	syscall

# restore register
	lw		$a0, 0($sp)
	lw		$a1, 4($sp)
	lw		$v0, 8($sp)
	addi	$sp, $sp, 12
.end_macro

# fill_side: pop up window about your side but you have enough soldiers to fill your side
.macro fill_side_evie
# reserve register
	subi	$sp, $sp, 12
	sw		$a0, 0($sp)
	sw		$a1, 4($sp)
	sw		$v0, 8($sp)

	la		$a0, empty_soldier_evie
	la		$a1, 2
	li		$v0, 55
	syscall

# restore register
	lw		$a0, 0($sp)
	lw		$a1, 4($sp)
	lw		$v0, 8($sp)
	addi	$sp, $sp, 12
.end_macro

# fill_side_borrow: pop up window about your empty side and borrow soldiers from opponents to refill your side
.macro fill_side_borrow
# reserve register
	subi	$sp, $sp, 12
	sw		$a0, 0($sp)
	sw		$a1, 4($sp)
	sw		$v0, 8($sp)

	la		$a0, borrow_soldier
	la		$a1, 2
	li		$v0, 55
	syscall

# restore register
	lw		$a0, 0($sp)
	lw		$a1, 4($sp)
	sw		$v0, 8($sp)
	addi	$sp, $sp, 12
.end_macro

# fill_side_borrow: pop up window about your empty side and borrow soldiers from opponents to refill your side
.macro fill_side_borrow_fred
# reserve register
	subi	$sp, $sp, 12
	sw		$a0, 0($sp)
	sw		$a1, 4($sp)
	sw		$v0, 8($sp)

	la		$a0, borrow_soldier_fred
	la		$a1, 2
	li		$v0, 55
	syscall

# restore register
	lw		$a0, 0($sp)
	lw		$a1, 4($sp)
	sw		$v0, 8($sp)
	addi	$sp, $sp, 12
.end_macro

# fill_side_borrow: pop up window about your empty side and borrow soldiers from opponents to refill your side
.macro fill_side_borrow_evie
# reserve register
	subi	$sp, $sp, 12
	sw		$a0, 0($sp)
	sw		$a1, 4($sp)
	sw		$v0, 8($sp)

	la		$a0, borrow_soldier_evie
	la		$a1, 2
	li		$v0, 55
	syscall

# restore register
	lw		$a0, 0($sp)
	lw		$a1, 4($sp)
	sw		$v0, 8($sp)
	addi	$sp, $sp, 12
.end_macro

# showResult: void MSCGame::showResult(State state)
# $st: 0 if normal pve ending, 1 if normal pvp ending, 2 if player2 quits, 3 if player1 quits, 4 if players quits in pve
.macro showResult(%st)
# Reserve register
	subi	$sp, $sp, 12
	sw		$a0, 0($sp) 
	sw		$a1, 4($sp)
	sw		$t0, 8($sp)

	addi	$t0, %st, 0
	beq		$t0, 1, end_normal
	beq		$t0, 2, player1_win
	beq		$t0, 3, player2_win
	beq		$t0, 4, bot_win
	
end_normal:
	la		$a0, show_result1
	j		pop_st
player1_win:
	la		$a0, show_result2
	j		pop_st
player2_win:
	la		$a0, show_result3
	j		pop_st
bot_win:
	la		$a0, show_result4
pop_st:
	li		$v0, 55
	li		$a1, 1
	syscall
	
	showScore

# restore register
	lw		$a0, 0($sp) 
	lw		$a1, 4($sp)
	lw		$t0, 8($sp)
	addi	$sp, $sp, 12
.end_macro


# showScore: Update score and result in scoreboard address
.macro showScore
# Reserve register
	subi	$sp, $sp, 24
	sw		$a0, 0($sp)
	sw		$a1, 4($sp)
	sw		$s0, 8($sp)
	sw		$s1, 12($sp)
	sw		$t1, 16($sp)
	sw		$t2, 20($sp)

# Calculate player1's score
	la		$a0, player1
	lw		$s0, 0($a0)
	lw		$a1, 4($a0)
	mul		$a1, $a1, 5
	add		$s0, $s0, $a1

# Calculate player2's score
	la		$a0, player2
	lw		$s1, 0($a0)
	lw		$a1, 4($a0)
	mul		$a1, $a1, 5
	add		$s1, $s1, $a1

	sub		$t2, $s0, $s1
	
# Update the score
	la		$a0, scoreboard
	addi	$a1, $zero, 10 

	bgez	$s0, continue_p1
	li		$t1, '-'
	sb		$t1, 64($a0)
	mul		$s0, $s0, -1
continue_p1:
	div		$s0, $a1		# Update player1's score
	mflo	$t1
	addi	$t1, $t1, '0'
	sb		$t1, 65($a0)
	mfhi	$t1
	addi	$t1, $t1, '0'
	sb		$t1, 66($a0)

	bgez	$s1, continue_p2
	li		$t1, '-'
	sb		$t1, 108($a0)
	mul		$s1, $s1, -1
continue_p2:
	div		$s1, $a1		# Update player2's score
	mflo	$t1
	addi	$t1, $t1, '0'
	sb		$t1, 109($a0)
	mfhi	$t1
	addi	$t1, $t1, '0'
	sb		$t1, 110($a0)

# Check status
	beq		$t0, 4, player2_win
	beq		$t0, 0, end_normal
	
	addi	$a1, $zero, 'P'
	sb		$a1, 98($a0)
	addi	$a1, $zero, 'L'
	sb		$a1, 99($a0)
	addi	$a1, $zero, 'A'
	sb		$a1, 100($a0)
	addi	$a1, $zero, 'Y'
	sb		$a1, 101($a0)
	addi	$a1, $zero, 'E'
	sb		$a1, 102($a0)
	addi	$a1, $zero, 'R'
	sb		$a1, 103($a0)
	addi	$a1, $zero, ' '
	sb		$a1, 104($a0)
	addi	$a1, $zero, '2'
	sb		$a1, 105($a0)

	beq		$t0, 2, player1_win
	beq		$t0, 3, player2_win
end_normal:
# Update result	(Default: WIN -WIN )
	beqz	$t2, draw_match
	bgtz	$t2, player1_win
player2_win: # (Update to LOSE-WIN )
	addi	$s0, $zero, 'L'
	sb		$s0, 128($a0)

	addi	$s0, $zero, 'O'
	sb		$s0, 129($a0)

	addi	$s0, $zero, 'S'
	sb		$s0, 130($a0)

	addi	$s0, $zero, 'E'
	sb		$s0, 131($a0)

	li		$v0, 55
	li		$a1, 4 
	syscall

	addi	$s0, $zero, 'W'
	sb		$s0, 128($a0)

	addi	$s0, $zero, 'I'
	sb		$s0, 129($a0)

	addi	$s0, $zero, 'N'
	sb		$s0, 130($a0)

	addi	$s0, $zero, ' '
	sb		$s0, 131($a0)

	j end_show

player1_win: # (Update to WIN -LOSE)
	addi	$s0, $zero, 'L'
	sb		$s0, 182($a0)

	addi	$s0, $zero, 'O'
	sb		$s0, 183($a0)

	addi	$s0, $zero, 'S'
	sb		$s0, 184($a0)

	addi	$s0, $zero, 'E'
	sb		$s0, 185($a0)

	li		$v0, 55
	li		$a1, 4 
	syscall

	addi	$s0, $zero, 'W'
	sb		$s0, 182($a0)

	addi	$s0, $zero, 'I'
	sb		$s0, 183($a0)

	addi	$s0, $zero, 'N'
	sb		$s0, 184($a0)

	addi	$s0, $zero, ' '
	sb		$s0, 185($a0)

	j		end_show
draw_match:  # (Update to DRAW-DRAW)
	addi	$s0, $zero, 'D'
	sb		$s0, 128($a0)
	sb		$s0, 182($a0)

	addi	$s0, $zero, 'R'
	sb		$s0, 129($a0)
	sb		$s0, 183($a0)

	addi	$s0, $zero, 'A'
	sb		$s0, 130($a0)
	sb		$s0, 184($a0)

	addi	$s0, $zero, 'W'
	sb		$s0, 131($a0)
	sb		$s0, 185($a0)

	li		$v0, 55
	li		$a1, 4 
	syscall

	addi	$s0, $zero, 'W'
	sb		$s0, 128($a0)
	sb		$s0, 182($a0)

	addi	$s0, $zero, 'I'
	sb		$s0, 129($a0)
	sb		$s0, 183($a0)

	addi	$s0, $zero, 'N'
	sb		$s0, 130($a0)
	sb		$s0, 184($a0)

	addi	$s0, $zero, ' '
	sb		$s0, 131($a0)
	sb		$s0, 185($a0)

end_show:
	li		$t1, '+'
	sb		$t1, 64($a0)
	sb		$t1, 108($a0)
	beq		$t0, 4, restore
	beq		$t0, 0, restore

	addi	$a1, $zero, ' '
	sb		$a1, 98($a0)
	sb		$a1, 99($a0)
	sb		$a1, 100($a0)
	sb		$a1, 101($a0)
	sb		$a1, 102($a0)
	addi	$a1, $zero, 'B'
	sb		$a1, 103($a0)
	addi	$a1, $zero, 'O'
	sb		$a1, 104($a0)
	addi	$a1, $zero, 'T'
	sb		$a1, 105($a0)
restore:
# restore register
	lw		$a0, 0($sp) 
	lw		$a1, 4($sp)
	lw		$s0, 8($sp)
	lw		$s1, 12($sp)
	lw		$t1, 16($sp)
	lw		$t2, 20($sp)
	addi	$sp, $sp, 24
.end_macro

# Choose mode to play
# return -1 if choosing cancel, 0 if choosing pvp, 1 if choosing pve 
.macro	choose_mode
# reserve register
	subi	$sp, $sp, 8
	sw		$a0, 0($sp)
	sw		$a1, 4($sp)

	la		$a0, choosemode
	li		$v0, 51

loop_mode:
	syscall
	beq		$a1, 0, check_valid			# Ok status
	beq		$a1, -2, end				# Cancel was chosen
	la		$a0, invalid_input			# invalid input
	j		loop_mode					# jump to loop_mode

check_valid:							# Check 0 or 1
	beq		$a0, 0, end_mode
	beq		$a0, 1, end_mode
	la		$a0, invalid_input
	j		loop_mode					# invalid input

end:
	addi	$a0, $zero, -1
end_mode:
	addi	$v0, $a0, 0

# restore register
	lw		$a0, 0($sp)
	lw		$a1, 4($sp)
	addi	$sp, $sp, 8
.end_macro

# Choose bot to play
# return -1 if choosing cancel, 1 if choosing fred, 2 if choosing evie
.macro	choose_bot
# reserve register
	subi	$sp, $sp, 8
	sw		$a0, 0($sp)
	sw		$a1, 4($sp)

	la		$a0, choosebot
	li		$v0, 51
loop_bot:
	syscall
	beq		$a1, 0, check_valid			# Ok status
	beq		$a1, -2, end				# Cancel was chosen
	la		$a0, invalid_input			# invalid input
	j		loop_bot					# jump to loop_bot

check_valid:							# Check 1 or 2
	beq		$a0, 1, end_bot
	beq		$a0, 2, end_bot
	la		$a0, invalid_input
	j		loop_bot					# invalid input

end:
	addi	$a0, $zero, -1
end_bot:
	addi	$v0, $a0, 0

# restore register
	lw		$a0, 0($sp)
	lw		$a1, 4($sp)
	addi	$sp, $sp, 8
.end_macro
