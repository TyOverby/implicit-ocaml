open! Core
open! Async

let main () =
  let shape =
    In_channel.stdin
    |> In_channel.input_all
    |> Sexp.of_string
    |> Shape.t_of_sexp
  in
  let%bind lines = Pipeline.eval_lines shape in
  lines
  |> Shared_types.Line_buffer.sexp_of_t
  |> Sexp.to_string_hum
  |> print_endline;
  return ()
;;

let command =
  Command.async
    ~summary:"convert a shape file to a linebuf file"
    (Command.Param.return main)
;;

let () = Command.run command
