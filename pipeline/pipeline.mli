open! Core_kernel
open! Async
open Shared_types

val eval_chunk : Shape_eval.Shape.t -> Chunk.t Deferred.t
