type 'a t =
  | Var : 'a Ctypes.typ * Id.t -> 'a t
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
  | Cond : 'a Ctypes.typ * bool t * 'a t * 'a t -> 'a t

let rec typeof (type a) : a t -> a Ctypes.typ = function
  | Var (typ, _) -> typ
  | Int_lit _ -> Ctypes.int
  | Float_lit _ -> Ctypes.float
  | Bool_lit _ -> Ctypes.bool
  | Add_int _ -> Ctypes.int
  | Sub_int _ -> Ctypes.int
  | Div_int _ -> Ctypes.int
  | Mul_int _ -> Ctypes.int
  | Add_float _ -> Ctypes.float
  | Sub_float _ -> Ctypes.float
  | Mul_float _ -> Ctypes.float
  | Div_float _ -> Ctypes.float
  | Eq_int (_, _) -> Ctypes.bool
  | Int_to_float _ -> Ctypes.float
  | Float_to_int _ -> Ctypes.int
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

and cond c t f =
  let typ = typeof t in
  Cond (typ, c, t, f)
;;
