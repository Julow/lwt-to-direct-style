open Ocamlformat_utils.Parsing

module Ocaml_to_ocamlformat = struct
  let location_t { Ocaml_parsing.Location.loc_start; loc_end; loc_ghost } =
    { Location.loc_start; loc_end; loc_ghost }

  let location_loc f { Ocaml_parsing.Location.txt; loc } =
    { Location.txt = f txt; loc = location_t loc }

  let rec longident =
    let open Longident in
    function
    | Ocaml_parsing.Longident.Lident s -> Lident s
    | Ldot (a, b) -> Ldot (longident a.txt, b.txt)
    | Lapply (a, b) -> Lapply (longident a.txt, longident b.txt)

  let lid = location_loc longident

  let merlin_lid l =
    let open Merlin_index_format.Index_format in
    lid (Lid.to_lid l)
end

let tpat_alias_ident = function
  | Ocaml_typing.Typedtree.Tpat_alias (_, ident, _, _, _) -> Some ident
  | _ -> None

let sub_locs_of_ident =
  let rec collect acc = function
    | Longident.Lident _ -> []
    | Ldot (lhs, rhs) -> collect (lhs.loc :: rhs.loc :: acc) lhs.txt
    | Lapply (lhs, rhs) ->
        collect (lhs.loc :: rhs.loc :: collect acc rhs.txt) lhs.txt
  in
  collect []
