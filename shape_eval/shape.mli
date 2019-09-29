type t

val circle : x:float -> y:float -> r:float -> t
val intersection : t list -> t
val union : t list -> t

val compile
  :  t
  -> x:float Jitsy.Expr.t
  -> y:float Jitsy.Expr.t
  -> float Jitsy.Expr.t

val invert : t -> t
val subtract : t -> t -> t
