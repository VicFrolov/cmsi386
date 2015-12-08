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

Implement permsort using perm and sorted.

*/


perm([], []).
perm([X], [X]).
perm(L1, [X | Xs]) :- select(X, L1, Ls), perm(Ls, Xs).

permsort([], []).
permsort([X], [X]).
permsort(L1, L2) :- perm(L1, L2), sorted(L2).


/* Problem 4 



*/


insert([], L1, L1 ).
insert( X, [], [X] ).

insert( X, [Y | Rest], [X, Y | Rest] ) :- X =< Y.

insert( X, [Y | Rest], [Y | Rest2] ) :- insert(X, Rest, Rest2), Y =< X.

insertV2( [], L1, L1 ).
insertV2( X, [], [X] ).
insertV2( X, L1, L2 ) :- sorted( L1 ), select( X, L2 , L1 ), sorted( L2 ).



helper([], Acc, Acc).
helper([X | Xs], Acc, Sorted) :- insert(X, Acc, NewAcc), helper(Xs, NewAcc, Sorted).
insort( L1, L2 ) :- helper(L1, [], L2).

%L2 is sorted, and a perm of L1.
%ie L1 = [4,3,2,1], L2 = [1,2,3,4]
%insert(3, [2,1,5,4], [2,1,3,5,4]).


/* Problem 5

Compare the time it takes prolog to find 1 solution for each of:

?- permsort([5,3,6,2,7,4,5,4,1,2,8,6],L).

vs 

?- insort([5,3,6,2,7,4,5,4,1,2,8,6],L).

Which is faster? Why?

*/

performWOrld(world([], [], [], none), [], world([], [], []) ).

perform(Start, Action, Goal) :- Start = world(S1, S2, S3, H), Goal = world(SS1, SS2, SS3, H1), Action = V.
blocksworld(Start, Actions, Goal) :- Start = world(S1, S2, S3, H), Actions = V, Goal = world(SS1, SS2, SS3, H1).
world(S1, S2, S3, H).
pickup(S).
putdown(S).



/* Problem 6 

In this problem, you will write a Prolog program to solve a form of
the "blocks world" problem, which is a famous planning problem from
artificial intelligence.  Imagine you have three stacks of blocks in a
particular configuration, and the goal is to move blocks around so
that the three stacks end up in some other configuration.  You have a
robot that knows how to do two kinds of actions.  First, the robot can
pick up the top block from a stack, as long as that stack is nonempty
and the robot's mechanical hand is free.  Second, the robot can place
a block from its hand on to a stack.


Implement a predicate blocksworld(Start, Actions, Goal). Start and
Goal are lists describing configurations (states) of the world, and
Actions is a list of actions. blocksworld(Start, Actions, Goal) should
be true if the robot can move from the Start state to the Goal state
by following the list of Actions.

We will represent blocks as single-letter atoms like a,b,c, etc.

We will represent a world as a relation world(S1,S2,S3,H) that has
four components: three lists of blocks S1, S2, and S2 that represent
the three stacks, and a component H that represents the contents of
the mechanical hand.  That last component H either contains a single
block or the atom none, to represent the fact that the hand is empty.

Some example configurations of the world:

  world([a,b,c],[],[d],none)   
    - The first stack contains blocks a,b,c (a is at the top).
    - The second stack is empty.
    - The third stack contains the block d.
    - The hand is empty.

  world([],[],[],a)
    - The stacks are all empty.
    - The hand contains the block a.

There are two kinds of actions: pickup(S) and putdown(S). In each
action, S must be one of the atoms stack1, stack2, or stack3, which
identifies which stack to pickup from or putdown to. For example,
pickup(stack1) instructs the robot to pickup from stack1, and
putdown(stack2) instructs it to put down the currently held block on stack2.

First define a predicate perform(Start,Action,Goal), which defines the
effect of a single action on the configuration.  Use this to define
the predicate blocksworld(Start, Actions, Goal).

Once you've defined perform and blocksworld, you can ask for the
solutions:

?- length(Actions,L), blocksworld(world([a,b,c],[],[],none), Actions, world([],[],[a,b,c],none)).

Actions = [pickup(stack1),putdown(stack2),pickup(stack1),putdown(stack2),pickup(stack1),putdown(stack3),pickup(stack2),putdown(stack3),pickup(stack2),putdown(stack3)]
L = 10 ?

Notice how I use length to limit the size of the resulting list of
actions. The effect of this is that Prolog will search for a solution
consisting of 0 actions, then 1 action, then 2 actions, etc.  This is
necessary to do when you test your code, in order to prevent Prolog
from getting stuck down infinite paths (e.g., continually picking up
and putting down the same block).

*/
















