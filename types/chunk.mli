type t [@@deriving sexp]

val create : x:int -> y:int -> t

val apply
  :  t
  -> f:(x:int -> y:int -> float Ctypes.ptr -> int -> 'c)
  -> 'c

val to_underlying : t -> Float_bigarray.t

module Debug : sig
  val borders : t -> unit
  val values : t -> unit
end
