(* camlp5r *)
(***********************************************************************)
(*                                                                     *)
(*                             Camlp5                                  *)
(*                                                                     *)
(*                Daniel de Rauglaudre, INRIA Rocquencourt             *)
(*                                                                     *)
(*  Copyright 2007 Institut National de Recherche en Informatique et   *)
(*  Automatique.  Distributed only by permission.                      *)
(*                                                                     *)
(***********************************************************************)

(* This file has been generated by program: do not edit! *)

type 'te grammar =
  { gtokens : (Token.pattern, int ref) Hashtbl.t;
    mutable glexer : 'te Token.glexer }
;;

type 'te g_entry =
  { egram : 'te grammar;
    ename : string;
    elocal : bool;
    mutable estart : int -> 'te Stream.t -> Obj.t;
    mutable econtinue : int -> int -> Obj.t -> 'te Stream.t -> Obj.t;
    mutable edesc : 'te g_desc }
and 'te g_desc =
    Dlevels of 'te g_level list
  | Dparser of ('te Stream.t -> Obj.t)
and 'te g_level =
  { assoc : g_assoc;
    lname : string option;
    lsuffix : 'te g_tree;
    lprefix : 'te g_tree }
and g_assoc = NonA | RightA | LeftA
and 'te g_symbol =
    Smeta of string * 'te g_symbol list * Obj.t
  | Snterm of 'te g_entry
  | Snterml of 'te g_entry * string
  | Slist0 of 'te g_symbol
  | Slist0sep of 'te g_symbol * 'te g_symbol
  | Slist1 of 'te g_symbol
  | Slist1sep of 'te g_symbol * 'te g_symbol
  | Sopt of 'te g_symbol
  | Sself
  | Snext
  | Stoken of Token.pattern
  | Stree of 'te g_tree
and g_action = Obj.t
and 'te g_tree =
    Node of 'te g_node
  | LocAct of g_action * g_action list
  | DeadEnd
and 'te g_node =
  { node : 'te g_symbol; son : 'te g_tree; brother : 'te g_tree }
;;

type position =
    First
  | Last
  | Before of string
  | After of string
  | Level of string
;;

val levels_of_rules :
  'te g_entry -> position option ->
    (string option * g_assoc option * ('te g_symbol list * g_action) list)
      list ->
    'te g_level list;;
val srules : ('te g_symbol list * g_action) list -> 'te g_symbol;;
external action : 'a -> g_action = "%identity";;

val delete_rule_in_level_list :
  'te g_entry -> 'te g_symbol list -> 'te g_level list -> 'te g_level list;;

val warning_verbose : bool ref;;
