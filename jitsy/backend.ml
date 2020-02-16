open! Core_kernel
open! Async_kernel

module type S = sig
  module Debug : sig
    type t
  end

  val run
    :  ('a, 'b -> 'c) Function.t
    -> (('b -> 'c) * Debug.t) Deferred.t
end

type t = (module S)
