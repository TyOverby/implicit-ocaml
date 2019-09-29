type t

val create : x:int32 -> y:int32 -> t

val apply
  :  t
  -> f:(x:int32 -> y:int32 -> int32 Ctypes.ptr -> int -> 'c)
  -> 'c

module Debug : sig
  val borders : t -> unit
  val values : t -> unit
end
