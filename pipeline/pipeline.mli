open! Core_kernel
open! Async_kernel
open Shared_types
module Reshape = Reshape

val eval_chunk
  :  (module Jitsy.Backend.S with type Debug.t = 'a)
  -> Shape.t
  -> Chunk.t Deferred.t

val eval_lines
  :  (module Jitsy.Backend.S with type Debug.t = 'a)
  -> Shape.t
  -> Line_buffer.t Deferred.t

val eval_connect
  :  (module Jitsy.Backend.S with type Debug.t = 'a)
  -> Shape.t
  -> Connected.t list Deferred.t
