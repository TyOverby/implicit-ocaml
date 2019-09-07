type 'a t =
  | Var : 'a Ctypes.typ * Id.t -> 'a t
  | Int_lit : int -> int t
  | Bool_lit : bool -> bool t
  | Float_lit : float -> float t
  | Add_float : float t * float t -> float t
  | Add_int : int t * int t -> int t
  | Eq_int : int t * int t -> bool t
  | Cond : 'a Ctypes.typ * bool t * 'a t * 'a t -> 'a t

let rec typeof (type a) : a t -> a Ctypes.typ = function
  | Var (typ, _) -> typ
  | Int_lit _ -> Ctypes.int
  | Float_lit _ -> Ctypes.float
  | Bool_lit _ -> Ctypes.bool
  | Add_int _ -> Ctypes.int
  | Add_float _ -> Ctypes.float
  | Eq_int (_, _) -> Ctypes.bool
  | Cond (c, _, _, _) -> c

and int_lit i = Int_lit i
and float_lit i = Float_lit i
and bool_lit i = Bool_lit i
and add_int a b = Add_int (a, b)
and add_float a b = Add_float (a, b)
and eq_int a b = Eq_int (a, b)

and cond c t f =
  let typ = typeof t in
  Cond (typ, c, t, f)
;;
