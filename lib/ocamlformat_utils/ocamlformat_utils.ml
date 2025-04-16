open Ocamlformat_lib
open Ocamlformat_format
module Location = Migrate_ast.Location

module Parsing = struct
  include Ocamlformat_ocaml_common
  include Ocamlformat_parser_extended
end

module Ast_utils = Ast_utils
open Parsing

let ( let* ) = Result.bind

(** Trimmed down version of [Translation_unit] that allows to modify the AST. *)
module Trimmed_translation_unit = struct
  open Ocamlformat_lib.Parse_with_comments
  module Cmt = Cmt

  let with_optional_box_debug ~box_debug k =
    if box_debug then Fmt.with_box_debug k else k

  let with_buffer_formatter ~buffer_size k =
    let buffer = Buffer.create buffer_size in
    let fs = Format_.formatter_of_buffer buffer in
    Fmt.eval fs k;
    Format_.pp_print_flush fs ();
    if Buffer.length buffer > 0 then Format_.pp_print_newline fs ();
    Buffer.contents buffer

  let strconst_mapper locs =
    let constant self c =
      match c.Parsetree.pconst_desc with
      | Parsetree.Pconst_string (_, { Location.loc_start; loc_end; _ }, Some _)
        ->
          locs := (loc_start.Lexing.pos_cnum, loc_end.Lexing.pos_cnum) :: !locs;
          c
      | _ -> Ast_mapper.default_mapper.constant self c
    in
    { Ast_mapper.default_mapper with constant }

  let collect_strlocs (type a) (fg : a Extended_ast.t) (ast : a) :
      (int * int) list =
    let locs = ref [] in
    let _ = Extended_ast.map fg (strconst_mapper locs) ast in
    let compare (c1, _) (c2, _) = Stdlib.compare c1 c2 in
    List.sort compare !locs

  let check_remaining_comments cmts =
    let dropped x = { Cmt.kind = `Dropped x; cmt_kind = `Comment } in
    match Cmts.remaining_comments cmts with
    | [] -> Ok ()
    | cmts -> Error (List.map dropped cmts)

  let check_comments (conf : Conf.t) cmts ~old:t_old ~new_:t_new =
    if conf.opr_opts.comment_check.v then
      match
        let* () = check_remaining_comments cmts in
        Normalize_extended_ast.diff_cmts conf t_old.comments t_new.comments
      with
      | Ok () -> ()
      | Error _ -> failwith "Comments changed"

  let check_all_locations fmt cmts_t =
    match Cmts.remaining_locs cmts_t with
    | [] -> ()
    | l ->
        let print l = Format.fprintf fmt "%a\n%!" Location.print_loc l in
        Format.fprintf fmt
          "Warning: Some locations have not been considered\n%!";
        List.iter print (List.sort compare l)

  let format (type ext) (ext_fg : ext Extended_ast.t) ~input_name ~prev_source
      ~ext_parsed (conf : Conf.t) =
    Location.input_name := input_name;
    (* iterate until formatting stabilizes *)
    let rec print_check ~i ~(conf : Conf.t) ~prev_source ext_t =
      let format () =
        let open Fmt in
        let cmts_t =
          Cmts.init ext_fg ~debug:conf.opr_opts.debug.v ext_t.source ext_t.ast
            ext_t.comments
        in
        let contents =
          with_buffer_formatter
            ~buffer_size:(String.length prev_source)
            (set_margin conf.fmt_opts.margin.v
            $ set_max_indent conf.fmt_opts.max_indent.v
            $ fmt_if (not (ext_t.prefix = "")) (str ext_t.prefix $ force_newline)
            $ with_optional_box_debug ~box_debug:false
                (Fmt_ast.fmt_ast ext_fg ~debug:conf.opr_opts.debug.v
                   ext_t.source cmts_t conf ext_t.ast))
        in
        (contents, cmts_t)
      in
      let fmted, cmts_t = format () in
      if String.equal prev_source fmted then (
        if conf.opr_opts.debug.v then
          check_all_locations Format.err_formatter cmts_t;
        let strlocs = collect_strlocs ext_fg ext_t.ast in
        (strlocs, fmted))
      else
        let ext_t_new =
          parse (parse_ast conf) ~disable_w50:true ext_fg conf ~input_name
            ~source:fmted
        in
        check_comments conf cmts_t ~old:ext_t ~new_:ext_t_new;
        (* Too many iteration ? *)
        if i >= conf.opr_opts.max_iters.v then failwith "Unstable formatting"
        else (* All good, continue *)
          print_check ~i:(i + 1) ~conf ~prev_source:fmted ext_t_new
    in
    print_check ~i:1 ~conf ~prev_source ext_parsed

  let parse_and_format (type ext) (ext_fg : ext Extended_ast.t) ~input_name
      ~source ~modify_ast (conf : Conf.t) =
    Location.input_name := input_name;
    let line_endings = conf.fmt_opts.line_endings.v in
    let ext_parsed =
      parse (parse_ast conf) ~disable_w50:true ext_fg conf ~source ~input_name
    in
    let ast, extra_comments = modify_ast ext_parsed.ast in
    let ext_parsed =
      { ext_parsed with ast; comments = extra_comments @ ext_parsed.comments }
    in
    let strlocs, formatted =
      format ext_fg ~input_name ~prev_source:source ~ext_parsed conf
    in
    Eol_compat.normalize_eol ~exclude_locs:strlocs ~line_endings formatted
