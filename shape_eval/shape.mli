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

val circle : x:float -> y:float -> r:float -> t
val intersection : t list -> t
val union : t list -> t
val invert : t -> t
val subtract : t -> t -> t
