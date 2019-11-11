open! Core_kernel
open! Shared_types

module Connected : sig
  type t =
    | Joined of Point.t list
    | Disjoint of Point.t list
  [@@deriving sexp]
end

val f : Line_buffer.t -> Connected.t list
