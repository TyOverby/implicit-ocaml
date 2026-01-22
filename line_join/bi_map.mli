open! Core
open! Shared_types
module Id : Core.Unique_id.Id

type t

val parse : Line_buffer.t -> t
val remove_id : t -> Id.t -> unit
val lookup_line : t -> Id.t -> Line.t
val first : t -> Id.t
val find_and_remove_end : t -> Point.t -> Id.t
val is_empty : t -> bool
