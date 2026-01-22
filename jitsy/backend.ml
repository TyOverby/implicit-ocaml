open! Core
open! Async_kernel
open Shared_types

module type S = sig
  module Debug : sig
    type t
  end

  val run
    :  Profile.t
    -> ('a, 'b -> 'c) Function.t
    -> (('b -> 'c) * Debug.t) Deferred.t

  val apply
    :  Profile.t
    -> Chunk.t
    -> f:(x:int -> y:int -> float Type.my_array -> int -> 'c)
    -> 'c
end

type t = (module S)
