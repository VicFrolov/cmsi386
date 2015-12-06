%Name: Victor Frolov

/* Problem 1

Define a predicate duplist(L1,L2) that is true if L2 contains every
two copies of each element of L1.
*/

duplist([], []).
duplist(L1, L2) :-  L1 = [X | Xs], L2 = [X, X | Ys], duplist(Xs, Ys).


/* Problem 2 

Define a predicate sorted(L) that is true if L a list of numbers in increasing order.

*/


sorted([]).
sorted(L) :- L = [X , Y | Xs], X =< Y, sorted(Xs).

