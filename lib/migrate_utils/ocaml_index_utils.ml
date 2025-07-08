let fail fmt = Printf.ksprintf failwith fmt

(* Find all the [.ocaml-index] files. *)
let scan_dune_build_path ~dune_build_dir =
  match Sys.is_directory dune_build_dir with
  | (exception Sys_error _) | false ->
      fail "Directory %S not found." dune_build_dir
  | true -> (
      let collect_index_files acc path =
        if Filename.extension path = ".ocaml-index" then path :: acc else acc
      in
      match Fs_utils.scan_dir collect_index_files [] dune_build_dir with
      | [] -> failwith "No index found. Please run 'dune build @ocaml-index'."
      | p -> p)

(* Query a package's lib path using [ocamlfind]. *)
let package_lib_paths packages =
  let cmd = Filename.quote_command "ocamlfind" ("query" :: packages) in
  let ic = Unix.open_process_in cmd in
  let lib_paths = String.trim (In_channel.input_all ic) in
  match Unix.close_process_in ic with
  | WEXITED 0 -> String.split_on_char '\n' lib_paths
  | _ -> fail "Command %S failed." cmd

(* Lookup the uid_map for a unit. *)
let uid_map_of_unit ~packages ~units =
  let open Ocaml_typing in
  let cmts =
    let acc_matching_cmts acc fname =
      let basename = Filename.basename fname in
      let unit_name =
        String.capitalize_ascii (Filename.remove_extension basename)
      in
      if Filename.extension basename = ".cmt" && units unit_name then
        (unit_name, fname) :: acc
      else acc
    in
    (* Lookup [.cmt] files matched by [units]. *)
    package_lib_paths packages
    |> List.fold_left
         (fun acc lib_path ->
           Fs_utils.list_dir lib_path |> Array.fold_left acc_matching_cmts acc)
         []
  in
  let ident_of_decl ~unit_name = function
    | Typedtree.Value { val_id = ident; _ }
    | Type { typ_id = ident; _ }
    | Value_binding { vb_pat = { pat_desc = Tpat_var (ident, _, _); _ }; _ }
    | Constructor { cd_id = ident; _ }
    | Extension_constructor { ext_id = ident; _ }
    | Module { md_id = Some ident; _ }
    | Module_substitution { ms_id = ident; _ }
    | Module_binding { mb_id = Some ident; _ }
    | Module_type { mtd_id = ident; _ }
    | Class { ci_id_class = ident; _ }
    | Class_type { ci_id_class = ident; _ }
    | Label { ld_id = ident; _ } ->
        `Found (unit_name, Ident.name ident)
    | Value_binding { vb_pat = { pat_desc; _ }; _ } -> (
        match Compat.tpat_alias_ident pat_desc with
        | Some ident -> `Found (unit_name, Ident.name ident)
        | None -> `Ignore)
    | Module { md_id = None; _ } | Module_binding { mb_id = None; _ } -> `Ignore
  in
  if cmts = [] then
    failwith ("Found no [.cmt] in packages: " ^ String.concat ", " packages);
  let module Tbl = Shape.Uid.Tbl in
  let tbl = Tbl.create 256 in
  List.iter
    (fun (unit_name, cmt) ->
      let cmt = Cmt_format.read_cmt cmt in
      Tbl.replace tbl
        (Shape.Uid.of_compilation_unit_id (Ident.create_persistent unit_name))
        (`Found (unit_name, ""));
      Tbl.iter
        (fun uid decl -> Tbl.replace tbl uid (ident_of_decl ~unit_name decl))
        cmt.cmt_uid_to_decl)
    cmts;
  fun uid ->
    match Tbl.find_opt tbl uid with
    | Some ((`Found _ | `Ignore) as r) -> r
    | None -> `Not_found

let pp_ocaml_lid ppf lid =
  let open Ocamlformat_utils.Parsing in
  let { Location.txt; loc } = Compat.Ocaml_to_ocamlformat.merlin_lid lid in
  Format.fprintf ppf "@[<hv 2>%s:@ %a@]"
    (Ocamlformat_utils.format_longident txt)
    Location.print_loc loc

(* Read the index files and extract all occurrences of [units]. *)
let extract_occurrences_of_unit ~units ~lookup_ident paths =
  let open Merlin_index_format.Index_format in
  if paths = [] then failwith "Found no index files in '_build'.";
  List.fold_left
    (fun acc file ->
      match read ~file with
      | Index index ->
          Uid_map.fold
            (fun uid locs acc ->
              match lookup_ident uid with
              | `Found ident ->
                  Lid_set.elements locs
                  |> List.fold_left
                       (fun acc lid ->
                         (ident, Compat.Ocaml_to_ocamlformat.merlin_lid lid)
                         :: acc)
                       acc
              | `Ignore -> (* Not a value *) acc
              | `Not_found -> (
                  match uid with
                  | Item it when units it.comp_unit ->
                      Format.eprintf "@[<v 2>No ident for uid %s.%d:@ %a@]@\n%!"
                        it.comp_unit it.id
                        (Format.pp_print_list pp_ocaml_lid)
                        (Lid_set.elements locs);
                      acc
                  | _ -> acc))
            index.defs acc
      | _ -> acc)
    [] paths

let occurrences ~dune_build_dir ~packages ~units =
  let paths = scan_dune_build_path ~dune_build_dir in
  let lookup_ident = uid_map_of_unit ~packages ~units in
  extract_occurrences_of_unit ~units ~lookup_ident paths
