open! Core_kernel

type t

val create : unit -> t

module Table : Hashtbl.S with type key := t
