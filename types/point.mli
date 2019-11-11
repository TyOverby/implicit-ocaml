open! Core_kernel

type t =
  { x : float
  ; y : float
  }
[@@deriving sexp, hash]

include Hashable.S with type t := t
include Equal.S with type t := t
