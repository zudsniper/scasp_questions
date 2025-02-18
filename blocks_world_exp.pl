%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE: blocks_world_scasp.pl
%% AUTHOR: @zudsniper (Jason)
%% 
%% PURPOSE:
%%   A small example of using s(CASP) to encode the Blocks World domain,
%%   with a bounded number of steps to find a plan that achieves a goal.
%% 
%% HOW TO RUN:
%%   1. Install s(CASP) per instructions.
%%   2. Run:  scasp blocks_world_scasp.pl
%%   3. Observe the generated models (each model encodes a valid plan).
%%   4. For an expanded justification tree, try:
%%         scasp --tree --long blocks_world_scasp.pl
%% 
%% NOTE: s(CASP) can enumerate partial models (plans), each showing which
%%       actions must occur at which time to reach the goal by the final step.
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. Domain Declarations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% List of blocks
block(a).
block(b).
block(c).

% Time steps in [0..2].  We will allow up to 3 states: t=0, t=1, t=2
time(0).
time(1).
time(2).

% The "successor" relation on time. This is used to move from step S to S+1.
succ(0,1).
succ(1,2).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2. Fluents and Representation of States
%% 
%% We will store conditions (fluents) with a predicate:
%%       holds( Fluent, Time )
%% meaning that at Time, the Fluent is true.  Example fluents:
%%    on(X,Y)      => block X is on block/table Y
%%    clear(X)     => block X has nothing on top of it
%%    handempty    => the robot hand is free
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% We also define an "occurs(Action, T)" predicate representing that
% an action occurs at time T.  We'll make 'occurs/2' abducible so that
% s(CASP) can "guess" which actions happen to achieve the goal.

#abducible occurs(Action, T).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3. Actions
%% 
%% We'll define two actions:
%%    pick_up(X)    => pick up block X (must be clear & on something)
%%    put_down(X,Y) => put block X on top of Y (must be holding X and Y clear)
%% In classical Blocks World, Y can be the table, treated as a special "block".
%% 
%% We'll encode the preconditions and the effects of each action on the next state.
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%
%% pick_up/1
%%%%%%%%%%%%%%%%%%%%
% PRECONDITIONS:
%   1) block X is clear
%   2) the robot hand is empty
%   3) X is on something (on(X, Something))
poss(pick_up(X), S) :-
    holds(clear(X), S),
    holds(handempty, S),
    holds(on(X,_Something), S).  % _Something can be either block or 'table'

% EFFECTS:
%   1) no longer on(X, _Something) at S+1
%   2) not clear(X) or on something at S+1 => replaced by holding(X)
%   3) _Something becomes clear if X was on a block
%   4) The hand is no longer empty
holds(on(X,Something), S1) :-
    occurs(pick_up(X), S),
    succ(S,S1),
    % This next line says: we keep on(X,Something) in S1 if we do NOT pick it up.
    % i.e. frame axiom to keep old on/2 unless the action used it.
    not rewrote_on_pick(X,Something,S).

% A helper to specify rewriting of on(X,Something):
rewrote_on_pick(X,Something,S) :-
    occurs(pick_up(X), S),
    holds(on(X,Something), S).  % so in next state we drop that fact

% The block X is "held" after picking it up
holds(holding(X), S1) :-
    occurs(pick_up(X), S),
    succ(S,S1).

% The hand is not empty after picking up X
% we represent that the old "handempty" is gone
holds(handempty, S1) :-
    holds(handempty, S),    % by default, we keep it
    succ(S,S1),
    not used_hand(S).       % but if we used it to pick/put, it disappears

used_hand(S) :- occurs(pick_up(_),S).
used_hand(S) :- occurs(put_down(_,_),S).

% If we pick up X from block Y, then Y becomes clear in S+1 
holds(clear(Y), S1) :-
    occurs(pick_up(X), S),
    succ(S,S1),
    holds(on(X,Y), S),  % X was on Y
    block(Y).           % Y is a block, not the table

% If we pick up X from the table, no "clear(table)" needed. It's optional.

%%%%%%%%%%%%%%%%%%%%
%% put_down/2
%%%%%%%%%%%%%%%%%%%%
% PRECONDITIONS:
%   1) block X is being held
%   2) block Y is clear
%   3) X != Y (cannot put a block on itself)
poss(put_down(X, Y), S) :-
    holds(holding(X), S),
    holds(clear(Y),   S),
    X \= Y.

% EFFECTS:
%   1) X is now on Y
%   2) X is no longer held
%   3) Y is no longer clear
%   4) The robot hand is empty
%   5) The old "on(X, ...)" or "holding(X)" from previous time might vanish
%      (we rely on the frame axioms plus rewrite helper rules).
holds(on(X,Y), S1) :-
    occurs(put_down(X,Y), S),
    succ(S,S1).

% Keep "on(U,V)" from previous state if not changed by an action
holds(on(U,V), S1) :-
    holds(on(U,V), S),
    succ(S,S1),
    not rewrote_on_put(U,V,S).

rewrote_on_put(X,_Y,S) :- occurs(put_down(X,_Y),S).  % means old on(X,_) is replaced

% If we put X onto Y, X is no longer "holding"
holds(holding(X), S1) :-
    holds(holding(X), S),
    succ(S,S1),
    not used_hand(S).  % if used in put_down, we remove it

% Y becomes not clear after we put X onto Y
holds(clear(Y), S1) :-
    holds(clear(Y), S),
    succ(S,S1),
    not blocked_top(Y,S).

blocked_top(Y,S) :-
    occurs(put_down(_X,Y), S).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4. Frame axioms for anything else:
%%    - If a fluent F was true at time S, it remains true at S+1 unless
%%      an action specifically changes it.
%% 
%%    We'll write a catch-all for "holds(F, S1) if holds(F, S) and
%%    that fluent is not undone by an action".
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% A "catch-all" for preserving any holds(F, S)->S+1, if not undone:
holds(F, S1) :-
    holds(F, S),
    succ(S,S1),
    not changed(F,S).

changed(F,S) :- 
    occurs(A,S),
    undoes(A,F,S).

% By default, no action undoes any fluent, unless we specify e.g. rewrote_on_pick/3,
% rewrote_on_put/3, etc. in specialized rules. 
% Additional logic might be placed in 'undoes/3' if desired.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 5. Initial State
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% At time 0:
holds(on(a, table), 0).
holds(on(b, table), 0).
holds(on(c, a),     0).
holds(clear(b),     0).
holds(clear(c),     0).
holds(handempty,    0).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 6. Goal
%%
%% We want a plan that ends with block c on top of block b by or before time=2.
%% Let's define a small helper "goal_reached" that is true if
%% there exists T in [0..2] s.t. holds(on(c,b), T).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

goal_reached :-
    time(T),  % T in {0,1,2}
    holds(on(c,b), T).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 7. Integrity Constraint:  We only want stable models
%%    that achieve the goal.  So we say "it is a contradiction if
%%    the goal is never reached." 
%%
%% That is: ":- not goal_reached." in ASP style means we kill models
%% that do not satisfy 'goal_reached'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- not goal_reached.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 8. Sample Query
%%
%% You can either put a query here (so that running scasp in batch mode
%% tries to solve it), or just enter the query in interactive mode.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

?- goal_reached.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% END OF FILE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
