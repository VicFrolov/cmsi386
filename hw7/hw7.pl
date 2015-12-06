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
sorted([_]) :- sorted([]).
sorted([X , Y |  Xs]) :- X =< Y, sorted([Y | Xs]).


/* Problem 3

Define a predicate perm(L1,L2) that is true if L2 is a permutation of L1.

Use the predicate select(X,L1,L2) that is true if L2 can be obtained
by removing one occurrence of X from L1.

$- select(1, [1,2,3], [2,3]).
true.

?- select(1, [1,2,1,3], [1,2,3]).
true.

Hint: By running select backwards, we can insert 1 into different
positions of [a,b,c]:

L1 = [a,b,c]

L2 = [b,a,c]


select()




?- select(1, X, [a,b,c]).
X = [1, a, b, c] ;
X = [a, 1, b, c] ;
X = [a, b, 1, c] ;
X = [a, b, c, 1] ;
false.

Use sorted and perm to define a predicate permsort(L1,L2) that
is true if L2 is a sorted permutation of L1.

*/


/*perm(L1, L1).

perm(L1, L2) :- L2 = L1 = [X | Xs].*/

/*Problem 4 */


insert([], [], []).

insert(X, [Y | Ys], [X, Y | Ys]) :-  X =< Y.

insert(X, [Y | LRest], [Y | L2Rest]) :-  insert(X, LRest, L2Rest).












