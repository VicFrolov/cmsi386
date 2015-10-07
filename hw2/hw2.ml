(* Name: Victor Frolov

   UID:978687700

   Others With Whom I Discussed Things: Trixie, Chris, Dennis Ranker

   Other Resources I Consulted: stackOverflow
   
*)

(* For this assignment, you will get practice with higher-order functions
 * in OCaml.  In a few places below, you are required to implement your
 * functions in a particular way, so pay attention to those directives or
 * you will get no credit for the problem.
 *)

(* Do not use any functions defined in other modules, except for List.map,
 * List.filter, List.fold_left, and List.fold_right. 
 *)

let map = List.map
let filter = List.filter
let fold_left = List.fold_left
let fold_right = List.fold_right

(************************************************************************
 * Problem 1: Using higher-order functions.
 *
 * Implement each function below as a single call to one of map, filter,
 * fold_left, or fold_right.
 ************************************************************************)

(* Problem 1a.
   A function that takes a list as input and returns the same list except 
   with all positive integers doubled in value.  Other integers are
   kept but are unchanged.
 *)

let doubleAllPos : int list -> int list = map (fun x -> if x > 0 then (x * 2) else x);;

let _ = assert (doubleAllPos [1;2;-1;4;-3;0] = [2;4;-1;8;-3;0]);;
let _ = assert (doubleAllPos [100;-300;200;-400;500;0] = [200;-300;400;-400;1000;0]);;
let _ = assert (doubleAllPos [] = [])


(* Problem 1b.
   A function that takes a list of pairs and returns a pair of lists.
   The first list contains the first component of each input pair;
   the second list contains the second components.
 *)
   
let unzip   (l : ('a * 'b) list) : 'a list * 'b list = fold_left (fun (list1,list2) (e1,e2) -> ( list1 @ [e1], list2 @ [e2])) ([], []) l ;;

let _ = assert (unzip [(1,'a');(2,'b')] = ([1;2], ['a';'b']));;
let _ = assert (unzip [(1,2);(2,4);(3,5);(4,6);(5,7);(6,9)] = ([1; 2; 3; 4; 5; 6], [2; 4; 5; 6; 7; 9]));;
let _ = assert (unzip [("hi", "bye");("there", "forever")] =  (["hi"; "there"], ["bye"; "forever"]) );;
let _ = assert (unzip [('b','a');('z','b')] = (['b';'z'], ['a';'b']));;



(* Problem 1c.
   Implement the so-called run-length encoding data compression method.
   Consecutive duplicates of elements are encoded as pairs (N, E) where
   N is the number of duplicates of the element E.
 *)


let encode l = fold_right (fun x z ->
        match z with
        | (n, y) :: zs when x = y -> (n + 1, y) :: zs
        | zs                      -> (1, x) :: zs
    ) l [];;

let _ = assert (encode ['a';'a';'a';'b';'c';'c'] = [(3,'a');(1,'b');(2,'c')]);;
let _ = assert (encode [1;2;2;3;3;3;4;4;4;4;5;5;5;5;5] = [(1, 1); (2, 2); (3,3); (4,4); (5,5)]);;
let _ = assert (encode [] = []);;
let _ = assert (encode ["sup"] = [(1, "sup")]);;

(* let rec _encode x l = 
	match l with 
	|[] -> 0
	| hd :: tl -> (if hd = x then + 1 else  + 0) + _encode x tl

let encode x l = ( _encode x l, x) *)



(* Problem 1d
   The function intOfDigits from Homework 1.
 *)

let intOfDigits (l : int list) : int =  fold_left (fun lst hd -> (lst * 10) + hd) 0 l;;


let _ = assert (intOfDigits [1;2;3] = 123);;
let _ = assert (intOfDigits [0;1;0] = 10);;
let _ = assert (intOfDigits [] = 0);;
let _ = assert (intOfDigits [5] = 5);;



(* Problem 2a.  

   A useful variant of map is the map2 function, which is like map but
   works on two lists instead of one. Note: If either input list is
   empty, then the output list is empty.

   Define map2 function using explicit recursion.

   Do not use any functions from the List module or other modules.
 *)


