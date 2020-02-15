open! Core_kernel
open Shared_types

module T = struct
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
    | Mix of
        { a : t
        ; b : t
        ; f : float
        }
  [@@deriving sexp]

  let circle ~x ~y ~r = Circle { x; y; r }
  let union l = Union l
  let intersection l = Intersection l
  let invert t = Invert t
  let subtract a b = intersection [ a; invert b ]
  let modulate shape ~by = Modulate { shape; by }
  let mix a b ~f = Mix { a; b; f }

  let scale shape ~dx ~dy =
    Transform
      { shape; matrix = Matrix.create_scale (1.0 /. dx) (1.0 /. dy) }
  ;;

  let translate shape ~dx ~dy =
    Transform
      { shape; matrix = Matrix.create_translation (-.dx) (-.dy) }
  ;;

  let rotate shape ~r =
    Transform { shape; matrix = Matrix.create_rotation r }
  ;;
end

module Type_safe = struct
  include T

  type exact = [ `Exact ]

  type inexact =
    [ exact
    | `Inexact
    ]

  type nonrec 'p t = t
end

let of_type_safe = Fn.id

include T
