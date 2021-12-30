.include "draw.asm"
.include "dialog.asm"
.include "play.asm"
.include "number.asm"
.include "bot.asm"
.data
board:          .word       5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5
player1:        .word       0, 0, 0         # soldiers, mandarins, loans
player2:        .word       0, 0, 0         # soldiers, mandarins, loans
mandarins:      .word       0, 0            # status, status (0 - on the table, 1/2 on player 1/2)

.text
main:
start_game:
		get_ready
		draw_background
		startmess
		li		$t0, -1
		beq		$t0, $v0, end
		beqz	$v0, display_rules
		li		$t0, 1
		beq		$t0, $v0, start_play
display_rules:
		displayRules
start_play:
		choose_mode
		# if cancel
		li		$t0, -1
		beq		$v0, $t0, end
		# PvP
		beqz	$v0, pvp_mode
pve_mode:
		choose_bot
		beq	$v0, -1, end
		beq	$v0, 2, evie_game
		play_vs_fred
		j		continue_play
evie_game:
		play_vs_evie
		j		continue_play
pvp_mode:
		play_pvp
continue_play:
		j		start_game
end:	
		thanks
		addiu	$v0, $zero, 10
		syscall
