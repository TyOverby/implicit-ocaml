open! Core_kernel
open! Async_kernel
open Shared_types

val eval
  :  Profile.t
  -> (module Jitsy.Backend.S with type Debug.t = 'd)
  -> Shape.t
  -> Chunk.t
  -> 'd Deferred.t
