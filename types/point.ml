open! Core_kernel

module T = struct
  type t =
    { x : float
    ; y : float
    }
  [@@deriving sexp, hash, compare, equal]
end

include T
include Hashable.Make (T)
include Comparable.Make (T)
