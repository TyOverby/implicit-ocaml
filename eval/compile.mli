open! Core
open Shared_types.Shape

val compile
  :  t
  -> x:float Jitsy.Expr.t
  -> y:float Jitsy.Expr.t
  -> float Jitsy.Expr.t
