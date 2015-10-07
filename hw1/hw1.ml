(* Name: Victor Frolov
   Email: vicfrolov@gmail.com
   Student ID: 978687700

   Others With Whom I Discussed Things: Justin, Trixie, Joe

   Other Resources I Consulted: StackExchange
   
*)

(* NOTE: for full credit, add unit tests for each problem.  You should
   define enough unit tests to provide full test coverage for your
   code; each subexpression should be evaluated for at least one
   test.

   Use OCaml's built-in assert function to define unit tests.
  
   run `ocaml hw1.ml` to typecheck and run all tests.
 *)

let _ = assert (1 = 1)
let _ = assert (not (1 = 0))

(* Problem 1
Write a function to compute the nth Fibonacci number, where
the 0th Fibonacci number is 0, the 1st is 1, and the nth for n > 1 is
the sum of the (n-1)st and (n-2)nd Fibonacci numbers.
 *)

let rec fib (n:int) : int =
  match n with
  | 0 -> 0
  | 1 -> 1
  | n -> fib (n - 1) + fib (n - 2);;

  let _ = assert(fib(3) = 2);;
  let _ = assert(fib(0) = 0);;
  let _ = assert(fib(1) = 1);;  
  let _ = assert(fib(9) = 34);;




(* Problem 2	       
Write a function clone of type 'a * int -> 'a list.  The function
takes an item e and a nonnegative integer n and returns a list
containing n copies of e.  
 *)

