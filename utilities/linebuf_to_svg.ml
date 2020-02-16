open! Core
open! Async
open Shared_types
open Svg

let style = Style.[ Fill None; Stroke (Some "black"); Stroke_width 1 ]

let main () =
  let linebuf =
    In_channel.stdin
    |> In_channel.input_all
    |> Sexp.of_string
    |> Line_buffer.t_of_sexp
  in
  linebuf
  |> Line_buffer.to_list
  |> List.map ~f:(Element.line ~style)
  |> to_svg
  |> print_endline;
  Deferred.unit
;;

let command =
  Command.async
    ~summary:"convert a linebuf file to an svg file"
    (Command.Param.return main)
;;
