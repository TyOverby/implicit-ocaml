include Expr_type

let rec typeof (type a) : a t -> a Type.t = function
  | Var (typ, _) -> typ
  | Int_lit _ -> Type.int
  | Int32_lit _ -> Type.int32
  | Float_lit _ -> Type.float
  | Bool_lit _ -> Type.bool
  | Add_int _ -> Type.int
  | Sub_int _ -> Type.int
  | Div_int _ -> Type.int
  | Mul_int _ -> Type.int
  | Add_int32 _ -> Type.int32
  | Sub_int32 _ -> Type.int32
  | Div_int32 _ -> Type.int32
  | Mul_int32 _ -> Type.int32
  | Min_int32 _ -> Type.int32
  | Max_int32 _ -> Type.int32
  | Add_float _ -> Type.float
  | Sub_float _ -> Type.float
  | Mul_float _ -> Type.float
  | Div_float _ -> Type.float
  | Sqrt_float _ -> Type.float
  | Square_int32 _ -> Type.int32
  | Sqrt_int32 _ -> Type.int32
  | Eq_int (_, _) -> Type.bool
  | Int_to_float _ -> Type.float
  | Int_to_int32 _ -> Type.int32
  | Int32_to_float _ -> Type.float
  | Float_to_int _ -> Type.int
  | Float_to_int32 _ -> Type.int32
  | Array_set _ -> Type.unit
  | Range2 _ -> Type.unit
  | Progn (c, _, _) -> c
  | Cond (c, _, _, _) -> c

and int_lit i = Int_lit i
and int32_lit i = Int32_lit i
and float_lit i = Float_lit i
and bool_lit i = Bool_lit i
and add_int a b = Add_int (a, b)
and sub_int a b = Sub_int (a, b)
and div_int a b = Div_int (a, b)
and mul_int a b = Mul_int (a, b)
and add_int32 a b = Add_int32 (a, b)
and sub_int32 a b = Sub_int32 (a, b)
and div_int32 a b = Div_int32 (a, b)
and mul_int32 a b = Mul_int32 (a, b)
and min_int32 a b = Min_int32 (a, b)
and max_int32 a b = Max_int32 (a, b)
and add_float a b = Add_float (a, b)
and sub_float a b = Sub_float (a, b)
and mul_float a b = Mul_float (a, b)
and div_float a b = Div_float (a, b)
and sqrt_float a = Sqrt_float a
and sqrt_int32 a = Sqrt_int32 a
and square_int32 a = Square_int32 a
and eq_int a b = Eq_int (a, b)
and int_to_float a = Int_to_float a
and int_to_int32 a = Int_to_int32 a
and int32_to_float a = Int32_to_float a
and float_to_int a = Float_to_int a
and float_to_int32 a = Float_to_int32 a
and array_set a b c = Array_set (a, b, c)
and range2 ~width ~height ~f = Range2 { width; height; f }

and progn l a =
  let typ = typeof a in
  Progn (typ, l, a)

and cond c t f =
  let typ = typeof t in
  Cond (typ, c, t, f)
;;
