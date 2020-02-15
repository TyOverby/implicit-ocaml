open! Core_kernel

let run shape =
  shape |> Shape.of_type_safe |> Shape.sexp_of_t |> print_s
;;

include Shape.Type_safe
