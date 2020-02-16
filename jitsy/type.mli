type 'a my_array = 'a Ctypes.ptr

type 'a t =
  { ctype : 'a Ctypes.typ
  ; string_repr : string
  }

val float : float t
val int : int t
val int32 : int32 t
val uint32 : Unsigned.uint32 t
val bool : bool t
val unit : unit t
val float_array : float my_array t
val int32_array : int my_array t
val to_string : 'a t -> string
