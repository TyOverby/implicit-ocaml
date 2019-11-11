open! Core_kernel

type t =
  | Circle of
      { x : float
      ; y : float
      ; r : float
      }
  | Union of t list
  | Intersection of t list
  | Invert of t
[@@deriving sexp]

let circle ~x ~y ~r = Circle { x; y; r }
let union l = Union l
let intersection l = Intersection l
let invert t = Invert t
let subtract a b = intersection [ a; invert b ]
