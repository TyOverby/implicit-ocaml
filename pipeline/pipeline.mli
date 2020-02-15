open! Core_kernel
open! Async
open Shared_types

val eval_chunk : Shape.t -> Chunk.t Deferred.t
val eval_lines : Shape.t -> Line_buffer.t Deferred.t
val eval_connect : Shape.t -> Connected.t sexp_list Deferred.t
