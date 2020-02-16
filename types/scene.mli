open! Core_kernel

type t =
  { layers : Layer.t list
  ; target_width : int
  ; target_height : int
  }
[@@deriving fields]
