open! Core_kernel

type t [@@deriving sexp]

val address_of : t -> float Ctypes.ptr
val length : t -> int
val create : int -> t
val get : t -> int -> float
val to_array : t -> float array
val of_array : float array -> t
