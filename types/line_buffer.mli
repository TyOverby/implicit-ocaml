type t = Float_bigarray.t [@@deriving sexp]

val create : line_capacity:int -> t
val to_list : t -> Line.t list
val iter : t -> f:(Line.t -> unit) -> unit
val iteri : t -> f:(int -> Line.t -> unit) -> unit
