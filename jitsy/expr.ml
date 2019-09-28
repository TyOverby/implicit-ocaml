type 'a t =
  | Var : 'a Type.t * Id.t -> 'a t
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
  | Array_set : 'a Ctypes.ptr t * int t * 'a t -> unit t
  | Progn : 'a Type.t * unit t list * 'a t -> 'a t
  | Cond : 'a Type.t * bool t * 'a t * 'a t -> 'a t

let rec typeof (type a) : a t -> a Type.t = function
  | Var (typ, _) -> typ
  | Int_lit _ -> Type.int
  | Float_lit _ -> Type.float
  | Bool_lit _ -> Type.bool
  | Add_int _ -> Type.int
  | Sub_int _ -> Type.int
  | Div_int _ -> Type.int
  | Mul_int _ -> Type.int
  | Add_float _ -> Type.float
  | Sub_float _ -> Type.float
  | Mul_float _ -> Type.float
  | Div_float _ -> Type.float
  | Eq_int (_, _) -> Type.bool
  | Int_to_float _ -> Type.float
  | Float_to_int _ -> Type.int
  | Array_set _ -> Type.unit
  | Progn (c, _, _) -> c
  | Cond (c, _, _, _) -> c

and int_lit i = Int_lit i
and float_lit i = Float_lit i
and bool_lit i = Bool_lit i
and add_int a b = Add_int (a, b)
and sub_int a b = Sub_int (a, b)
and div_int a b = Div_int (a, b)
and mul_int a b = Mul_int (a, b)
and add_float a b = Add_float (a, b)
and sub_float a b = Sub_float (a, b)
and mul_float a b = Mul_float (a, b)
and div_float a b = Div_float (a, b)
and eq_int a b = Eq_int (a, b)
and int_to_float a = Int_to_float a
and float_to_int a = Float_to_int a
and array_set a b c = Array_set (a, b, c)

and progn l a =
  let typ = typeof a in
  Progn (typ, l, a)

and cond c t f =
  let typ = typeof t in
  Cond (typ, c, t, f)
;;
