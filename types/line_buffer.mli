type t = Float_bigarray.t [@@deriving sexp]

val create : line_capacity:int -> t

val iter
  :  t
  -> f:(x1:float -> y1:float -> x2:float -> y2:float -> unit)
  -> unit
