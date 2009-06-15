(* camlp5r q_MLast.cmo *)
(* This file has been generated by program: do not edit! *)
(* Copyright (c) INRIA 2007 *)

open Pretty;;
open Pcaml.Printers;;

type ('a, 'b) pr_gfun = (string, 'b) pr_context -> 'a -> string;;

let tab ind = String.make ind ' ';;

(* horizontal list *)
let rec hlist elem pc xl =
  match xl with
    [] -> sprintf "%s%s" pc.bef pc.aft
  | [x] -> elem pc x
  | x :: xl ->
      sprintf "%s %s" (elem {pc with aft = ""; dang = ""} x)
        (hlist elem {pc with bef = ""} xl)
;;

(* horizontal list with different function from 2nd element on *)
let rec hlist2 elem elem2 ({aft = k0, k} as pc) xl =
  match xl with
    [] -> invalid_arg "hlist2"
  | [x] -> elem {pc with aft = k} x
  | x :: xl ->
      sprintf "%s %s" (elem {pc with aft = k0} x)
        (hlist2 elem2 elem2 {pc with bef = ""} xl)
;;

(* horizontal list with different function for the last element *)
let rec hlistl elem eleml pc xl =
  match xl with
    [] -> sprintf "%s%s" pc.bef pc.aft
  | [x] -> eleml pc x
  | x :: xl ->
      sprintf "%s %s" (elem {pc with aft = ""; dang = ""} x)
        (hlistl elem eleml {pc with bef = ""} xl)
;;

(* vertical list *)
let rec vlist elem pc xl =
  match xl with
    [] -> sprintf "%s%s" pc.bef pc.aft
  | [x] -> elem pc x
  | x :: xl ->
      sprintf "%s\n%s" (elem {pc with aft = ""; dang = ""} x)
        (vlist elem {pc with bef = tab pc.ind} xl)
;;

(* vertical list with different function from 2nd element on *)
let rec vlist2 elem elem2 ({aft = k0, k} as pc) xl =
  match xl with
    [] -> invalid_arg "vlist2"
  | [x] -> elem {pc with aft = k} x
  | x :: xl ->
      sprintf "%s\n%s" (elem {pc with aft = k0} x)
        (vlist2 elem2 elem2 {pc with bef = tab pc.ind} xl)
;;

(* vertical list with different function for the last element *)
let rec vlistl elem eleml pc xl =
  match xl with
    [] -> sprintf "%s%s" pc.bef pc.aft
  | [x] -> eleml pc x
  | x :: xl ->
      sprintf "%s\n%s" (elem {pc with aft = ""; dang = ""} x)
        (vlistl elem eleml {pc with bef = tab pc.ind} xl)
;;

let rise_string ind sh b s =
  (* hack for "plistl" (below): if s is a "string" (i.e. starting with
     double-quote) which contains newlines, attempt to concat its first
     line in the previous line, and, instead of displaying this:
              eprintf
                "\
           hello, world"
     displays that:
              eprintf "\
           hello, world"
     what "saves" one line.
   *)
  if String.length s > ind + sh && s.[ind+sh] = '\"' then
    match try Some (String.index s '\n') with Not_found -> None with
      Some i ->
        let t = String.sub s (ind + sh) (String.length s - ind - sh) in
        let i = i - ind - sh in
        begin match
          horiz_vertic (fun () -> Some (sprintf "%s %s" b (String.sub t 0 i)))
            (fun () -> None)
        with
          Some b -> b, String.sub t (i + 1) (String.length t - i - 1)
        | None -> b, s
        end
    | None -> b, s
  else b, s
;;

(* paragraph list with a different function for the last element;
   the list elements are pairs where second elements are separators
   (the last separator is ignored) *)
let rec plistl elem eleml sh pc xl =
  let (s1, s2o) = plistl_two_parts elem eleml sh pc xl in
  match s2o with
    Some s2 -> sprintf "%s\n%s" s1 s2
  | None -> s1
and plistl_two_parts elem eleml sh pc xl =
  match xl with
    [] -> assert false
  | [x, _] -> eleml pc x, None
  | (x, sep) :: xl ->
      let s =
        horiz_vertic (fun () -> Some (elem {pc with aft = sep; dang = sep} x))
          (fun () -> None)
      in
      match s with
        Some b ->
          plistl_kont_same_line elem eleml sh {pc with bef = b} xl, None
      | None ->
          let s1 = elem {pc with aft = sep; dang = sep} x in
          let s2 =
            plistl elem eleml 0
              {pc with ind = pc.ind + sh; bef = tab (pc.ind + sh)} xl
          in
          s1, Some s2
and plistl_kont_same_line elem eleml sh pc xl =
  match xl with
    [] -> assert false
  | [x, _] ->
      horiz_vertic (fun () -> eleml {pc with bef = sprintf "%s " pc.bef} x)
        (fun () ->
           let s =
             eleml {pc with ind = pc.ind + sh; bef = tab (pc.ind + sh)} x
           in
           let (b, s) = rise_string pc.ind sh pc.bef s in
           sprintf "%s\n%s" b s)
  | (x, sep) :: xl ->
      let s =
        horiz_vertic
          (fun () ->
             Some
               (elem
                  {pc with bef = sprintf "%s " pc.bef; aft = sep; dang = sep}
                  x))
          (fun () -> None)
      in
      match s with
        Some b -> plistl_kont_same_line elem eleml sh {pc with bef = b} xl
      | None ->
          let (s1, s2o) =
            plistl_two_parts elem eleml 0
              {pc with ind = pc.ind + sh; bef = tab (pc.ind + sh)}
              ((x, sep) :: xl)
          in
          match s2o with
            Some s2 ->
              let (b, s1) = rise_string pc.ind sh pc.bef s1 in
              sprintf "%s\n%s\n%s" b s1 s2
          | None -> sprintf "%s\n%s" pc.bef s1
;;

(* paragraph list *)
let plist elem sh pc xl = plistl elem elem sh pc xl;;

(* paragraph list where the [pc.bef] is part of the algorithm, i.e. if the
   first element does not fit, there is a newline after the [pc.bef].*)
let plistb elem sh pc xl =
  match xl with
    [] -> sprintf "%s%s" pc.bef pc.aft
  | [x, _] ->
      horiz_vertic (fun () -> elem {pc with bef = sprintf "%s " pc.bef} x)
        (fun () ->
           let s =
             elem {pc with ind = pc.ind + sh; bef = tab (pc.ind + sh)} x
           in
           sprintf "%s\n%s" pc.bef s)
  | (x, sep) :: xl ->
      let s =
        horiz_vertic (fun () -> Some (elem {pc with aft = sep; dang = sep} x))
          (fun () -> None)
      in
      match s with
        Some b -> plistl_kont_same_line elem elem sh {pc with bef = b} xl
      | None ->
          let s1 =
            horiz_vertic (fun () -> elem {pc with aft = sep; dang = sep} x)
              (fun () ->
                 let s =
                   elem
                     {ind = pc.ind + sh; bef = tab (pc.ind + sh); aft = sep;
                      dang = sep}
                     x
                 in
                 sprintf "%s\n%s" pc.bef s)
          in
          let s2 =
            plistl elem elem 0
              {pc with ind = pc.ind + sh; bef = tab (pc.ind + sh)} xl
          in
          sprintf "%s\n%s" s1 s2
;;

(* comments *)

module Buff =
  struct
    let buff = ref (String.create 80);;
    let store len x =
      if len >= String.length !buff then
        buff := !buff ^ String.create (String.length !buff);
      !buff.[len] <- x;
      succ len
    ;;
    let mstore len s =
      let rec add_rec len i =
        if i == String.length s then len
        else add_rec (store len s.[i]) (succ i)
      in
      add_rec len 0
    ;;
    let get len = String.sub !buff 0 len;;
  end
;;

let rev_extract_comment strm =
  let rec find_comm len (strm__ : _ Stream.t) =
    match Stream.peek strm__ with
      Some ' ' -> Stream.junk strm__; find_comm (Buff.store len ' ') strm__
    | Some '\t' ->
        Stream.junk strm__;
        find_comm (Buff.mstore len (String.make 8 ' ')) strm__
    | Some '\n' -> Stream.junk strm__; find_comm (Buff.store len '\n') strm__
    | Some ')' ->
        Stream.junk strm__; find_star_bef_rparen (Buff.store len ')') strm__
    | _ -> 0
  and find_star_bef_rparen len (strm__ : _ Stream.t) =
    match Stream.peek strm__ with
      Some '*' -> Stream.junk strm__; insert (Buff.store len '*') strm__
    | _ -> 0
  and insert len (strm__ : _ Stream.t) =
    match Stream.peek strm__ with
      Some ')' ->
        Stream.junk strm__;
        find_star_bef_rparen_in_comm (Buff.store len ')') strm__
    | Some '*' ->
        Stream.junk strm__; find_lparen_aft_star (Buff.store len '*') strm__
    | Some '\"' ->
        Stream.junk strm__; insert_string (Buff.store len '\"') strm__
    | Some x -> Stream.junk strm__; insert (Buff.store len x) strm__
    | _ -> len
  and insert_string len (strm__ : _ Stream.t) =
    match Stream.peek strm__ with
      Some '\"' -> Stream.junk strm__; insert (Buff.store len '\"') strm__
    | Some x -> Stream.junk strm__; insert_string (Buff.store len x) strm__
    | _ -> len
  and find_star_bef_rparen_in_comm len (strm__ : _ Stream.t) =
    match Stream.peek strm__ with
      Some '*' ->
        Stream.junk strm__;
        let len =
          try insert (Buff.store len '*') strm__ with
            Stream.Failure -> raise (Stream.Error "")
        in
        insert len strm__
    | _ -> insert len strm__
  and find_lparen_aft_star len (strm__ : _ Stream.t) =
    match Stream.peek strm__ with
      Some '(' ->
        Stream.junk strm__;
        begin try while_space (Buff.store len '(') strm__ with
          Stream.Failure -> raise (Stream.Error "")
        end
    | _ -> insert len strm__
  and while_space len (strm__ : _ Stream.t) =
    match Stream.peek strm__ with
      Some ' ' -> Stream.junk strm__; while_space (Buff.store len ' ') strm__
    | Some '\t' ->
        Stream.junk strm__;
        begin try
          while_space (Buff.mstore len (String.make 8 ' ')) strm__
        with Stream.Failure -> raise (Stream.Error "")
        end
    | Some '\n' ->
        Stream.junk strm__; while_space (Buff.store len '\n') strm__
    | Some ')' -> Stream.junk strm__; find_star_bef_rparen_again len strm__
    | _ -> len
  and find_star_bef_rparen_again len (strm__ : _ Stream.t) =
    match Stream.peek strm__ with
      Some '*' -> Stream.junk strm__; insert (Buff.mstore len ")*") strm__
    | _ -> len
  in
  let len = find_comm 0 strm in
  let s = Buff.get len in
  let rec loop i nl_bef ind_bef =
    if i <= 0 then "", 0, 0
    else if s.[i] = '\n' then loop (i - 1) (nl_bef + 1) ind_bef
    else if s.[i] = ' ' then loop (i - 1) nl_bef (ind_bef + 1)
    else
      let s = String.sub s 0 (i + 1) in
      for i = 0 to String.length s / 2 - 1 do
        let t = s.[i] in
        s.[i] <- s.[String.length s - i - 1]; s.[String.length s - i - 1] <- t
      done;
      s, nl_bef, ind_bef
  in
  loop (len - 1) 0 0
;;

let source = ref "";;
let comm_min_pos = ref 0;;

let set_comm_min_pos bp = comm_min_pos := bp;;

let rev_read_comment_in_file bp ep =
  let strm =
    Stream.from
      (fun i ->
         let j = bp - i - 1 in
         if j < !comm_min_pos || j >= String.length !source then None
         else Some !source.[j])
  in
  let (s, nl_bef, ind_bef) = rev_extract_comment strm in
  if s = "" then
    (* heuristic to find the possible comment before 'begin' or left
       parenthesis *)
    let rec loop i =
      let (strm__ : _ Stream.t) = strm in
      match Stream.peek strm__ with
        Some '(' when i = 0 -> Stream.junk strm__; rev_extract_comment strm
      | Some c when c = "begin".[4-i] ->
          Stream.junk strm__;
          if i = String.length "begin" - 1 then rev_extract_comment strm
          else loop (i + 1)
      | _ -> s, nl_bef, ind_bef
    in
    (* heuristic to find the possible comment before 'begin' or left
       parenthesis *)
    loop 0
  else s, nl_bef, ind_bef
;;

let adjust_comment_indentation ind s nl_bef ind_bef =
  if s = "" then ""
  else
    let (ind_aft, i_bef_ind) =
      let rec loop ind_aft i =
        if i >= 0 && s.[i] = ' ' then loop (ind_aft + 1) (i - 1)
        else ind_aft, i
      in
      loop 0 (String.length s - 1)
    in
    let ind_bef = if nl_bef > 0 then ind_bef else ind in
    let len = i_bef_ind + 1 in
    let olen = Buff.mstore 0 (String.make ind ' ') in
    let rec loop olen i =
      if i = len then Buff.get olen
      else
        let olen = Buff.store olen s.[i] in
        let (olen, i) =
          if s.[i] = '\n' && (i + 1 = len || s.[i+1] <> '\n') then
            let delta_ind = if i = i_bef_ind then 0 else ind - ind_bef in
            if delta_ind >= 0 then
              Buff.mstore olen (String.make delta_ind ' '), i + 1
            else
              let i =
                let rec loop cnt i =
                  if cnt = 0 then i
                  else if i = len then i
                  else if s.[i] = ' ' then loop (cnt + 1) (i + 1)
                  else i
                in
                loop delta_ind (i + 1)
              in
              olen, i
          else olen, i + 1
        in
        loop olen i
    in
    loop olen 0
;;

let comm_bef ind loc =
  let ind = ind.ind in
  let bp = Stdpp.first_pos loc in
  let ep = Stdpp.last_pos loc in
  let (s, nl_bef, ind_bef) = rev_read_comment_in_file bp ep in
  adjust_comment_indentation ind s nl_bef ind_bef
;;

(* For pretty printing improvement:
   - if e is a "sequence" or a "let..in sequence", get "the list of its
     expressions", which is flattened (merging sequences inside sequences
     and changing "let..in do {e1; .. en}" into "do {let..in e1; .. en}",
     and return Some "the resulting expression list".
   - otherwise return None *)
let flatten_sequence e =
  let rec get_sequence =
    function
      MLast.ExSeq (_, el) -> Some el
    | MLast.ExLet (_, MLast.VaVal rf, pel, e) as se ->
        begin match get_sequence e with
          Some (e :: el) ->
            let e =
              let loc =
                let loc1 = MLast.loc_of_expr se in
                let loc2 = MLast.loc_of_expr e in Stdpp.encl_loc loc1 loc2
              in
              MLast.ExLet (loc, MLast.VaVal rf, pel, e)
            in
            Some (e :: el)
        | None | _ -> None
        end
    | _ -> None
  in
  match get_sequence e with
    Some el ->
      let rec list_of_sequence =
        function
          e :: el ->
            begin match get_sequence e with
              Some el1 -> list_of_sequence (el1 @ el)
            | None -> e :: list_of_sequence el
            end
        | [] -> []
      in
      Some (list_of_sequence el)
  | None -> None
;;
