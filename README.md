# Mandarin Square Capturing in Mips
Mandarin Square Capturing is traditional Vietnamese children's board game. This is a simple MIPS implementation we did for assignment. Enjoy the game with your friends or you can play with our bot :D.

We hope this will take you back to your childhood.

# Team Information
1. Trần Trung Thái
2. Lê Xuân Huy
3. Lâm Phạm Trọng Phúc
4. Trần Hoàng Nhật Huy

# Game rules
- Please add all files with tail ".asm" to play game.

SET UP
- Each player places one big stone or five small stones (called the "Mandarin piece") in the Mandarin square as well as five small stones (called "citizen pieces") in each of the rice field squares.

OBJECTIVE
- The game ends when all the pieces are captured.
- If both Mandarin are captured, then the remaining pieces belong to the player controlling the side that the pieces are on. This is sometimes expressed by saying "Mandarin is gone, citizen dismisses, take back the army, selling the rice field''
- Whichever player has more pieces is the winner (a Mandarin piece is equal to ten or five citizen pieces).

SCATTERING
- The first player takes up all the pieces of any rice field square on his/her side of the board and distribute one piece per square, starting at the next square in either direction. When all pieces are distributed, the player repeats by taking up the pieces of the following and distributing them.
- If his/her of the board is empty, he/she must use five previous-won pieces to place one piece in each square on his/her side before repeating. If he/she does not have enough pieces, he/she must borrow a piece from the other player and return it when counting the points at the end of the game.

CAPTURING
- When the next square to be distributed is empty, the player wins all the pieces in the square after that. A square that contains a lot of pieces is the rich square.
- When the next square is an empty Mandarin square, or the next two squares are empty, it becomes the other players' turn.
- In some game variations, the Mandarin square that contains little citizen pieces called young Mandarin. In this case we can't capture this square.

# To play
- You should have installed Mars4_5.jar or any version of Mars mips to compile our game.
- If you have already had Mars mips, download all our file and run the file main.asm
- Remember to open Bitmap display in Tools/Bitmap Display and setting as the instruction below, connect it to mips and run main.asm, now you can enjoy your game.

# Bitmap display
Some bitmap settings will be required for this game.
- Unit Width in Pixels: 4

- Unit Height in Pixels: 4

- Display Width in Pixels: 1024

- Display Height in Pixels: 512

- Base address: 0x10040000 (heap)
