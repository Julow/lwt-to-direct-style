open Ocamlformat_ocaml_common
open Ocamlformat_parser_extended
open Asttypes
open Parsetree
open Ast_helper

let mk_loc ?(loc = !default_loc) txt = { Location.txt; loc }

let mk_function_param ?(loc = !default_loc) ?(lbl = Nolabel) ?def pat =
  { pparam_loc = loc; pparam_desc = Pparam_val (lbl, def, pat) }

let mk_let' ?(loc_in = !default_loc) ?(rec_ = Nonrecursive) bindings rhs =
  let bindings = { pvbs_bindings = bindings; pvbs_rec = rec_ } in
  Exp.let_ ~loc_in bindings rhs

let mk_let ?loc_in ?rec_ ?(is_pun = false) ?value_constraint pat ?(args = [])
    lhs rhs =
  let binding = Vb.mk ~is_pun ?value_constraint pat args (Pfunction_body lhs) in
  mk_let' ?loc_in ?rec_ [ binding ] rhs

let mk_function_cases ?(loc = !default_loc) ?(attrs = []) cases =
  Exp.function_ [] None (Pfunction_cases (cases, loc, attrs))

let mk_longident' = function
  | [] -> assert false
  | hd :: tl ->
      let open Longident in
      List.fold_left (fun acc seg -> Ldot (acc, seg)) (Lident hd) tl

