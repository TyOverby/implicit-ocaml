open! Core_kernel

type t =
  { shape : Shape.t
  ; color : string
  }
[@@deriving fields, sexp]

let create ~shape = Fields.create ~shape:(Shape.of_type_safe shape)
