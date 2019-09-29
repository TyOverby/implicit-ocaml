type 'a t = 'a Expr_type.t

val typeof : 'a t -> 'a Type.t
val int_lit : int -> int t
val int32_lit : int32 -> int32 t
val float_lit : float -> float t
val bool_lit : bool -> bool t
val neg_int32 : int32 t -> int32 t
val add_int32 : int32 t -> int32 t -> int32 t
val sub_int32 : int32 t -> int32 t -> int32 t
val mul_int32 : int32 t -> int32 t -> int32 t
val div_int32 : int32 t -> int32 t -> int32 t
val max_int32 : int32 t -> int32 t -> int32 t
val min_int32 : int32 t -> int32 t -> int32 t
val add_int : int t -> int t -> int t
val sub_int : int t -> int t -> int t
val mul_int : int t -> int t -> int t
val div_int : int t -> int t -> int t
val add_float : float t -> float t -> float t
val sub_float : float t -> float t -> float t
val mul_float : float t -> float t -> float t
val div_float : float t -> float t -> float t
val sqrt_float : float t -> float t
val sqrt_int32 : int32 t -> int32 t
val square_int32 : int32 t -> int32 t
val array_set : 'a Ctypes.ptr t -> int t -> 'a t -> unit t

val range2
  :  width:int t
  -> height:int t
  -> f:(x:int t -> y:int t -> pos:int t -> unit t)
  -> unit t

val eq_int : int t -> int t -> bool t
val cond : bool t -> 'a t -> 'a t -> 'a t
val int_to_float : int t -> float t
val int_to_int32 : int t -> int32 t
val int32_to_float : int32 t -> float t
val float_to_int : float t -> int t
val float_to_int32 : float t -> int32 t
val progn : unit t list -> 'a t -> 'a t
