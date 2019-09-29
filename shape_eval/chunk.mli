type t

val create : unit -> t
val apply : t -> f:(int32 Ctypes.ptr -> int -> 'c) -> 'c
val debug : t -> unit
