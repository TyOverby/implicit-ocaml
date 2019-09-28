type 'a t =
  { ctype : 'a Ctypes.typ
  ; string_repr : string
  }

val float : float t
val int : int t
val bool : bool t
val unit : unit t
val float_array : float Ctypes.ptr t
val to_string : 'a t -> string
