open! Core
open! Async
open Shared_types

let main () =
  let connected =
    In_channel.stdin
    |> In_channel.input_all
    |> Sexp.of_string
    |> [%of_sexp: Connected.t list]
  in
  printf
    {|<svg xmlns="http://www.w3.org/2000/svg" viewbox="0 0 88 88">
  |};
  List.iter connected ~f:(function
      | Disjoint _ -> failwith "umimplemented"
      | Joined points ->
        printf {|<path d="|};
        (points
        |> List.hd_exn
        |> fun { Point.x; y } -> printf "M%f %f\n " x y);
        List.iter points ~f:(fun { Point.x; y } ->
            printf "L%f %f\n " x y);
        printf " Z\" ";
        printf
          {|style="fill:black; stroke:none; stroke-width:0"></path>\n|});
  printf {|</svg>|};
  Deferred.unit
;;

let command =
  Command.async
    ~summary:"convert a connected.sexp to a svg file"
    (Command.Param.return main)
;;

let () = Command.run command
