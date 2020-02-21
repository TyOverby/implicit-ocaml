open! Core_kernel
open! Async_kernel
open Shared_types

val reshape
  :  Profile.t
  -> Box.bounding
  -> Shape.t
  -> target_width:int
  -> target_height:int
  -> padding:int
  -> Shape.t

val eval_chunk
  :  Profile.t
  -> (module Jitsy.Backend.S with type Debug.t = 'a)
  -> Shape.t
  -> width:int
  -> height:int
  -> Chunk.t Deferred.t

val eval_lines
  :  Profile.t
  -> (module Jitsy.Backend.S with type Debug.t = 'a)
  -> Shape.t
  -> width:int
  -> height:int
  -> Line_buffer.t Deferred.t

val eval_connect
  :  Profile.t
  -> (module Jitsy.Backend.S with type Debug.t = 'a)
  -> Shape.t
  -> width:int
  -> height:int
  -> Connected.t list Deferred.t
