open Core_kernel
open Async

val compile_expression
  :  Buffer.t
  -> idgen:(Id.t -> string)
  -> 'a Expr.t
  -> string

val compile : ('a, 'b) Function.t -> string * string
val compile_c : string -> string Deferred.Or_error.t
val load : string -> Dl.library

val jit
  :  ('a, 'b -> 'c) Function.t
  -> (('b -> 'c) * (unit -> string Deferred.t)) Deferred.t
