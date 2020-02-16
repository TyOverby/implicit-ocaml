type t [@@deriving sexp]

val create : width:int -> height:int -> x:int -> y:int -> t
val width : t -> int
val height : t -> int
val x : t -> int
val y : t -> int
val to_underlying : t -> Float_bigarray.t

module Debug : sig
  val borders : t -> unit
  val values : t -> unit
end
