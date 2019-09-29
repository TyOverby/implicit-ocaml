type t

val create : x:int -> y:int -> t

val apply
  :  t
  -> f:(x:int -> y:int -> float Ctypes.ptr -> int -> 'c)
  -> 'c

module Debug : sig
  val borders : t -> unit
  val values : t -> unit
end
