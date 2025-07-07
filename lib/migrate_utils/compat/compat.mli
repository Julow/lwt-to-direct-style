module Ocaml_to_ocamlformat : sig
  (** Convert from OCaml [Parsing] values that Merlin uses to the corresponding
      Ocamlformat type. *)

  open Ocamlformat_utils.Parsing

  val lid :
    Ocaml_parsing.Longident.t Ocaml_parsing.Location.loc ->
    Longident.t Location.loc

  val merlin_lid :
    Merlin_index_format.Index_format.Lid.t -> Longident.t Location.loc
end

(* [tpat_alias_ident tpat] returns [Some ident] if [tpat] is [Tpat_alias _],
   [None] otherwise. *)
val tpat_alias_ident :
  Ocaml_typing.Typedtree.value Ocaml_typing.Typedtree.pattern_desc ->
  Ocaml_typing.Ident.t option
