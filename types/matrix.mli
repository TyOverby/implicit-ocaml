type t =
  { m11 : float
  ; m12 : float
  ; m21 : float
  ; m22 : float
  ; m31 : float
  ; m32 : float
  }
[@@deriving sexp]

val row_major
  :  float
  -> float
  -> float
  -> float
  -> float
  -> float
  -> t

val id : t
val mul : t -> t -> t
val create_rotation : float -> t
val create_translation : float -> float -> t
val create_scale : float -> float -> t
val apply_to_point : t -> Point.t -> Point.t
val apply_to_rect : t -> Box.t -> Box.t
