open! Core

type t =
  | Joined of Point.t list
  | Disjoint of Point.t list
[@@deriving sexp]
