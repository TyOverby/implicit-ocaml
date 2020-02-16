open! Core_kernel

type t =
  { x : float
  ; y : float
  ; w : float
  ; h : float
  }
[@@deriving sexp]

type b =
  | Everything
  | Nothing
  | Something of t
  | Hole of t
[@@deriving sexp]

type bounding =
  { positive : b
  ; negative : b
  }
[@@deriving sexp, fields]

val union_all : bounding list -> bounding
val intersection_all : bounding list -> bounding
val inverse : bounding -> bounding
val grow_by : float -> t -> t
val bbox_of_points : Point.t list -> t option
val grow : bounding -> float -> bounding
