open! Core

type t =
  { x : float
  ; y : float
  }
[@@deriving sexp]

include Hashable.S with type t := t
include Comparable.S with type t := t
include Equal.S with type t := t
