open! Core

type t =
  { layers : Layer.t list
  ; target_width : int
  ; target_height : int
  ; padding : int
  }
[@@deriving sexp]

val create
  :  layers:Layer.t list
  -> target_width:int
  -> target_height:int
  -> padding:int
  -> t

val layers : t -> Layer.t list
val target_width : t -> int
val target_height : t -> int
val padding : t -> int
