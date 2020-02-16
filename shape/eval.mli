open! Core_kernel
open! Async_kernel
open Shared_types

val eval
  :  (module Jitsy.Backend.S with type Debug.t = 'd)
  -> Types.t
  -> Chunk.t
  -> 'd Deferred.t
