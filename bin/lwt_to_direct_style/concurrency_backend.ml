open Ocamlformat_utils.Parsing
open Asttypes
open Parsetree
open Ast_helper
open Ocamlformat_utils.Ast_utils

let eio add_comment =
  let used_eio_std = ref false in
  let fiber_ident i =
    used_eio_std := true;
    [ "Fiber"; i ]
  in
  let promise_ident i =
    used_eio_std := true;
    [ "Promise"; i ]
  in
  let add_comment fmt = Format.kasprintf add_comment fmt in
  let add_comment_dropped_exp ~label exp =
    add_comment "Dropped expression (%s): [%s]." label
      (Ocamlformat_utils.format_expression exp)
  in
  object
    method both ~left ~right =
      mk_apply_simple (fiber_ident "pair") [ left; right ]

    method pick lst = mk_apply_simple (fiber_ident "any") [ lst ]

    method async process_f =
      add_comment "[sw] must be propagated here.";
      Exp.apply
        (mk_exp_ident (fiber_ident "fork"))
        [
          (Labelled (mk_loc "sw"), mk_exp_ident [ "sw" ]); (Nolabel, process_f);
        ]

    method wait () =
      add_comment
        "Translation is incomplete, [Promise.await] must be called on the \
         promise when it's part of control-flow.";
      mk_apply_simple (promise_ident "create") [ mk_unit_val ]

    method wakeup u arg = mk_apply_simple (promise_ident "resolve") [ u; arg ]
    method join lst = mk_apply_simple (fiber_ident "all") [ lst ]
    method pause () = mk_apply_simple (fiber_ident "yield") [ mk_unit_val ]

    method extra_opens =
      if !used_eio_std then [ mk_longident' [ "Eio"; "Std" ] ] else []

    method choose_comment_hint = "Use Eio.Promise instead. "

    method list_parallel =
      function
      | ("filter" | "filter_map" | "map" | "iter") as ident ->
          Some (fiber_ident "List" @ [ ident ])
      | ident ->
          add_comment
            "[%s] can't be translated automatically. See \
             https://ocaml.org/p/eio/latest/doc/Eio/Fiber/List/index.html"
            ident;
          None

    method sleep d = mk_apply_simple [ "Eio_unix"; "sleep" ] [ d ]

    method with_timeout d f =
      add_comment "[env] must be propagated from the main loop";
      let clock = Exp.send (mk_exp_ident [ "env" ]) (mk_loc "mono_clock") in
      mk_apply_simple [ "Eio"; "Time"; "with_timeout_exn" ] [ clock; d; f ]

    method timeout_exn = mk_longident [ "Eio"; "Time"; "Timeout" ]

    method condition_create () =
      mk_apply_simple [ "Eio"; "Condition"; "create" ] [ mk_unit_val ]

    method condition_wait mutex cond =
      mk_apply_simple [ "Eio"; "Condition"; "await" ] [ cond; mutex ]

    method condition_type param =
      (match param.ptyp_desc with
      | Ptyp_constr ({ txt = Lident "unit"; _ }, []) -> ()
      | _ ->
          add_comment
            "Eio conditions don't carry a value. Use a mutable variable and a \
             dedicated mutex.");
      mk_typ_constr [ "Eio"; "Condition"; "t" ]

    method cancel_message =
      "Use [Switch] or [Cancel] for defining a cancellable context."

    method state p = mk_apply_simple (promise_ident "peek") [ p ]

    method mutex_create () =
      mk_apply_simple [ "Eio"; "Mutex"; "create" ] [ mk_unit_val ]

    method mutex_lock m = mk_apply_simple [ "Eio"; "Mutex"; "lock" ] [ m ]
    method mutex_unlock m = mk_apply_simple [ "Eio"; "Mutex"; "unlock" ] [ m ]

    method mutex_with_lock t f =
      mk_apply_ident
        [ "Eio"; "Mutex"; "use_rw" ]
        [
          (mk_lbl "protect", mk_constr_exp [ "false" ]);
          (Nolabel, t);
          (Nolabel, f);
        ]

    method key_new () =
      mk_apply_simple (fiber_ident "create_key") [ mk_unit_val ]

    method key_get key = mk_apply_simple (fiber_ident "get") [ key ]

    method key_with_value key val_opt f =
      Exp.apply
        (mk_apply_ident [ "Option"; "fold" ]
           [
             (mk_lbl "none", mk_exp_ident (fiber_ident "without_binding"));
             ( mk_lbl "some",
               mk_apply_simple [ "Fun"; "flip" ]
                 [ mk_exp_ident (fiber_ident "with_binding") ] );
             (Nolabel, val_opt);
           ])
        [ (Nolabel, key); (Nolabel, f) ]

    method promise_type param =
      mk_typ_constr ~params:[ param ] (promise_ident "t")

    method direct_style_type param = param

    method of_unix_file_descr ?blocking fd =
      add_comment "[sw] must be propagated here.";
      let blocking_arg =
        let lbl = mk_loc "blocking" in
        match blocking with
        | Some (expr, `Lbl) -> [ (Labelled lbl, expr) ]
        | Some (expr, `Opt) -> [ (Optional lbl, expr) ]
        | None -> []
      in
      mk_apply_ident
        [ "Eio_unix"; "Fd"; "of_unix" ]
        ([ (Labelled (mk_loc "sw"), mk_exp_ident [ "sw" ]) ]
        @ blocking_arg
        @ [
            (Labelled (mk_loc "close_unix"), mk_constr_exp [ "true" ]);
            (Nolabel, fd);
          ])

    method io_read input buffer buf_offset buf_len =
      add_comment "[%s] should be a [Cstruct.t]."
        (Ocamlformat_utils.format_expression buffer);
      add_comment_dropped_exp ~label:"buffer offset" buf_offset;
      add_comment_dropped_exp ~label:"buffer length" buf_len;
      mk_apply_simple [ "Eio"; "Flow"; "single_read" ] [ input; buffer ]

    method fd_close fd = mk_apply_simple [ "Eio_unix"; "Fd" ] [ fd ]

    method main_run promise =
      add_comment
        "[Eio_main.run] argument used to be a [Lwt] promise and is now a \
         [fun]. Make sure no asynchronous or IO calls are done outside of this \
         [fun].";
      mk_apply_simple [ "Eio_main"; "run" ]
        [ mk_fun ~arg_name:"env" (fun _env -> promise) ]

    method input_io_of_fd fd =
      Exp.constraint_
        (mk_apply_simple [ "Eio_unix"; "Net"; "import_socket_stream" ] [ fd ])
        (mk_typ_constr
           ~params:
             [ mk_poly_variant [ ("R", []); ("Flow", []); ("Close", []) ] ]
           [ "Std"; "r" ])

    method output_io_of_fd fd =
      add_comment
        "This creates a closeable [Flow.sink] resource but write operations \
         are rewritten to calls to [Buf_write].\n\
        \        You might want to use [Buf_write.with_flow sink (fun \
         buf_write -> ...)].";
      Exp.constraint_
        (mk_apply_simple [ "Eio_unix"; "Net"; "import_socket_stream" ] [ fd ])
        (mk_typ_constr
           ~params:
             [ mk_poly_variant [ ("W", []); ("Flow", []); ("Close", []) ] ]
           [ "Std"; "r" ])

    method io_write_str chan str =
      mk_apply_simple [ "Eio"; "Buf_write"; "string" ] [ chan; str ]

    method type_out_channel = mk_typ_constr [ "Eio"; "Buf_write"; "t" ]
  end
