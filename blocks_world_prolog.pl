% Block world definitions, we can add the six blocks (a, b, c, d, e, f) and the table (t)
block(X) :- 
    member(X, [a, b, c, d]).


% Define the initial state
start([
    on(a, b),
    on(b, t),
    on(d, t),
    on(c, d),
    clear(a),
    clear(c)
]).

% Define the goal state
goal([
    on(d, a),
    on(a, c),
    on(c, b),
    on(b, t),
    clear(a)
]).

/*
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


% Main predicate for IDS, exploring depths up to the given limit
ids(Limit, Plan) :-
    % Define start and goal states
    start(Start0),
    goal(Goal0),
    % Convert states to ordered sets for easier manipulation
    list_to_ord_set(Start0, Start),
    list_to_ord_set(Goal0, Goal),
    % Incrementally explore depths from 0 to Limit
    between(0, Limit, Len),
    write('Trying depth: '), write(Len), nl,
    % Define the length of the plan corresponding to the depth
    length(Plan, Len),
    % Call Depth-First Search (DFS)
    dfs(Start, Goal, [Start], Plan).

% Base case: if the current state matches the goal state, the plan is complete
dfs(State, State, _Visited, Plan) :-
    !,
    Plan = [],
    write('Goal reached with state: '), write(State), nl.

% Recursive case: explore possible actions from the current state
dfs(State, Goal, Visited, [Action | Actions]) :-
    write('Current state: '), write(State), nl,
    write('Visited: '), write(Visited), nl,
    % Find a valid action to transition to the next state
    action(Action, State, Next),
    write('Action taken: '), write(Action), nl,
    write('Next state: '), write(Next), nl,
    % Ensure the next state has not been visited
    not(member(Next, Visited)),
    % Continue DFS with the new state
    dfs(Next, Goal, [Next | Visited], Actions).


% Action: move block X from Y to Z
action(move(X, Y, Z), S1, S3) :-
    % Preconditions for the action
    member(clear(X), S1),
    member(on(X, Y), S1),
    block(Y),
    member(clear(Z), S1),
    X \= Z,
    % Update state by removing and adding relevant facts
    ord_subtract(S1, [clear(Z), on(X, Y)], S2),
    ord_union([clear(Y), on(X, Z)], S2, S3).

% Action: move block X from Y onto the table
action(move_onto_table(X, Y), S1, S3) :-
    % Preconditions for the action
    member(clear(X), S1),
    member(on(X, Y), S1),
    block(Y),
    % Update state by removing and adding relevant facts
    ord_subtract(S1, [on(X, Y)], S2),
    ord_union([clear(Y), on(X, t)], S2, S3).

% Action: move block X from the table onto block Y
action(move_onto_block(X, Y), S1, S3) :-
    % Preconditions for the action
    member(clear(X), S1),
    member(clear(Y), S1),
    member(on(X, t), S1),
    X \= Y,
    % Update state by removing and adding relevant facts
    ord_subtract(S1, [clear(Y), on(X, t)], S2),
    ord_union([on(X, Y)], S2, S3).