let rec clone ((e,n) : 'a * int) : 'a list =
  match n with 
  | 0 -> []
  | _ -> e :: clone(e,(n-1))


let _ = assert(clone(1,0) = []);;
let _ = assert(clone(1,3) = [1;1;1]);;
let _ = assert(clone("a",5) = ["a";"a";"a";"a";"a"]);;
let _ = assert(clone([5;5], 5) = [[5; 5]; [5; 5]; [5; 5]; [5; 5]; [5; 5]]);;



(* Problem 3
Write a recursive function to get the number of occurrences of an
element in a list. For example, there are 0 occurrences of 5 in [1;2;3].
There are 2 occurrences of 5 in [1;5;5;0].
 *)

let rec count ((v,l) : ('a * 'a list)) : int =
  match l with
  | [] -> 0
  | head::tail -> (if head = v then 1 else 0) + count(v, tail) 


let _ = assert(count(5, [1;5;5;0]) = 2);;
let _ = assert(count(5, []) = 0);;
let _ = assert(count("a", ["a";"b";"c";"a";"a"]) = 3);;
let _ = assert(count(3, [3;3;3;5;5;5;5;5;5;5;5;5;5;5;5;5;3]) = 4);;

(* Problem 4
Write a function that appends one list to the front of another.    
 *)

let rec append ((l1,l2) : ('a list * 'a list)) : 'a list =
  match l1 with 
  | [] -> l2
  |head::tail -> head :: append(tail, l2)


let _ = assert(append([1;2;3], [4;5;6]) = [1;2;3;4;5;6])
let _ = assert(append([], []) = [])
let _ = assert(append([1], []) = [1])
let _ = assert(append([], [1]) = [1])



    
(* Problem 5
Use append to write a recursive function that reverses the elements in
a list.
 *)

let rec reverse (l : 'a list) : 'a list =
  match l with
  |[] -> []
  |head::tail -> append(reverse(tail), [head])


let _ = assert(reverse([]) = []);;
let _ = assert(reverse([1]) = [1]);;
let _ = assert(reverse([1;2]) = [2;1]);;
let _ = assert(reverse([1;2;4;5]) = [5;4;2;1]);;
let _ = assert(reverse([false;true]) = [true;false])


(* Problem 6
Write a function "tails" of type 'a list -> 'a list list that takes a
list and returns a list of lists containing the original list along
with all tails of the list, from longest to shortest.
 *)        

let rec tails(l : 'a list) : 'a list list = 
  match l with 
  | [] -> [[]]
  | head :: tail -> l :: tails(tail)

let _ = assert (tails [] = [[]])
let _ = assert (tails [1] = [[1];[]])
let _ = assert (tails ["a"] = [["a"];[]])
let _ = assert (tails [1;2;3] = [[1;2;3];[2;3];[3];[]])


(* Problem 7
Write a function split of type 'a list -> 'a list * 'a list that
separates out those elements of the given list in odd positions (that
is, the first, third, fifth, etc.) from those in even positions (that
is, the second, fourth, etc.). 
 *)        

let rec split(l : 'a list) : 'a list * 'a list =
  match l with 
  | [] -> ([], [])
  | [e] -> ([e], [])
  | head::e::tail -> let x,y = split(tail) in (head::x , e::y)


let _ = assert(split([]) = ([], [])) 
let _ = assert (split [1;2;3;4] = ([1;3], [2;4]))
let _ = assert (split ["banana"; "clown"; "orange"] = (["banana"; "orange"], ["clown"]))


(* Problem 8
Flatten a list of lists.
 *)


let rec flatten (l: 'a list list) : 'a list =
  match l with
  | [] -> []
  | head :: tail ->  append(head, flatten(tail))

let _ = assert (flatten [[]] = [])
let _ = assert (flatten [[2]] = [2])
let _ = assert (flatten [[2]; []; [3;4]] = [2; 3; 4])

               
(* Problem 9
Write a function to return the last element of a list. To deal with
the case when the list is empty, the function should return a value of
the built-in option type, defined as follows:

type 'a option = None | Some of 'a
 *)

let rec last (l: 'a list) : 'a option =
  match l with 
  | [] -> None
  | head :: tail when tail = [] -> Some head
  | head :: tail -> last(tail)


let _ = assert (last [] = None)
let _ = assert (last [1;3;2] = Some 2)  
let _ = assert (last ["a"; "b"; "asdf"] = Some "asdf")

(* Problem 10
Write a recursive function to return the longest prefix of a list --
another list containing all but the last element. For example, the
longest prefix of [1;2;3;4;5] is [1;2;3;4]
 *)

let rec longestPrefix (l : 'a list) : 'a list =
  match l with 
  |[] -> []
  |[x] -> []
  |head :: tail -> head :: longestPrefix tail




let _ = assert (longestPrefix [] = [])
let _ = assert (longestPrefix [1] = [])
let _ = assert (longestPrefix [1;2;3;4;5] = [1;2;3;4])




(* Problem 11
Write a recursive function that checks whether a list is a
palindrome. A palindrome reads the same forward or backward;
e.g. ["x"; "a"; "m"; "a"; "x"]. Hint: use last and longestPrefix.
 *)
         
let rec palindrome (l : 'a list) : bool =
  match l with 
  | [] -> true
  | [h] -> true
  | head :: tail -> if Some head = last(l) then palindrome(longestPrefix (tail)) else false
    

let _ = assert(palindrome([]) = true)
let _ = assert(palindrome([1]) = true)
let _ = assert(palindrome([1;2;1]) = true)
let _ = assert(palindrome(["h";"o";"a"]) = false)
let _ = assert(palindrome(["x"; "a"; "m"; "a"; "x"]) = true)

(* Problem 12
The naive implementation of fib is wildly inefficient, because it does
a ton of redundant computation.  Perhaps surprisingly, we can make
things much more efficient by building a list of the first n Fibonacci
numbers. Write a function fibsFrom that takes a nonnegative number n
and returns a list of the first n Fibonacci numbers in reverse order
(i.e., from the nth to the 0th).  Recall that the 0th Fibonacci number
is 0, the 1st is 1, and the nth for n > 1 is the sum of the (n-1)st
and (n-2)nd Fibonacci numbers.  You should implement fibsFrom without
writing any helper functions.  A call like (fibsFrom 50) should be
noticeably faster than (fib 50).  Hint: Your function should make only
one recursive call.
 *)

let rec fibsFrom (n:int) : int list =
  match n with
  (* I ASSUME THIS IS EXHAUSTIVE AS THE INPUT VALUE MUST BE A NON-NEGATIVE INTEGER! *)
    |0 -> [0]
    |1 -> [1;0]
    |_ -> let first::second::other = fibsFrom (n-1) in (first+second)::first::second::other

let _ = assert (fibsFrom 0 = [0])
let _ = assert (fibsFrom 1 = [1;0])
let _ = assert (fibsFrom 2 = [1;1;0])
let _ = assert (fibsFrom 3 = [2;1;1;0])

(* Problem 14
Strings in OCaml do not support pattern matching very well, so it is
sometimes necessary to convert them to something that we can match on
more easily: lists of characters.  Using OCaml's built-in functions
String.get and String.length, write a function chars that converts a
string to a char list.
 *)

let _ = assert (String.get "asdf" 0 = 'a')
let _ = assert (String.length "asdf" = 4)        

let rec chars (s:string) : char list =
  match s with 
  | "" -> []
  | _ -> (String.get s 0) :: (chars (String.sub s 1 (String.length s -1)))


let _ = assert (chars "" = [])
let _ = assert (chars "a" = ['a'])
let _ = assert (chars "asdf" = ['a';'s';'d';'f'])


(* Problem 13
The naive algorithm for reversing a list takes time that is quadratic
in the size of the argument list.  In this problem, you will implement
a more efficient algorithm for reversing a list: your solution should
only take linear time. Call this function fastRev. The key to fastRev
is that it builds the reversed list as we recurse over the input list,
rather than as we return from each recursive call.  This is similar to
how an iterative version of list reversal, as implemented in a
language like C, would naturally work.

To get the right behavior, your fastRev function should use a local
helper function revHelper to do most of the work.  The helper function
should take two arguments: (1) the suffix of the input list that
remains to be reversed; (2) the reversal of the first part of the
input list.  The helper function should return the complete reversed
list.  Therefore the reversal of an input list l can be performed via
the invocation revHelper(l, []).  I've already provided this setup for
you, so all you have to do is provide the implementation of revHelper
(which is defined as a nested function within fastRev) and invoke it
as listed above.  The call (fastRev (clone(0, 10000))) should be
noticeably faster than (reverse (clone(0, 10000))).
 *)
               
let fastRev (l : 'a list) : 'a list =
  let rec revHelper (remain, sofar) =
    match remain with
    |[] -> sofar
    |head::tail ->  revHelper(tail, head::sofar)
in revHelper(l, [])

let _ = assert(fastRev [1;2] = [2;1])
let _ = assert(fastRev ["banana"; "orange"; "apple"] = ["apple";"orange";"banana"])



(* Problem 15
Convert a list of digits (numbers between 0 and 9) into an integer.
 *)

let rec int_of_digits (ds : int list) : int =
  match ds with 
  | [] -> 0
  | [x] -> x
  | head::tail -> head * int_of_float(10.0 ** (float_of_int (List.length ds - 1))) + int_of_digits(tail)

let _ = assert (int_of_digits [1;2;3] = 123)
let _ = assert (int_of_digits [0;1;0] = 10)
let _ = assert (int_of_digits [] = 0)
let _ = assert (int_of_digits [5] = 5)



