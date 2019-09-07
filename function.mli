type ('a, 'r) t =
  { expression : 'a Expr.t
  ; typ : 'r Ctypes.fn
  ; param_map : (Id.t * string) list
  }

module Let_syntax : sig
  val return : 'a Expr.t -> ('a, 'a) t

  module Let_syntax : sig
    val bind : 'a Ctypes_static.typ -> f:('a Expr.t -> ('b, 'c) t) -> ('b, 'a -> 'c) t
  end
end
