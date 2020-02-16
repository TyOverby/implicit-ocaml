open! Core_kernel

type t =
  { shape : Shape.t
  ; color : string
  }
[@@deriving sexp]

val create : shape:_ Shape.Type_safe.t -> color:string -> t
val color : t -> string
val shape : t -> Shape.t
