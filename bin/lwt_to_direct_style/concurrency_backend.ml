open Ocamlformat_utils.Parsing
open Asttypes
open Parsetree
open Ast_helper
open Ocamlformat_utils.Ast_utils

type t = {
  both : left:expression -> right:expression -> expression;
      (** Transform [Lwt.both]. *)
  pick : expression -> expression;
  join : expression -> expression;
  async : expression -> expression;
  wait : unit -> expression;
  wakeup : expression -> expression -> expression;
  pause : unit -> expression;
  extra_opens : Longident.t list;  (** Opens to add at the top of the module. *)
  choose_comment_hint : string;
  list_parallel : string -> string list option;
      (** Given a function name from [Lwt_list] with the [_p] suffix removed,
          return an identifier. *)
  sleep : expression -> expression;
  with_timeout : expression -> expression -> expression;
  timeout_exn : pattern;
  condition_create : unit -> expression;
  condition_wait : expression -> expression -> expression;
      (** mutex -> condition -> . *)
  cancel_message : string;
  state : expression -> expression;
  mutex_create : unit -> expression;
  mutex_lock : expression -> expression;
  mutex_unlock : expression -> expression;
  mutex_with_lock : expression -> expression -> expression;
  key_new : unit -> expression;
  key_get : expression -> expression;
  key_with_value : expression -> expression -> expression -> expression;
      (** key -> val_opt -> f -> r *)
}

module Eio = struct
  let both ~left ~right = mk_apply_simple [ "Fiber"; "pair" ] [ left; right ]
  let pick lst = mk_apply_simple [ "Fiber"; "any" ] [ lst ]

  let async process_f =
    Comments.add_default_loc "[sw] must be propagated here.";
    Exp.apply
      (mk_exp_ident [ "Fiber"; "fork" ])
      [ (Labelled (mk_loc "sw"), mk_exp_ident [ "sw" ]); (Nolabel, process_f) ]

  let wait () =
    Comments.add_default_loc
      "Translation is incomplete, [Promise.await] must be called on the \
       promise when it's part of control-flow.";
    mk_apply_simple [ "Promise"; "create" ] [ mk_unit_val ]

  let wakeup u arg = mk_apply_simple [ "Promise"; "resolve" ] [ u; arg ]
  let join lst = mk_apply_simple [ "Fiber"; "all" ] [ lst ]
  let pause () = mk_apply_simple [ "Fiber"; "yield" ] [ mk_unit_val ]
  let extra_opens = [ mk_longident' [ "Eio" ] ]
  let choose_comment_hint = "Use Eio.Promise instead. "

  let list_parallel = function
    | ("filter" | "filter_map" | "map" | "iter") as ident ->
        Some [ "Fiber"; "List"; ident ]
    | ident ->
        Comments.add_default_loc
          ("[" ^ ident
         ^ "] can't be translated automatically. See \
            https://ocaml.org/p/eio/latest/doc/Eio/Fiber/List/index.html");
        None

  let sleep d = mk_apply_simple [ "Eio_unix"; "sleep" ] [ d ]

  let with_timeout d f =
    Comments.add_default_loc "[env] must be propagated from the main loop";
    let clock = Exp.send (mk_exp_ident [ "env" ]) (mk_loc "mono_clock") in
    mk_apply_simple [ "Time"; "with_timeout_exn" ] [ clock; d; f ]

  let timeout_exn = Pat.construct (mk_longident [ "Time"; "Timeout" ]) None
end

let eio =
  let open Eio in
  {
    both;
    pick;
    join;
    async;
    pause;
    wait;
    wakeup;
    extra_opens;
    choose_comment_hint;
    list_parallel;
    sleep;
    with_timeout;
    timeout_exn;
    condition_create =
      (fun () ->
        mk_apply_simple [ "Eio"; "Condition"; "create" ] [ mk_unit_val ]);
    condition_wait =
      (fun mutex cond ->
        mk_apply_simple [ "Eio"; "Condition"; "await" ] [ cond; mutex ]);
    cancel_message =
      "Use [Switch] or [Cancel] for defining a cancellable context.";
    state = (fun p -> mk_apply_simple [ "Promise"; "peek" ] [ p ]);
    mutex_create =
      (fun () -> mk_apply_simple [ "Eio"; "Mutex"; "create" ] [ mk_unit_val ]);
    mutex_lock = (fun m -> mk_apply_simple [ "Eio"; "Mutex"; "lock" ] [ m ]);
    mutex_unlock = (fun m -> mk_apply_simple [ "Eio"; "Mutex"; "unlock" ] [ m ]);
    mutex_with_lock =
      (fun t f ->
        mk_apply_ident
          [ "Eio"; "Mutex"; "use_rw" ]
          [
            (mk_lbl "protect", mk_constr_exp "false"); (Nolabel, t); (Nolabel, f);
          ]);
    key_new =
      (fun () -> mk_apply_simple [ "Fiber"; "create_key" ] [ mk_unit_val ]);
    key_get = (fun key -> mk_apply_simple [ "Fiber"; "get" ] [ key ]);
    key_with_value =
      (fun key val_opt f ->
        Exp.apply
          (mk_apply_ident [ "Option"; "fold" ]
             [
               (mk_lbl "none", mk_exp_ident [ "Fiber.without_binding" ]);
               ( mk_lbl "some",
                 mk_apply_simple [ "Fun"; "flip" ]
                   [ mk_exp_ident [ "Fiber.with_binding" ] ] );
               (Nolabel, val_opt);
             ])
          [ (Nolabel, key); (Nolabel, f) ]);
  }
