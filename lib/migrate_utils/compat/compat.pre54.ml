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
    | Ldot (a, b) -> Ldot (longident a, b)
    | Lapply (a, b) -> Lapply (longident a, longident b)

  let lid = location_loc longident
  let merlin_lid = lid
end

let tpat_alias_ident = function
  | Ocaml_typing.Typedtree.Tpat_alias (_, ident, _, _) -> Some ident
  | _ -> None

let sub_locs_of_ident _ = []
