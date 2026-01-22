open! Core
open Shared_types

let run shape =
  shape |> Shape.of_type_safe |> Shape.sexp_of_t |> print_s
;;

let run_scene scene = scene |> Scene.sexp_of_t |> print_s

include Shape.Type_safe
module Scene = Scene
module Layer = Layer
