open! Core_kernel

module Float : sig
  val const : float -> float Expr_type.t

  val ( + )
    :  float Expr_type.t
    -> float Expr_type.t
    -> float Expr_type.t

  val ( - )
    :  float Expr_type.t
    -> float Expr_type.t
    -> float Expr_type.t

  val ( * )
    :  float Expr_type.t
    -> float Expr_type.t
    -> float Expr_type.t

  val ( / )
    :  float Expr_type.t
    -> float Expr_type.t
    -> float Expr_type.t

  val min
    :  float Expr_type.t
    -> float Expr_type.t
    -> float Expr_type.t

  val max
    :  float Expr_type.t
    -> float Expr_type.t
    -> float Expr_type.t

  val sqrt : float Expr_type.t -> float Expr_type.t
  val square : float Expr_type.t -> float Expr_type.t
end

module Int : sig
  val ( + ) : int Expr_type.t -> int Expr_type.t -> int Expr_type.t
  val ( - ) : int Expr_type.t -> int Expr_type.t -> int Expr_type.t
  val ( * ) : int Expr_type.t -> int Expr_type.t -> int Expr_type.t
  val ( / ) : int Expr_type.t -> int Expr_type.t -> int Expr_type.t
end
