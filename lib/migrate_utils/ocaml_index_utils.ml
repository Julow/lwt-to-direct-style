let fail fmt = Printf.ksprintf failwith fmt

(** Convert from OCaml [Parsing] values that Merlin uses to the corresponding
    Ocamlformat type. *)
module Ocaml_to_ocamlformat = struct
  open Ocamlformat_utils.Parsing

  let location_t { Ocaml_parsing.Location.loc_start; loc_end; loc_ghost } =
    { Location.loc_start; loc_end; loc_ghost }

  let location_loc f { Ocaml_parsing.Location.txt; loc } =
    { Location.txt = f txt; loc = location_t loc }

  let rec longident =
    let open Longident in
    function
    | Ocaml_parsing.Longident.Lident s -> Lident s
    | Ldot (a, b) -> Ldot (longident a, b)
    | Lapply (a, b) -> Lapply (longident a, longident b)

  let lid = location_loc longident
end

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
    | Value_binding
        { vb_pat = { pat_desc = Tpat_alias (_, ident, _, _); _ }; _ }
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
    | Value_binding { vb_pat = { pat_desc = _; _ }; _ }
    | Module { md_id = None; _ }
    | Module_binding { mb_id = None; _ } ->
        `Ignore
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

let pp_ocaml_lid ppf { Ocaml_parsing.Location.txt; loc } =
  let open Ocaml_parsing in
  Format.fprintf ppf "@[<hv 2>%a:@ %a@]" Pprintast.longident txt
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
                  Lid_set.fold
                    (fun loc acc ->
                      (ident, Ocaml_to_ocamlformat.lid loc) :: acc)
                    locs acc
              | `Ignore -> (* Not a value *) acc
              | `Not_found -> (
                  match uid with
                  | Item { comp_unit; id } when units comp_unit ->
                      Format.eprintf "@[<v 2>No ident for uid %s.%d:@ %a@]@\n%!"
                        comp_unit id
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
