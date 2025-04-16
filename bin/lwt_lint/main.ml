open Ocamlformat_utils.Parsing
open Parsetree

let error_count = ref 0

let warn ~loc fmt =
  let { Location.loc_start = p; _ } = loc in
  incr error_count;
  Format.eprintf
    ("@[<hv 2>%s:%d:%d@;<2 0>" ^^ fmt ^^ "@]@\n")
    p.pos_fname p.pos_lnum (p.pos_cnum - p.pos_bol)

let lint_ignore_pat ignore_ident loc =
  warn ~loc
    "Ignored value without a type annotation. Patterns %S ignores a value that \
     might be a Lwt promise."
    ignore_ident

let lint_value_binding pvb =
  match (pvb.pvb_pat.ppat_desc, pvb.pvb_constraint) with
  | Ppat_any, None -> lint_ignore_pat "_" pvb.pvb_loc
  | Ppat_var var, None when String.starts_with ~prefix:"_" var.txt ->
      lint_ignore_pat var.txt pvb.pvb_loc
  | _ -> ()

let lint_structure_item stri =
  match stri.pstr_desc with
  | Pstr_value { pvbs_bindings; _ } ->
      List.iter lint_value_binding pvbs_bindings
  | _ -> ()

let lint_mapper =
  let default = Ast_mapper.default_mapper in
  let structure_item m stri =
    lint_structure_item stri;
    default.structure_item m stri
  in
  { default with structure_item }

let lint_file file =
  match Ocamlformat_utils.parse ~file with
  | Ok (`Structure str) -> ignore (lint_mapper.structure lint_mapper str)
  | Ok (`Signature sg) -> ignore (lint_mapper.signature lint_mapper sg)
  | Error (`Msg msg) ->
      Format.eprintf "%s: %s\n%!" file msg;
      incr error_count

let main paths =
  error_count := 0;
  List.iter (Fs_utils.find_ml_files lint_file) paths;
  Format.printf "%d errors\n%!" !error_count;
  if !error_count > 0 then exit 1

open Cmdliner

let pos_inputs =
  let doc = "Path to files or directories to lint." in
  Arg.(non_empty & pos_all file [] & info ~doc ~docv:"PATH" [])

let cmd =
  let doc = "Lint code that might cause implicit forking in Lwt." in
  let info = Cmd.info "lwt-lint" ~version:"%%VERSION%%" ~doc in
  Cmd.v info Term.(const main $ pos_inputs)

let () = exit (Cmd.eval cmd)
