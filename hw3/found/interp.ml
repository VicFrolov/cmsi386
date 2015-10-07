(*
  Jonathan Nguy
  603 799 761
*)
(* Homework 1:  MOCaml interpreter *)


(* EXCEPTIONS *)

(* This is a marker for places in the code that you have to fill in.
   Your completed assignment should never raise this exception. *)
exception ImplementMe of string

(* This exception is thrown to indicate an error during typechecking
   (e.g., a name has not been declared before it is used).
   The string should provide an error message.
*)
exception TypeError of string

(* This exception is thrown when an error occurs during evaluation
   (e.g., attempting to invoke something that's not a function).
   The string should provide an error message.
*)
exception EvalError of string

(* This exception is thrown when pattern matching fails during evaluation. *)  
exception MatchFailure  



(* EVALUATION *)

(* See if a value matches a given pattern.  If there is a match, return
   an environment for any name bindings in the pattern.  If there is not
   a match, raise the MatchFailure exception.
   - only integers match integer patterns, and only if the values agree
   - only booleans match boolean patterns, and only if the values agree
   - any value matches the wildcard pattern
   - any value matches the variable pattern
     and additionally creates a new name binding
   - only tuples match tuple patterns, and only if they have the
     same length and each component value matches the associated pattern
   - otherwise pattern matching failures
   
*)
let rec patMatchOne (pat:mopat) (value:movalue) : moenv =
  match (pat, value) with
      (IntPat(i), IntVal(j)) ->
	if i=j then Env.empty_env() else raise MatchFailure
    | (BoolPat(b1), BoolVal(b2)) ->
	if b1=b2 then Env.empty_env() else raise MatchFailure

    (* anything matches wildcard pattern, then return empty list *)
    | (WildcardPat(w), _) -> Env.empty_env() 

      (* add the variable to the environment *)
    | (VarPat(str, v), a) -> Env.add_binding str a (Env.empty_env())

      (* tuples -> you have to match the pattern and val
	 as lists, then recursively call patMatchOne for each element*)
    | (TuplePat(t1), TupleVal(t2)) -> 
      (match (t1,t2) with
	   ([],[]) -> Env.empty_env()
	 | (x::xs, y::ys) ->
	   Env.combine_envs (patMatchOne x y) (patMatchOne (TuplePat xs) (TupleVal ys)) 
	 | (x::xs, []) -> raise MatchFailure
	 | ([], x::xs) -> raise MatchFailure)

    | _ -> raise MatchFailure

(* Match a value to a list of (pattern, expression) pairs.  Return the
   expression corresponding to the first pattern that matches, as well as
   an environment resulting from the match. Raise a MatchFailure exception
   if no pattern matches.  *)
let rec patMatch (l:(mopat * moexpr) list) (value:movalue) : (moexpr * moenv) =
  match (l, value) with

      (* get the environments of the patterns using patMatchOne  *)
      ([], a) -> raise MatchFailure
    | ((a,b)::xs, y) -> 
      try (b, (patMatchOne a y)) with MatchFailure -> (patMatch xs y)


(* Evaluate an expression in the given environment.  Raise a MatchFailure if
   pattern matching fails.  Raise an EvalError if any other kind of error
   occurs (e.g., trying to add a boolean to an integer) which prevents evaluation
   from continuing.
*)	      
let rec eval (e:moexpr) (env:moenv) : movalue =
  match e with
      IntConst(c) -> IntVal(c)
    | BoolConst(b) -> BoolVal(b)
      (* Lookup the variable's value in the environment.
	 Raise an EvalError if not found. *)
    | Var(s) -> (try (Env.lookup s env) 
      with Env.NotBound -> raise (EvalError "value not found in environment"))

      (* Functions evaluate to themselves and also keep a copy of their
	 lexical environment. *)
    | Fun(pat, body) -> (FunVal(pat, body, env))

      (* add left expression with right expression... must be ints *)
    | Plus(e1,e2) -> (let e1Val = eval e1 env in
		     let e2Val = eval e2 env in
		     match (e1Val, e2Val) with
			 (IntVal(x), IntVal(y)) -> IntVal(x+y)
		       | _ -> raise (EvalError "must add 2 ints"))
      
      (* Based on the conditional expression's value, either evaluate
	 the "then" or the "else" expression. *)
    | If(cond,thn,els) -> 
      (if eval cond env = BoolVal(true)
      then eval thn env
      else eval els env)
 
      (* Evaluate each component of the tuple and return a tuple value. *)
    | Tuple(es) -> TupleVal(List.fold_right (fun x y -> (eval x env)::y) es [])
      
      (* Evaluate e1 to a value v1, match v1 against pattern p, and then
	 evaluate e2 using any new bindings created by the pattern matching. *)
    | Let((p,e1), e2) -> (let v1 = eval e1 env in
			  let tempEnv = patMatchOne p v1 in
			  eval e2 (Env.combine_envs env tempEnv))

    (* Evaluate e1 to a function f and e2 to an argument v.
       Invoke the first case of f whose pattern is matched by v, using
       any new bindings created by the pattern matching. *)
     | App(e1,e2) ->  

       (*make sure the left expression is a function*)
      (let f = eval e1 env in
       let v = eval e2 env in
       match f with
	   (*f is a function value, then return the value of
	     the function expression using the value of v *)
	   FunVal(pat, exp, en) -> 		   
	     eval exp (Env.combine_all_envs [env; en; (patMatchOne pat v)]) 
	 | _ -> raise (EvalError "left expression must be a function"))


    (* Evaluate the withExp to a value v, and then invoke the body of
       the first case whose pattern is matched by v, using any new
       bindings created by the pattern matching. *)
	(* evaluate the "with" expression
	   then match the with expression with the cases, then 
	   return the value of the expression that matched*)
    | Match(withExp, cases) -> (
      let v = eval withExp env in
      try (let (a,b) = patMatch cases v in
       eval a (Env.combine_envs env b)) with MatchFailure -> 
	raise (EvalError "patterns don't match with expression"))

(* TYPECHECKING *)

(* Determine the type of a pattern and also produce a type environment for
   any names bound in the pattern. You may assume that a pattern never refers
   to the same variable name more than once.
   - an integer pattern has type int
   - a boolean pattern has type bool
   - a wildcard pattern has its declared type
   - a variable pattern has its declared type and adds a name binding
     to the type environment
   - an empty tuple pattern has type unit
   - a non-empty tuple pattern has a tuple type, with component types
     determined by the types of the component patterns
*)
let rec patMatchType (pat:mopat) : (motyp * motenv) =
  match pat with
      IntPat(i) -> (IntType, Env.empty_env())
    | BoolPat(b) -> (BoolType, Env.empty_env())
    | WildcardPat(w) -> (w, Env.empty_env())
    | VarPat(str, v) -> (v, (Env.add_binding str v (Env.empty_env())))
      (* a tuple is a list of motypes *)
    | TuplePat(a) -> 
      (match a with
	  [] -> (UnitType, Env.empty_env())
	| b -> (TupleType(List.fold_right (fun x y -> 
	  let (c,d) = (patMatchType x) in c::y) b []), 
	
	       (List.fold_right (fun x y -> 
		 let (e,f) = (patMatchType x) in (Env.combine_envs f y)) b (Env.empty_env()))))

      (* | _ -> raise (ImplementMe "patMatchType")*)


(* Typecheck an expression in the given type environment. Raise a TypeError
   if a type error is found (e.g., trying to use an expression of type bool
   as if it has type int). *)    
let rec tc (e:moexpr) (tenv:motenv) :motyp =
  match e with
      IntConst(c) -> IntType
    | BoolConst(b) -> BoolType

    (* Lookup the variable's type in the environment.
       Raise a TypeError if not found. *)
    | Var(s) -> (try (Env.lookup s tenv) with (Env.NotBound) -> 
                raise (TypeError "variable not found in environment"))

      (* check left and right expression to make sure they're ints *)
    | Plus(e1,e2) -> (let a = tc e1 tenv in
		      let b = tc e2 tenv in
		      if (a,b) = (IntType, IntType) 
		      then IntType
		      else raise (TypeError "must add only integers"))
	    
    (* The guard expression must have type boolean, and the
       then and else branches must have the same type. *)

      (* simply make sure the type of thn is same as type of els *)
    | If(cond,thn,els) -> 
      (if tc cond tenv = BoolType
      then (let a = tc thn tenv in
	    let b = tc els tenv in
	    if a=b
	    then a
	    else raise (TypeError "then and else statements must have same type "))
      else raise (TypeError "condition statement must be a bool"))

    (* As a special case, the type of the empty tuple is unit. Otherwise,
       the type of a tuple is a tuple type, whose component types are determined
       by the types of the tuple components. *)
    | Tuple(es) -> 
      (match es with
	  [] -> UnitType
	| a -> TupleType(List.fold_right (fun x y -> (tc x tenv)::y) a []))
      

    (* Typecheck the pattern, producing the function's argument type.
       Then typecheck the body to determine the result type, using any new
       name bindings from the pattern.  The type of a function is a function
       type. *)
    | Fun(pat, body) -> (let (x,y) = (patMatchType pat) in
			 FunType (x, tc body (Env.combine_envs tenv y)))

    (* Typecheck e1 and pat, and make sure their types agree.  Then typecheck
       e2 using any new name bindings from the pattern. *)
    | Let((pat,e1), e2) -> (let (a, b) = (patMatchType pat) in
			    let c = (tc e1 tenv) in
			    (* if the two pattern types don't match *)
			    if a <> c
			    then raise (TypeError "e1 and pat must be of same type")
			    else (tc e2 (Env.combine_envs tenv b)))

    (* Typecheck e1 to a function type and e2 to a type t2.  Require t2
       to agree with the function's argument type, and return the function's
       result type as the type of the whole expression. *)
    | App(e1,e2) -> (let a = tc e1 tenv in
		     match a with
			 FunType(x,y) -> 
			   (let t2 = tc e2 tenv in 
			    if x=t2
			    then y
			    else raise (TypeError "e2 must agree with function argument type"))
		       | _ -> raise (TypeError "first argument must be a function type"))

    (* Typecheck the "with" expression to a type t.  Typecheck each
       case, which involves typechecking its pattern and then its
       body, the latter using any new bindings from the pattern.  The
       type of each pattern must agree with the type of the "with"
       expression.  The types of each body expression must agree with
       one another. *)
    | Match(withExp, cases) -> (let t = tc withExp tenv in	
				(* body is a list of types of the cases *)
				let bod = 

				  (* map uses the cases list and ensures the patterns
				  match the withExp pattern... the function creates
				  a list of the types of the bodies *)
				(List.map (fun x ->
				  match x with
				      (pat, exp) ->
					let (a,b) = (patMatchType pat) in
					(* if the patterns dont match *)
					if a <> t
					then raise (TypeError 
						      "match cases do not match expression")
					else tc exp (Env.combine_envs tenv b)) cases)
				in 
				match bod with
				    [] -> raise (TypeError "no matches")
				  | x::xs ->   
				    (* do something for all of the list *)
				    (if (List.for_all (fun a -> 
				      if a=x
				      then true
				      else false) bod)
				     then x (* return type of the body expression *)
				     else raise (TypeError "not all bodies match")))