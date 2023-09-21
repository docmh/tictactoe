# TicTacToe

Tic Tac Toe or Three in a Row in GNU-Prolog, none, one, or both players can be robots. 

Just learned PROLOG and wrote this little program as a learning project. Feel free to enhance the code. 

# Gameplay

Start the game with `go(Robots).`, where `Robots` is a list. First player has symbol `X`, second player has symbol `O`. You have these options: 

- `go([]).` when both players should be human users.
- `go(['X']).` when first player should be a robot.
- `go(['O']).` when second player should be a robot.
- `go(['X', 'O'].` when both players should be robots.

If you are a human player and have to make a move, just enter the number of a free field from the board, displayed to you. 
