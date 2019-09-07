open! Async

module Expr : sig
  type 'a t

  val int_lit : int -> int t
  val bool_lit : bool -> bool t
  val float_lit : float -> float t
  val add_int : int t -> int t -> int t
  val add_float : float t -> float t -> float t
  val eq_int : int t -> int t -> bool t
  val cond : bool t -> 'a t -> 'a t -> 'a t
  val typeof : 'a t -> 'a Ctypes.typ
end

module Type : sig
  type 'a t

  val to_string : 'a t -> string
end

module Function : sig
  type ('a, 'r) t

  module Let_syntax : sig
    val return : 'a Expr.t -> ('a, 'a) t

    module Let_syntax : sig
      val bind : 'a Type.t -> f:('a Expr.t -> ('b, 'c) t) -> ('b, 'a -> 'c) t
    end
  end
end

module Compile : sig
  val jit : ('a, 'b -> 'c) Function.t -> ('b -> 'c) Deferred.t
end
