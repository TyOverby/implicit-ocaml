open! Async
open Shared_types

type debug =
  { c_source : unit -> string
  ; asm_source : unit -> string Deferred.t
  }

val eval : Shape.t -> Chunk.t -> debug Deferred.t
