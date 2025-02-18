initState(state([a,b,c],[],[])).
goalState(state([],[],[a,b,c])).

currentState(0, S) :- initState(S).
currentState(N, S) :- 
    currentState(N2, S2), 
    N is N2 + 1, 
    move(S2,S).

solve(I,G) :- move(I,G).
solve(I,G) :- move(I,I2), solve(I2,G).

move(state([H|T],C2,C3), state(T, [H|C2], C3)) :- is_okay([H|C2]).
move(state([H|T],C2,C3), state(T, C2, [H|C3])) :- is_okay([H|C3]).
move(state(C1,[H|T],C3), state(C1, T, [H|C3])) :- is_okay([H|C3]).
move(state(C1,[H|T],C3), state([H|C1], T, C3)) :- is_okay([H|C1]).
move(state(C1,C2, [H|T]), state([H|C1], C2, T)) :- is_okay([H|C1]).
move(state(C1,C2, [H|T]), state(C1, [H|C2], T)) :- is_okay([H|C2]).

is_okay([]).
is_okay([_]).
is_okay([X,Y|T]) :- 
    smaller(X,Y),
    is_okay([Y|T]).

smaller(a,b).
smaller(b,c).
smaller(a,c).

play_game :- goalState(G), currentState(_,G).

?- initState(I), goalState(G), solve(I,G).
