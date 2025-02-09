% Ensure s(CASP) is used
:- use_module(library(scasp)).
% ------------------------------
% GRAPH DEFINITIONS
% ------------------------------

% Define possible colors
color(red).
color(blue).
color(green).

% Define nodes in the graph
node(a).
node(b).
node(c).
node(d).

% Define edges between nodes
edge(a, b).
edge(a, c).
edge(a, d).
edge(b, c).
edge(c, d).


% Graph: 
%     a -------- b
%     | \        |
%     |  \       |
%     |   \      |
%     |    \     |
%     |     \    |
%     |      \   |
%     |       \  |
%     |        \ |
%     c -------- d

% % ------------------------------
% GRAPH COLORING RULES
% ------------------------------

% Assign colors to nodes
color(N, C) :- node(N), color(C), not other_color(N, C), not same_as_neighbors(N, C).

% Ensure adjacent nodes do not have the same color
same_as_neighbors(N, C) :- edge(N, N2), color(N2, C).

% Ensure a node does not have multiple colors
other_color(N, C) :- color(C), color(C2), C \= C2, color(N, C2).

% Global constraint to detect violations
global_constraint_violated :- same_as_neighbors(N, C).

% ------------------------------
% TEST CASES
% ------------------------------

% Test if a node is assigned a color
% test_color_assigned(N, C) :-
%     node(N),
%     color(N, C),
%     write('Node '), write(N), write(' is assigned color '), write(C), nl.

% % Test if adjacent nodes have different colors
% test_adjacent_nodes_different(N1, N2, C1, C2) :-
%     edge(N1, N2),
%     color(N1, C1),
%     color(N2, C2),
%     C1 \= C2,
%     write('Nodes '), write(N1), write(' and '), write(N2), write(' have different colors ('), write(C1), write(', '), write(C2), write(')'), nl.

% Print assigned colors for all nodes
% print_assigned_colors :-
%     node(N),
%     color(N, C),
%     write('Node '), write(N), write(' is assigned color '), write(C), nl, 
%     fail.
% print_assigned_colors.

% % ------------------------------
% % RUNNING THE TESTS
% % ------------------------------

% ?- print_assigned_colors.
% ?- test_color_assigned(a, C).
% ?- test_color_assigned(b, C).
% ?- test_color_assigned(c, C).
% ?- test_color_assigned(d, C).

% ?- test_adjacent_nodes_different(a, b, C1, C2).
% ?- test_adjacent_nodes_different(a, c, C1, C2).
% ?- test_adjacent_nodes_different(b, c, C1, C2).
% ?- test_adjacent_nodes_different(c, d, C1, C2).

?- color(a, C).
?- color(b, C).
?- color(c, C).
?- color(d, C).