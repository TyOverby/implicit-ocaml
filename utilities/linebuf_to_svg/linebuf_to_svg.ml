open! Core
open! Async
open Shared_types

let main () =
  let linebuf =
    In_channel.stdin
    |> In_channel.input_all
    |> Sexp.of_string
    |> Line_buffer.t_of_sexp
  in
  printf
    {|<svg xmlns="http://www.w3.org/2000/svg" viewbox="0 0 88 88">
  |};
  Line_buffer.iter linebuf ~f:(fun { Line.x1; y1; x2; y2 } ->
      printf
        {| <line x1="%f" y1="%f" x2="%f" y2="%f" style="%s" />
        |}
        x1
        y1
        x2
        y2
        {|fill:none; stroke:black; stroke-width:1|});
  printf {|</svg>|};
  Deferred.unit
;;

let command =
  Command.async
    ~summary:"convert a shape file to a linebuf file"
    (Command.Param.return main)
;;

let () = Command.run command
