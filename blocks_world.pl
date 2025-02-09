:- use_module(library(scasp)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: blocks_world.pl
% Example: s(CASP) version of a small Blocks World solver
%          using Iterative Deepening Search (IDS).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- use_module(library(lists), [member/2, length/2, subtract/3]).
:- use_module(library(sort),  [sort/2]).  % Provides 'sort/2' which we can use for ord_* ops

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Basic domain definitions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% We have four blocks (a, b, c, d), plus a 'table' symbol t.
block(X) :- member(X, [a, b, c, d]).

% If you really need a predicate for the table, rename it:
% table_is(t).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Example initial (start) and goal states
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start([
    on(a, b),
    on(b, t),
    on(d, t),
    on(c, d),
    clear(a),
    clear(c)
]).
/*
Start State:      
    c            
    d     a      
    _____ b ___  
   |    table   |
   +===========+

*/

goal([
    on(d, a),
    on(a, c),
    on(c, b),
    on(b, t),
    clear(a)
]).
/*
Goal State:
    d
    a
    c
    b     
    ___________  
   |   table   |
   +===========+

*/

/*
  You can switch to one of these alternate pairs if you like:

start([
    on(a, b),
    on(b, c),
    on(c, t),
    on(d, t),
    clear(a),
    clear(d)
]).
goal([
    on(d, c),
    on(c, b),
    on(b, a),
    on(a, t),
    clear(d)
]).

start([
    on(a, t),
    on(b, a),
    on(c, b),
    on(d, t),
    clear(c),
    clear(d)
]).
goal([
    on(c, d),
    on(d, b),
    on(b, a),
    on(a, t),
    clear(c)
]).
*/

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. Utility to emulate 'ord' operations:
%    list_to_ord_set/2, ord_subtract/3, ord_union/3
%    (In Ciao, sort/2 is built in. Then we define subtract, union.)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

list_to_ord_set(L, S) :- sort(L, S).

ord_subtract(Set, Remove, Result) :-
    subtract(Set, Remove, Temp),
    sort(Temp, Result).

ord_union(Extra, Set, Union) :-
    append(Extra, Set, All),
    sort(All, Union).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4. Iterative Deepening Search
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ids(Limit, Plan) :-
    start(S0), list_to_ord_set(S0, Start),
    goal(G0),  list_to_ord_set(G0, Goal),
    between(0, Limit, Depth),
    length(Plan, Depth),
    dfs(Start, Goal, [Start], Plan),
    !.  % Stop once we find a plan up to 'Depth'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 5. Depth-limited DFS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If current State == Goal, done
dfs(State, State, Visited2, []) :- 
    !.

% Otherwise, pick an Action from State -> Next, then recurse
dfs(State, Goal, Visited, [Action | More]) :-
    action(Action, State, Next),
    not member(Next, Visited),
    dfs(Next, Goal, [Next | Visited], More).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 6. Actions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Move block X from Y onto Z
action(move(X, Y, Z), S1, S3) :-
    member(clear(X), S1),
    member(on(X, Y), S1),
    block(Y),           % Y is a block
    member(clear(Z), S1),
    X \= Z,
    ord_subtract(S1, [clear(Z), on(X, Y)], Tmp),
    ord_union([clear(Y), on(X, Z)], Tmp, S3).

% Move block X from Y onto the table
action(move_onto_table(X, Y), S1, S3) :-
    member(clear(X), S1),
    member(on(X, Y), S1),
    block(Y),
    ord_subtract(S1, [on(X, Y)], Tmp),
    ord_union([clear(Y), on(X, t)], Tmp, S3).

% Move X from table onto block Y
action(move_onto_block(X, Y), S1, S3) :-
    member(clear(X), S1),
    member(clear(Y), S1),
    member(on(X, t), S1),
    X \= Y,
    ord_subtract(S1, [clear(Y), on(X, t)], Tmp),
    ord_union([on(X, Y)], Tmp, S3).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 7. Example usage:
%
%   scasp --interactive blocks_world.pl
%   ?- ids(5,Plan).
%
% You can adjust the '5' or the domain as desired.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