let mk_longident ident = mk_loc (mk_longident' ident)
let mk_constr_exp ?arg cstr = Exp.construct (mk_longident cstr) arg

let mk_constr_pat ?arg cstr =
  Pat.construct (mk_longident cstr) (Option.map (fun a -> ([], a)) arg)

let mk_variant_exp ?arg cstr = Exp.variant (mk_loc (mk_loc cstr)) arg
let mk_variant_pat ?arg cstr = Pat.variant (mk_loc (mk_loc cstr)) arg
let same_longident a b = Longident.flatten a = b
let mk_exp_ident ident = Exp.ident (mk_longident ident)
let mk_exp_var s = mk_exp_ident [ s ]
let mk_unit_ident = mk_longident [ "()" ]
let mk_unit_pat = Pat.construct mk_unit_ident None
let mk_unit_arg = mk_function_param mk_unit_pat
let mk_unit_val = Exp.construct mk_unit_ident None
let mk_thunk body = Exp.function_ [ mk_unit_arg ] None (Pfunction_body body)
let mk_some_ident = mk_longident [ "Some" ]
let mk_none_ident = mk_longident [ "None" ]
let mk_exp_some x = Exp.construct mk_some_ident (Some x)
let mk_exp_none = Exp.construct mk_none_ident None
let mk_typ_constr ?(params = []) lid = Typ.constr (mk_longident lid) params
let mk_lbl s = Labelled (mk_loc s)
let mk_lblopt s = Optional (mk_loc s)
let mk_pat_some arg = mk_constr_pat ~arg [ "Some" ]
let mk_pat_none = mk_constr_pat [ "None" ]

let mk_row_field ?(loc = !default_loc) ?(attrs = []) desc =
  { Parsetree.prf_desc = desc; prf_loc = loc; prf_attributes = attrs }

let mk_poly_variant ?(open_ = false) ?labels ?(inherit_ = []) vars =
  let mk_rtag (var, args) =
    mk_row_field (Rtag (mk_loc (mk_loc var), List.is_empty args, args))
  in
  let mk_inherit t = mk_row_field (Rinherit t) in
  let flag = if open_ then Open else Closed in
  let constrs = List.map mk_rtag vars @ List.map mk_inherit inherit_ in
  Typ.variant constrs flag labels

(* Exp *)

let mk_const_string s = Exp.constant (Const.string s)
let mk_const_int i = Exp.constant (Const.integer i)

(* Construct [let var = lhs in (rhs var)]. *)
let mk_let_var ident lhs rhs =
  let pat = Pat.var (mk_loc ident) in
  mk_let pat lhs (rhs (mk_exp_var ident))

module Mk_function : sig
  (** Construct a [fun .. -> ..] node. Usage:

      {[
        let f =
          let open Mk_function in
          mk_function
            (return (fun a b -> Exp.tuple [ a; b ])
             $ arg "a" $ arg "b")
        in
      ]} *)

  type 'a t
  type arg

  val arg : ?lbl:[ `Lbl | `Opt of expression option ] -> string -> arg
  val ( $ ) : (expression -> 'a) t -> arg -> 'a t
  val return : 'a -> 'a t
  val mk_function : ?typ:type_constraint -> expression t -> expression
end = struct
  type 'a t = expr_function_param list * 'a
  type arg = expr_function_param * expression

  let ( $ ) (params, body) (param, exp) = (param :: params, body exp)
  let return f = ([], f)

  let arg ?lbl name =
    let lbl, def =
      match lbl with
      | Some `Lbl -> (Some (mk_lbl name), None)
      | Some (`Opt def) -> (Some (mk_lblopt name), def)
      | None -> (None, None)
    in
    let exp = mk_exp_var name and pat = Pat.var (mk_loc name) in
    (mk_function_param ?lbl ?def pat, exp)

  let mk_function ?typ (params, body) =
    Exp.function_ (List.rev params) typ (Pfunction_body body)
end

let mk_fun ?(arg_name = "x") f =
  let open Mk_function in
  mk_function (return f $ arg arg_name)

let is_unit_val = function
  | { pexp_desc = Pexp_construct (ident, None); _ } ->
      same_longident ident.txt [ "()" ]
  | _ -> false

let mk_if if_cond if_body else_body =
  let mk_if_cond ?(loc_then = !default_loc) ?(attrs = []) if_cond if_body =
    { if_cond; if_body; if_attrs = attrs; if_loc_then = loc_then }
  in
  Exp.ifthenelse [ mk_if_cond if_cond if_body ] (Some (else_body, !default_loc))

let mk_binding_op ?(loc = !default_loc) ?(is_pun = false) op pat ?(args = [])
    ?(typ = None) exp =
  Exp.binding_op op pat args typ exp is_pun loc

(* Generates a [Pexp_ident] when [args] is the empty list. *)
let mk_apply_ident ident args =
  let ident = mk_exp_ident ident in
  match args with [] -> ident | _ -> Exp.apply ident args

let mk_apply_simple f_ident args =
  mk_apply_ident f_ident (List.map (fun x -> (Nolabel, x)) args)

(** Generate an expression that read the value of a optional argument obtained
    with [Unpack_apply.take_lblopt]. *)
let value_of_lblopt ~default arg =
  match arg with
  | Some (exp, `Lbl) -> exp
  | Some (exp, `Opt) ->
      Exp.match_ exp
        [
          Exp.case (mk_pat_some (Pat.var (mk_loc "x"))) (mk_exp_var "x");
          Exp.case mk_pat_none default;
        ]
  | None -> default

(** Flatten a pipelines composed of [|>] and [@@] into a [Pexp_apply] node. *)
let rec flatten_apply exp =
  let flatten callee arg =
    let callee, prefix_args =
      match (flatten_apply callee).pexp_desc with
      | Pexp_apply (callee, prefix_args) -> (callee, prefix_args)
      | _ -> (callee, [])
    in
    Exp.apply callee (prefix_args @ [ (Nolabel, arg) ])
  in
  match exp.pexp_desc with
  | Pexp_infix ({ txt = "@@"; _ }, lhs, rhs) -> flatten lhs rhs
  | Pexp_infix ({ txt = "|>"; _ }, lhs, rhs) -> flatten rhs lhs
  | _ -> exp

(** Rewrite expressions that look like an apply by calling
    [f ~loc longident args]. Returns [None] for other expressions. Expressions
    that are treated as an apply:
    - [Pexp_apply], obviously.
    - Pipelines composed of [|>] and [@@].
    - [Pexp_ident], interpreted as an apply with no arguments.
    - [Pexp_infix], warning, Longident node doesn't appear in the parsetree.
    - [Pexp_construct], as they cannot be confused with regular identifiers
      thanks to their capital letter. *)
let rewrite_apply exp f =
  match (flatten_apply exp).pexp_desc with
  | Pexp_apply ({ pexp_desc = Pexp_ident lid; pexp_attributes = []; _ }, args)
    ->
      f lid args
  | Pexp_ident lid -> f lid []
  | Pexp_infix (op, lhs, rhs) ->
      let args = [ (Nolabel, lhs); (Nolabel, rhs) ] in
      let lid = { op with txt = mk_longident' [ op.txt ] } in
      f lid args
  | Pexp_construct (lid, Some arg) -> f lid [ (Nolabel, arg) ]
  | Pexp_construct (lid, None) -> f lid []
  | _ -> None

module Unpack_apply : sig
  type t

  val unapply : (arg_label * expression) list -> t -> expression option
  (** Decode a list of arguments matching a sequence of [take] instructions
      ending in a [return]. If the argument list is smaller than expected, a
      function node is generated to respect the arity and allow the expression
      to be rewritten. Return [None] if the argument list couldn't be unapplied.
  *)

  val take : (expression -> t) -> t
  (** Accept one argument. *)

  val take_lbl : string -> (expression -> t) -> t
  (** Accept a labelled argument. It's safer to accept all the labelled
      arguments first before accepting any unlabelled argument. *)

  val take_lblopt : string -> ((expression * [ `Opt | `Lbl ]) option -> t) -> t
  (** Accept an optional labelled argument. [`Opt] indicates that the passed
      value is an option passed using [?lbl:...] and [`Lbl] indicates that the
      value is passed as [~lbl:...]. See [take_lbl]. *)

  val take_all : ((arg_label * expression) list -> expression option) -> t
  (** Accept all remaining arguments. *)

  val return : expression option -> t
  (** Stop accepting arguments. [return (Some exp)] rewrites the apply
      expression to [exp] while [return None] leaves the original expression.
      The "too many arguments" warning is not triggered with [return None]. *)
end = struct
  type t =
    | Arg of (expression -> t)
    | Label of string * (expression -> t)
    | Label_opt of string * ((expression * [ `Opt | `Lbl ]) option -> t)
    | Take_all of ((arg_label * expression) list -> expression option)
    | End of expression option

  let rec apply_remaining_args params i = function
    | Arg k -> apply_remaining_next params i Nolabel k
    | Label (lbl, k) -> apply_remaining_next params i (Labelled (mk_loc lbl)) k
    | Label_opt (lbl, k) ->
        apply_remaining_next params i
          (Optional (mk_loc lbl))
          (fun arg -> k (Some (arg, `Opt)))
    | End r -> apply_remaining_end params r
    | Take_all k -> apply_remaining_end params (k [])

  and apply_remaining_next params i lbl k =
    let ident = "x" ^ string_of_int i in
    let new_param = mk_function_param ~lbl (Pat.var (mk_loc ident)) in
    let expr = mk_exp_ident [ ident ] in
    apply_remaining_args (new_param :: params) (i + 1) (k expr)

  and apply_remaining_end params r =
    match (r, params) with
    | _, [] | None, _ -> r
    | Some body, _ :: _ ->
        Some (Exp.function_ (List.rev params) None (Pfunction_body body))

  let find_label args lbl =
    List.partition
      (function
        | (Labelled lbl' | Optional lbl'), _ -> lbl'.txt <> lbl | _ -> true)
      args

  let rec unapply args t =
    match (args, t) with
    | (Nolabel, arg) :: args_tl, Arg k -> unapply args_tl (k arg)
    | _, End None -> None
    | [], t -> apply_remaining_args [] 1 t
    | args, Take_all k -> k args
    | args, Label (lbl, k) -> (
        match find_label args lbl with
        | _, [] ->
            Format.eprintf "Error: Label %S expected but not found" lbl;
            None
        | args_tl, (_, arg) :: _ -> unapply args_tl (k arg))
    | args, Label_opt (lbl, k) -> (
        match find_label args lbl with
        | args_tl, (Labelled _, arg) :: _ ->
            unapply args_tl (k (Some (arg, `Lbl)))
        | args_tl, (Optional _, arg) :: _ ->
            unapply args_tl (k (Some (arg, `Opt)))
        | _ -> unapply args (k None))
    | ((Labelled lbl | Optional lbl), _) :: _, Arg _ ->
        Format.eprintf "Error: Unexpected label %S at %a\n%!" lbl.txt
          Printast.fmt_location lbl.loc;
        None
    | (_, arg) :: _, End (Some _) ->
        Format.eprintf "Error: Too many arguments at %a\n%!"
          Printast.fmt_location arg.pexp_loc;
        None

  let take k = Arg k
  let take_lbl lbl k = Label (lbl, k)
  let take_lblopt lbl k = Label_opt (lbl, k)
  let take_all k = Take_all k
  let return r = End r
end
