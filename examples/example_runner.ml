open! Core_kernel

let run shape = shape |> Shape_eval.Shape.sexp_of_t |> print_s

include Shape_eval.Shape
