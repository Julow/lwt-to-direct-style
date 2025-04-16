module Parsing : sig
  (** OCamlformat's version of OCaml's parsing modules *)

  include module type of Ocamlformat_ocaml_common
  include module type of Ocamlformat_parser_extended
end

module Cmt = Ocamlformat_lib.Cmt

module Ast_utils : module type of Ast_utils
(** Utility functions for contructing AST nodes. *)

open Parsing.Parsetree

type modify_ast = {
  structure : structure -> structure * Cmt.t list;
  signature : signature -> signature * Cmt.t list;
}

val format_in_place :
  file:string -> modify_ast:modify_ast -> (unit, [ `Msg of string ]) result
(** Format the content of and overwrite [file]. [modify_ast] can be used to
    apply any change to the program. Raises [Failure] and [Sys_error]. *)

val parse :
  file:string ->
  ( [ `Structure of structure | `Signature of signature ],
    [ `Msg of string ] )
  result
(** Parse an ocaml file. *)
