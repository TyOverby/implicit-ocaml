open! Core
open! Async
open Jitsy

module Debug : sig
  type t =
    { c_source : string
    ; asm_source : unit -> string Deferred.t
    }
end

val compile_expression
  :  Buffer.t
  -> idgen:(Id.t -> string)
  -> 'a Expr.t
  -> string

val compile : ('a, 'b) Function.t -> string * string
val compile_c : string -> string Deferred.Or_error.t
val load : string -> Dl.library

val jit
  :  Shared_types.Profile.t
  -> ('a, 'b -> 'c) Function.t
  -> (('b -> 'c) * Debug.t) Deferred.t
