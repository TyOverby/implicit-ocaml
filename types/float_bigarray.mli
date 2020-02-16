open! Core_kernel

type t =
  (float, Bigarray.float32_elt, Bigarray.c_layout) Bigarray.Array1.t

val t_of_sexp : Sexp.t -> t
val sexp_of_t : t -> Sexp.t
val length : t -> int
val create : int -> t
val get : t -> int -> float
val to_array : t -> float array
val of_array : float array -> t
val sub : t -> int -> int -> t
