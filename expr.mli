type 'a t =
  | Var : 'a Ctypes_static.typ * Id.t -> 'a t
  | Int_lit : int -> int t
  | Bool_lit : bool -> bool t
  | Float_lit : float -> float t
  | Add_float : float t * float t -> float t
  | Sub_float : float t * float t -> float t
  | Mul_float : float t * float t -> float t
  | Div_float : float t * float t -> float t
  | Add_int : int t * int t -> int t
  | Sub_int : int t * int t -> int t
  | Mul_int : int t * int t -> int t
  | Div_int : int t * int t -> int t
  | Int_to_float : int t -> float t
  | Float_to_int : float t -> int t
  | Eq_int : int t * int t -> bool t
  | Cond : 'a Ctypes_static.typ * bool t * 'a t * 'a t -> 'a t

val typeof : 'a t -> 'a Ctypes_static.typ
val int_lit : int -> int t
val float_lit : float -> float t
val bool_lit : bool -> bool t
val add_int : int t -> int t -> int t
val sub_int : int t -> int t -> int t
val mul_int : int t -> int t -> int t
val div_int : int t -> int t -> int t
val add_float : float t -> float t -> float t
val sub_float : float t -> float t -> float t
val mul_float : float t -> float t -> float t
val div_float : float t -> float t -> float t
val eq_int : int t -> int t -> bool t
val cond : bool t -> 'a t -> 'a t -> 'a t
val int_to_float : int t -> float t
val float_to_int : float t -> int t
