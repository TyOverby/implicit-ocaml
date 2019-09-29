type t

val circle : x:int32 -> y:int32 -> r:int32 -> t
val intersection : t list -> t
val union : t list -> t
val compile : t -> x:int32 Jitsy.Expr.t -> y:int32 Jitsy.Expr.t -> int32 Jitsy.Expr.t
