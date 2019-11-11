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
  Line_join.f linebuf |> [%sexp_of: Connected.t list] |> print_s;
  Deferred.unit
;;

let command =
  Command.async
    ~summary:"convert a shape file to a linebuf file"
    (Command.Param.return main)
;;

let () = Command.run command