let rec map2 (f: 'a -> 'b -> 'c) (l1: 'a list) (l2:'b list) : 'c list =
  match l1,l2 with
  | [],[]                 -> []
  | (hd1::tl1),(hd2::tl2) -> let hd = f hd1 hd2 in hd::(map2 f tl1 tl2)


let _ = assert (map2 (fun x y -> x*y) [1;2;3] [4;5;6] = [1*4; 2*5; 3*6]);;
let _ = assert (map2 (fun x y -> x-y)[1;2;3] [4;5;6] = [1-4; 2-5; 3-6]);;
let _ = assert (map2 (fun x y -> x+y)[] [] = []);;


(* Problem 2b.

   Now implement the zip function, which is the inverse of unzip
   above. zip takes two lists l1 and l2, and returns a list of pairs,
   where the first element of the ith pair is the ith element of l1,
   and the second element of the ith pair is the ith element of l2.

   Implement zip as a function whose entire body is a single call to
   map2.
 *)

let zip (l1: 'a list)  (l2 : 'b list) : ('a * 'b) list = map2 (fun x y -> (x,y)) l1 l2;;

let _ = assert (zip [1;2] ['a';'b']  = [(1,'a');(2,'b')]);;
let _ = assert (zip [1;1;1;1] [2;2;2;2]  = [(1,2);(1,2);(1,2);(1,2)]);;
let _ = assert (zip [] [] = []);;


(* Problem 2c.

   A useful variant of fold_right and fold_left is the foldn function,
   which folds over an integer (assumed to be nonnegative) rather than
   a list. Given a function f, an integer n, and a base case b, foldn
   calls f n times. The input to the first call is the base case b,
   the input to second call is the output of the first call, and so
   on.

   For example, we can define the factorial function as:
   let fact n = foldn (fun x y -> x*y) n 1

   Implement foldn using explicit recursion.
 *)

let rec foldn  (f: (int -> 'a -> 'a)) (i: int) (b:'a) : 'a = 
	match i with 
	| 0 -> b
	| _ -> f i (foldn f (i-1) b)	


let fact n = foldn (fun x y -> x*y) n 1	

let _ = assert (fact 5 = 120);;
let _ = assert (fact 1 = 1)
let _ = assert (fact 2 = 2)
let _ = assert (foldn (fun x y -> x*y) 5 1 = 5 * 4 * 3 * 2 * 1 * 1)
let _ = assert (foldn (fun x y -> x-y) 5 0 = 5 - (4 - (3 - (2 - (1 - 0)))))


(* Problem 2d.
   Implement the clone function from Homework 1 as a single call to
   foldn.
 *)

let clone ((e,n) : 'a * int) : 'a list = foldn( fun a b -> let a = e in a :: b ) n []


let _ = assert(clone(1,0) = []);;
let _ = assert(clone(1,3) = [1;1;1]);;
let _ = assert(clone("a",5) = ["a";"a";"a";"a";"a"]);;
let _ = assert(clone([5;5], 5) = [[5; 5]; [5; 5]; [5; 5]; [5; 5]; [5; 5]]);;


(* Problem 2e.
   Implement fibsFrom from Homework1 as a single call to foldn.
 *)

let fibsFrom (n:int) : int list = foldn(fun a b -> let hd::mid::tl = b in hd + mid::b) (n-1) [1;0];;


let _ = assert (fibsFrom 0 = [0])
let _ = assert (fibsFrom 1 = [1;0])
let _ = assert (fibsFrom 2 = [1;1;0])
let _ = assert (fibsFrom 3 = [2;1;1;0])
let _ = assert (fibsFrom 6 = [8;5;3;2;1;1;0])

(* Problem 3a.

   Our first implementation of a dictionary is as an "association
   list", i.e. a list of pairs. Implement empty1, put1, and get1 for
   association lists (we use the suffix 1 to distinguish from other
   implementations below).  As an example of how this representation
   of dictionaries works, the dictionary that maps "hello" to 5 and
   has no other entries is represented as [("hello",5)].

   To get the effect of replacing old entries for a key, put1 should
   simply add new entries to the front of the list, and accordingly
   get1 should return the leftmost value whose associated key matches
   the given key.

 *) 

let empty1 : unit -> ('a * 'b) list = fun x -> [];;

let put1 : 'a -> 'b -> ('a * 'b) list -> ('a * 'b) list = fun key value lst -> ((key,value)::lst);;

let rec get1 : 'a -> ('a * 'b) list -> 'b option = fun key lst -> 
	match lst with 
	| [] -> None
	| (keySearch, value)::rest -> if key = keySearch then Some value else get1 key rest;;



let _ = assert(empty1 () = []);;
let _ = assert(put1 1 "bestInTheWest" [] = [(1, "bestInTheWest")]);;
let _ = assert(put1 2 "bestInTheWest" [(2, "secondIsForLosers")] =  [(2, "bestInTheWest");(2, "secondIsForLosers")])
let _ = assert(get1 5 [(5, "bad");(5, "good");(4, "whocares")] = Some "bad");;
let _ = assert(get1 5 [] = None);;


(* Problem 3b.

   Our second implementation of a dictionary uses a new datatype 
   "dict2", defined below.

   dict2 is polymorphic in the key and value types, which respectively
   are represented by the type variables 'a and 'b.  For example, the
   dictionary that maps "hello" to 5 and has no other entries would be
   represented as the value Entry("hello", 5, Empty) and
   would have the type (string,int) dict2.

   Implement empty2, put2, and get2 for dict2.  As above, new entries
   should be added to the front of the dictionary, and get2 should
   return the leftmost match.

   empty2: unit -> ('a,'b) dict2
   put2: 'a -> 'b -> ('a,'b) dict2 -> ('a,'b) dict2
   get2: 'a -> ('a,'b) dict2 -> 'b option
 *)  
    
type ('a,'b) dict2 = Empty | Entry of 'a * 'b * ('a,'b) dict2;;

let empty2 : unit -> ('a,'b) dict2 = fun x -> Empty;;

let put2 : 'a -> 'b -> ('a,'b) dict2 -> ('a,'b) dict2 = fun newKey newValue oldDict -> Entry (newKey, newValue, oldDict);;

let rec get2 : 'a -> ('a,'b) dict2 -> 'b option = fun key dictionary ->
    match dictionary with
    | Empty -> None
    | Entry (keyIn, valueIn, rest) -> if key = keyIn then Some valueIn else get2 key rest;;



let _ = assert(empty2 () = Empty);;
let _ = assert(put2 "testMe" 5 (Entry ("sup", 4, Empty)) = (Entry ("testMe", 5, Entry( "sup", 4, Empty))));;
let _ = assert(get2 "older" (Entry ("testMe", 5, Entry("older", 4, Empty))) = Some 4);;



(* Problem 3c

   Conceptually, a dictionary is just a function from keys to values.
   Since OCaml has first-class functions, we can choose to represent
   dictionaries as actual functions.  We define the following type:

   type ('a,'b) dict3 = ('a -> 'b option)

   We haven't seen the above syntax before (note that the right-hand
   side just says ('a -> 'b option) rather than something like Foo of
   ('a -> 'b option)).  Here dict3 is a type synonym: it is just a
   shorthand for the given function type rather than a new type.  As
   an example of how this representation of dictionaries works, the
   following dictionary maps "hello" to 5 and has no other entries:

   (function s ->
    match s with
    | "hello" -> Some 5
    | _ -> None)

   One advantage of this representation over the two dictionary
   implementations above is that we can represent infinite-size
   dictionaries.  For instance, the following dictionary maps all
   strings to their length (using the String.length function):

   (function s -> Some(String.length s))

   Implement empty3, put3, and get3 for dict3.  It's OK if the types
   that OCaml infers for these functions use ('a -> 'b option) in
   place of ('a,'b) dict3, since they are synonyms for one another.

   empty3: unit -> ('a,'b) dict3
   put3: 'a -> 'b -> ('a,'b) dict3 -> ('a,'b) dict3
   get3: 'a -> ('a,'b) dict3 -> 'b option
 *)  

type ('a,'b) dict3 = ('a -> 'b option)

let empty3 : unit -> ('a,'b) dict3 =  fun x -> (fun y ->  None);;

let put3 : 'a -> 'b -> ('a,'b) dict3 -> ('a,'b) dict3 = fun key value dict -> fun x -> if x = key then Some value else dict x;;

let get3 : 'a -> ('a,'b) dict3 -> 'b option = fun key dict -> dict key;;



let _ = assert (get3 "orangeugladididntsaybananaagain" (empty3 ()) = None);;
let _ = assert (get3 42 (fun lst -> Some (String.length "charizard")) = Some 9);;
let _ = assert (get3 800 (fun lst -> Some (String.length "two")) = Some 3);;



