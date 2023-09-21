% three in a row, column or diagonal win
player_wins(Player) :- 
    sublist([1, 2, 3], Player);
    sublist([4, 5, 6], Player);
    sublist([7, 8, 9], Player);
    sublist([1, 4, 7], Player);
    sublist([2, 5, 8], Player);
    sublist([3, 6, 9], Player);
    sublist([1, 5, 9], Player);
    sublist([3, 5, 7], Player).

% draw, when there are no free fields left
is_draw(Free) :- 
    length(Free, Len), 
    Len == 0.

% claim is allowed, when it is a free field
claim_allowed(Claim, Free) :- 
    member(Claim, Free).

% claim a field, update current player and free fields
claim_field(Claim, Player, Free, PlayerUpdated, FreeUpdated) :- 
    append(Player, [Claim], PlayerTemporary),
    sort(PlayerTemporary, PlayerUpdated),
    delete(Free, Claim, FreeUpdated).

% toggle current player and symbol
toggle_player(CurrentPlayer1, CurrentPlayer2, NewPlayer1, NewPlayer2, CurrentSymbol1, NewSymbol1) :- 
    NewPlayer1 = CurrentPlayer2,
    NewPlayer2 = CurrentPlayer1, 
    (CurrentSymbol1 == 'X' -> NewSymbol1 = 'O' ; NewSymbol1 = 'X').

% display current state of the board
display_board(Board) :- 
    nth(1, Board, X1), nth(2, Board, X2), nth(3, Board, X3),
    nth(4, Board, X4), nth(5, Board, X5), nth(6, Board, X6),
    nth(7, Board, X7), nth(8, Board, X8), nth(9, Board, X9),
    format('~n ~w | ~w | ~w~n', [X1, X2, X3]),
    format('---+---+---~n', []),
    format(' ~w | ~w | ~w~n', [X4, X5, X6]),
    format('---+---+---~n', []),
    format(' ~w | ~w | ~w~2n', [X7, X8, X9]).

% update board by adding current player's move,
% indicated by their symbol, to the board; 
% free fields are represented by their number
update_board(Player1, Player2, Symbol1, Board, N) :- 
    N == 10 -> display_board(Board);
    (Symbol1 == 'X' -> Symbol2 = 'O' ; Symbol2 = 'X'),
    (
        member(N, Player1) -> append(Board, [Symbol1], BoardA);
        member(N, Player2) -> append(Board, [Symbol2], BoardA);
        append(Board, [N], BoardA)
    ), 
    M is N + 1,
    update_board(Player1, Player2, Symbol1, BoardA, M).

% claims that free field, which completes a three in a row,
% given two already claimed fields
claim_win(XSource, YSource, Free, Claim) :-
    member(X, XSource), 
    member(Y, YSource),
    member(Z, Free),
    X \= Y, Y \= Z, X \= Z,
    sort([X, Y, Z], [A, B, C]),
    player_wins([A, B, C]),
    Claim = Z.

claim_center(Free, Claim) :- 
    member(5, Free), Claim = 5. % claim center field if free

claim_from_subset(Player, Free, SubsetFree, Claim) :-
    append(Player, Free, PlayerFree),
    claim_win(PlayerFree, Player, SubsetFree, Claim).

claim_possible_win(Player1, Player2, Free, SubsetFree, Claim) :-
    claim_from_subset(Player1, Free, SubsetFree, Claim); % claim a field (corner or side) for a possible win of the current player
    claim_from_subset(Player2, Free, SubsetFree, Claim). % claim a field (corner or side) to prevent a possible win of the other player

claim_corner(Player1, Player2, Free, Claim) :- 
    subtract(Free, [2, 4, 6, 8], Corners), % subtract free corner fields
    claim_possible_win(Player1, Player2, Free, Corners, Claim).

claim_side(Player1, Player2, Free, Claim) :- 
    subtract(Free, [1, 3, 7, 9], Sides), % subtract free side fields
    claim_possible_win(Player1, Player2, Free, Sides, Claim).
    
claim_strategically(Player1, Player2, Free, Claim) :-
    claim_center(Free, Claim);                      % up to four options to win on the center field
    claim_corner(Player1, Player2, Free, Claim);    % up to three options to win on a corner field 
    claim_side(Player1, Player2, Free, Claim);      % up to two options to win on a side field 
    member(Claim, Free).                            % no option to win, claim any free field

calculate_claim(Player1, Player2, Free, Claim) :-
    claim_win(Player1, Player1, Free, Claim);           % Current player wins
    claim_win(Player2, Player2, Free, Claim);           % Other player could win, defend
    claim_strategically(Player1, Player2, Free, Claim). % Claim a strategically beneficial free field

% if current player is a robot, calculate claim, else read claim from user input
retrieve_claim(Player1, Player2, Free, Symbol1, Robots, Claim) :-
    member(Symbol1, Robots) -> (
        calculate_claim(Player1, Player2, Free, Claim), 
        format('Player ~w chooses field: ~w.~n', [Symbol1, Claim])
    ) ; (
        format('Player ~w, please choose a field: ', [Symbol1]),
        read(Claim)
    ).
 
play_move(Player1, Player2, Free, Symbol1, Robots) :-
    retrieve_claim(Player1, Player2, Free, Symbol1, Robots, Claim), % read (human) or calculate (robot) claim
    claim_allowed(Claim, Free) -> ( 
        % valid move, claim field, update board and continue game
        claim_field(Claim, Player1, Free, Player1Updated, FreeUpdated), 
        update_board(Player1Updated, Player2, Symbol1, Board, 1), 
        (
            player_wins(Player1Updated) -> format('~2nPlayer ~w has won!~2n', [Symbol1]);   % game ends when current player wins
            is_draw(FreeUpdated) -> format('~2nYou played a draw!~2n', []);                 % game ends when there are no free fields left (draw)
            (
                % game continues, let other player make a move
                toggle_player(Player1Updated, Player2, NewPlayer1, NewPlayer2, Symbol1, NewSymbol1),
                play_move(NewPlayer1, NewPlayer2, FreeUpdated, NewSymbol1, Robots)
            )
        )
    ) ; ( 
        % invalid move, try again
        format('~2nPlayer ~w, this was an invalid move!~2n', [Symbol1]),
        play_move(Player1, Player2, Free, Symbol1, Robots)
    ).

% initiate and start game
% if Robots-list includes 'X' or 'O' (or both), the corresponding player is a robot
go(Robots) :- 
    format('Welcome to Tic Tac Toe!~n', []),
    Symbol1 = 'X', 
    Player1 = [], 
    Player2 = [],
    Free = [1, 2, 3, 4, 5, 6, 7, 8, 9],
    update_board(Player1, Player2, Symbol1, Board, 1), 
    play_move(Player1, Player2, Free, Symbol1, Robots).