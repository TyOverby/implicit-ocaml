open! Core
open! Async
open Svg
open Shared_types

let style = Style.[ Fill (Some "black"); Stroke None; Stroke_width 0 ]

let main () =
  let connected =
    In_channel.stdin
    |> In_channel.input_all
    |> Sexp.of_string
    |> [%of_sexp: Connected.t list]
  in
  connected
  |> List.map ~f:(function
    | Disjoint _ -> failwith "svg of disjoint is not implemented"
    | Joined points -> points)
  |> Element.path ~style
  |> List.return
  |> to_svg
  |> print_endline;
  Deferred.unit
;;

let command =
  Command.async
    ~summary:"convert a connected.sexp to a svg file"
    (Command.Param.return main)
;;
