type 'a t =
  | Var : 'a Type.t * Id.t -> 'a t
  | Int_lit : int -> int t
  | Int32_lit : int32 -> int32 t
  | Bool_lit : bool -> bool t
  | Float_lit : float -> float t
  | Add_float : float t * float t -> float t
  | Sub_float : float t * float t -> float t
  | Mul_float : float t * float t -> float t
  | Div_float : float t * float t -> float t
  | Sqrt_float : float t -> float t
  | Sqrt_int32 : int32 t -> int32 t
  | Square_int32 : int32 t -> int32 t
  | Add_int : int t * int t -> int t
  | Sub_int : int t * int t -> int t
  | Mul_int : int t * int t -> int t
  | Div_int : int t * int t -> int t
  | Neg_int32 : int32 t -> int32 t
  | Add_int32 : int32 t * int32 t -> int32 t
  | Sub_int32 : int32 t * int32 t -> int32 t
  | Mul_int32 : int32 t * int32 t -> int32 t
  | Div_int32 : int32 t * int32 t -> int32 t
  | Min_int32 : int32 t * int32 t -> int32 t
  | Max_int32 : int32 t * int32 t -> int32 t
  | Int_to_float : int t -> float t
  | Int_to_int32 : int t -> int32 t
  | Int32_to_float : int32 t -> float t
  | Float_to_int : float t -> int t
  | Float_to_int32 : float t -> int32 t
  | Eq_int : int t * int t -> bool t
  | Array_set : 'a Ctypes.ptr t * int t * 'a t -> unit t
  | Range2 :
      { width : int t
      ; height : int t
      ; f : x:int t -> y:int t -> pos:int t -> unit t
      }
      -> unit t
  | Progn : 'a Type.t * unit t list * 'a t -> 'a t
  | Cond : 'a Type.t * bool t * 'a t * 'a t -> 'a t
