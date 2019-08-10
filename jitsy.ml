module Expr : sig
  type 'a t

  val var : 'a Ctypes.typ -> 'a t
  val int_lit : int -> int t
  val bool_lit : bool -> bool t
  val add_int : int t -> int t -> int t
  val eq_int : int t -> int t -> bool t
  val cond : bool t -> 'a t -> 'a t -> 'a t
  val typeof : 'a t -> 'a Ctypes.typ
end = struct
  type 'a t =
    | Var : 'a Ctypes.typ -> 'a t
    | Int_lit : int -> int t
    | Bool_lit : bool -> bool t
    | Add_int : int t * int t -> int t
    | Eq_int : int t * int t -> bool t
    | Cond : 'a Ctypes.typ * bool t * 'a t * 'a t -> 'a t

  let rec typeof (type a) : a t -> a Ctypes.typ = function
    | Var typ -> typ
    | Int_lit _ -> Ctypes.int
    | Bool_lit _ -> Ctypes.bool
    | Add_int _ -> Ctypes.int
    | Eq_int (_, _) -> Ctypes.bool
    | Cond (c, _, _, _) -> c

  and int_lit i = Int_lit i
  and bool_lit i = Bool_lit i
  and add_int a b = Add_int (a, b)
  and eq_int a b = Eq_int (a, b)
  and var typ = Var typ

  and cond c t f =
    let typ = typeof t in
    Cond (typ, c, t, f)
  ;;
end

module Function : sig
  val with_parameter
    :  'a Ctypes_static.typ
    -> f:('a Expr.t -> 'b Expr.t * 'c Ctypes_static.fn)
    -> 'b Expr.t * ('a -> 'c) Ctypes_static.fn

  val constant : 'a Expr.t -> 'a Expr.t * 'a Ctypes_static.fn
end = struct
  let with_parameter typ ~f =
    let ( @-> ) = Ctypes.( @-> ) in
    let expr, expr_typ = f (Expr.var typ) in
    expr, typ @-> expr_typ
  ;;

  let constant expr =
    let typ = Expr.typeof expr in
    expr, Ctypes.returning typ
  ;;
end

module Function_builder : sig
  type ('a, 'r) t
  type 'a param
  type 'a param_type

  module Let_syntax : sig
    val return : 'a Expr.t -> ('a, 'a) t

    module Let_syntax : sig
      module Open_on_rhs : sig
        val arg : 'a param_type -> 'a param
        val bool : bool param_type
        val int : int param_type
      end

      val bind : 'a param -> f:('a Expr.t -> ('b, 'c) t) -> ('b, 'a -> 'c) t
    end
  end
end = struct
  type ('a, 'r) t = 'a Expr.t * 'r Ctypes.fn

  type 'a param_type =
    { typ : 'a Ctypes.typ
    ; c_name : string
    }

  type 'a param =
    { typ : 'a param_type
    ; id : unit
    }

  module Let_syntax = struct
    let return = Function.constant

    module Let_syntax = struct
      module Open_on_rhs = struct
        let arg typ = { typ; id = () }
        let bool = { typ = Ctypes.bool; c_name = "bool" }
        let int = { typ = Ctypes.int; c_name = "int" }
      end

      let bind param ~f = Function.with_parameter param.typ.typ ~f
    end
  end
end

open Function_builder.Let_syntax

let f =
  let%bind_open a = arg int in
  let%bind_open b = arg int in
  return (Expr.add_int a b)
;;