end

include Trimmed_translation_unit

(* let build_config ~file = *)
(*   Unix.putenv "OCAMLFORMAT" "version-check=false"; *)
(*   match *)
(*     Bin_conf.build_config ~enable_outside_detected_project:true ~root:None ~file *)
(*       ~is_stdin:false *)
(*   with *)
(*   | Ok conf -> *)
(*       let mk v = Conf_t.Elt.make v `Default in *)
(*       { *)
(*         conf with *)
(*         fmt_opts = *)
(*           { *)
(*             conf.fmt_opts with *)
(*             (1* Don't change comments to remove a source of errors and of *)
(*                undesirable changes. *1) *)
(*             parse_docstrings = mk false; *)
(*             wrap_comments = mk false; *)
(*           }; *)
(*         opr_opts = *)
(*           { *)
(*             conf.opr_opts with *)
(*             comment_check = mk false; *)
(*             disable = mk false; *)
(*             version_check = mk false; *)
(*           }; *)
(*       } *)
(*   | Error msg -> failwith msg *)

let build_config ~file:_ =
  let mk v = Conf_t.Elt.make v `Default in
  {
    Conf.default with
    fmt_opts =
      {
        Conf.default.fmt_opts with
        (* Don't change comments to remove a source of errors and of undesirable
           changes. *)
        parse_docstrings = mk false;
        wrap_comments = mk false;
      };
    opr_opts =
      {
        Conf.default.opr_opts with
        comment_check = mk false;
        disable = mk false;
        version_check = mk false;
        margin_check = mk false;
        disable_conf_attrs = mk true;
      };
  }

let error s = Error (`Msg s)

open Parsing.Parsetree

type modify_ast = {
  structure : structure -> structure * Cmt.t list;
  signature : signature -> signature * Cmt.t list;
}

let handle_fmt_exn = function
  | Failure msg | Sys_error msg -> error msg
  | Syntaxerr.Error err ->
      Format.kasprintf error "Syntax error at %a" Location.print_loc
        (Syntaxerr.location_of_error err)
  | exn ->
      Format.kasprintf error "Unhandled exception: %s" (Printexc.to_string exn)

let _format_in_place ast_kind ~file modify_ast =
  try
    let conf = build_config ~file in
    let source = In_channel.with_open_text file In_channel.input_all in
    let fmted =
      parse_and_format ast_kind ~input_name:file ~source ~modify_ast conf
    in
    if String.length fmted = 0 then error "Formatted to 0 length"
    else (
      if not (String.equal fmted source) then
        Out_channel.with_open_bin file (fun oc ->
            Out_channel.output_string oc fmted);
      Ok ())
  with exn -> handle_fmt_exn exn

let format_in_place ~file ~modify_ast =
  let open Extended_ast in
  match Filename.extension file with
  | ".ml" | ".eliom" -> _format_in_place Structure ~file modify_ast.structure
  | ".mli" | ".eliomi" -> _format_in_place Signature ~file modify_ast.signature
  | _ -> error ("Don't know what to do with file " ^ file)

let _parse ext_fg ~input_name =
  let open Ocamlformat_lib.Parse_with_comments in
  let conf = build_config ~file:input_name in
  let source = In_channel.with_open_bin input_name In_channel.input_all in
  let with_comments =
    parse (parse_ast conf) ~disable_w50:true ext_fg conf ~source ~input_name
  in
  with_comments.ast

let parse ~file:input_name =
  Location.input_name := input_name;
  try
    match Filename.extension input_name with
    | ".ml" | ".eliom" -> Ok (`Structure (_parse Structure ~input_name))
    | ".mli" | ".eliomi" -> Ok (`Signature (_parse Signature ~input_name))
    | _ -> error ("Don't know what to do with file " ^ input_name)
  with exn -> handle_fmt_exn exn
