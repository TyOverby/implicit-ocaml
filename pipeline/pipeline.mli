open! Core_kernel
open! Async
open Shared_types

val eval_chunk : Shape_eval.Shape.t -> Chunk.t Deferred.t
val eval_lines : Shape_eval.Shape.t -> Line_buffer.t Deferred.t

val eval_connect
  :  Shape_eval.Shape.t
  -> Line_join.Connected.t sexp_list Deferred.t
