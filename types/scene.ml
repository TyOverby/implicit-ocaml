open! Core_kernel

type t =
  { layers : Layer.t list
  ; target_width : int
  ; target_height : int
  ; padding : int
  }
[@@deriving fields, sexp]

let create = Fields.create
