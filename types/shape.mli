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
  | Modulate of
      { shape : t
      ; by : float
      }
  | Transform of
      { shape : t
      ; matrix : Matrix.t
      }
  | Smooth_union of
      { a : t
      ; b : t
      ; k : float
      }
  | Mix of
      { a : t
      ; b : t
      ; f : float
      }
  | Repeat_x of
      { shape : t
      ; every : float
      }
  | Repeat_y of
      { shape : t
      ; every : float
      }
[@@deriving sexp]

val circle : x:float -> y:float -> r:float -> t
val intersection : t list -> t
val union : t list -> t
val invert : t -> t
val subtract : t -> t -> t
val modulate : t -> by:float -> t
val scale : t -> dx:float -> dy:float -> t
val translate : t -> dx:float -> dy:float -> t
val rotate : t -> r:float -> t
val mix : t -> t -> f:float -> t
val smooth_union : t -> t -> k:float -> t
val repeat_x : t -> every:float -> t
val repeat_y : t -> every:float -> t

module Type_safe : sig
  type exact = [ `Exact ]

  type inexact =
    [ `Exact
    | `Inexact
    ]

  type -'p t

  val circle : x:float -> y:float -> r:float -> [> exact ] t
  val intersection : 'a t list -> 'a t
  val union : 'a t list -> inexact t
  val invert : 'a t -> 'a t
  val subtract : 'a t -> 'a t -> 'a t
  val modulate : exact t -> by:float -> [> exact ] t
  val scale : _ t -> dx:float -> dy:float -> inexact t
  val translate : 'a t -> dx:float -> dy:float -> 'a t
  val rotate : 'a t -> r:float -> 'a t
  val mix : exact t -> exact t -> f:float -> [> exact ] t
  val smooth_union : 'a t -> 'a t -> k:float -> 'a t
  val repeat_x : 'a t -> every:float -> 'a t
  val repeat_y : 'a t -> every:float -> 'a t
end

val of_type_safe : _ Type_safe.t -> t
val to_type_safe : t -> Type_safe.inexact Type_safe.t
