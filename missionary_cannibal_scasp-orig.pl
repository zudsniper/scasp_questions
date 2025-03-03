%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Missionaries and Cannibals in s(CASP)
% A "Known Good" version that should compile cleanly
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%
% Initial / Goal States
%%%%%%%%%%%%%%%%%%%%%%%%
initState(state(3,3,0,0,left)).
goalState(state(0,0,3,3,right)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BFS-style enumerated states
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
currentState(0, S) :-
    initState(S).

currentState(N, S) :-
    currentState(N2, S2),
    N is N2 + 1,
    move(S2, S).

%%%%%%%%%%%%%%%%%%%%
% DFS-style approach
%%%%%%%%%%%%%%%%%%%%
solve(I, G) :-
    move(I, G).

solve(I, G) :-
    move(I, I2),
    solve(I2, G).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Moves: move boat left->right or right->left with up to 2 people
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Boat on left, load M missionaries + C cannibals, cross to right
move(state(ML,CL,MR,CR,left),
     state(ML2,CL2,MR2,CR2,right)) :-
    boat(M,C),
    ML2 is (ML - M),
    CL2 is (CL - C),
    MR2 is (MR + M),
    CR2 is (CR + C),
    is_okay(ML2,CL2),
    is_okay(MR2,CR2).

% Boat on right, load M missionaries + C cannibals, cross to left
move(state(ML,CL,MR,CR,right),
     state(ML2,CL2,MR2,CR2,left)) :-
    boat(M,C),
    MR2 is (MR - M),
    CR2 is (CR - C),
    ML2 is (ML + M),
    CL2 is (CL + C),
    is_okay(ML2,CL2),
    is_okay(MR2,CR2).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% boat/2 - valid ways to put up to 2 people on boat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
boat(1,0).  % 1 missionary
boat(2,0).  % 2 missionaries
boat(0,1).  % 1 cannibal
boat(0,2).  % 2 cannibals
boat(1,1).  % 1 missionary + 1 cannibal

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Safety constraint: never outnumber M by C
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
is_okay(0, 0).
is_okay(1, 0).
is_okay(2, 0).
is_okay(3, 0).
is_okay(0, 1).
is_okay(0, 2).
is_okay(0, 3).
is_okay(1, 1).
is_okay(2, 2).
is_okay(3, 3).
is_okay(1, 2).
is_okay(1, 3).
is_okay(2, 1).
is_okay(3, 1).
is_okay(2, 3).
is_okay(3, 2).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Optional "play_game" BFS query
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
play_game :-
    goalState(G),
    currentState(_, G).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Usage Examples:
%
%   ?- initState(I), goalState(G), solve(I, G).
%
%   ?- play_game.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
