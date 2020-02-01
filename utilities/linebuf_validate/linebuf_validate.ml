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
  Line_buffer.iteri
    linebuf
    ~f:(fun i
            { Line.p1 = { x = x1; y = y1 }; p2 = { x = x2; y = y2 } }
            ->
      if Float.is_nan x1
         || Float.is_nan y1
         || Float.is_nan x2
         || Float.is_nan y2
      then raise_s [%message "line has a NaN" (i : int)]
      else ());
  let linebuf_list = Line_buffer.to_list linebuf in
  let starts, ends =
    linebuf_list
    |> List.fold
         ~init:(Point.Set.empty, Point.Set.empty)
         ~f:(fun (starts, ends) { Line.p1; p2 } ->
           if Point.Set.mem starts p1
           then
             print_s
               [%message (p1 : Point.t) "already included in starts"]
           else if Point.Set.mem ends p2
           then
             print_s
               [%message (p2 : Point.t) "already included in ends"];
           Point.Set.add starts p1, Point.Set.add ends p2)
  in
  let length_tripple =
    List.length linebuf_list, Set.length starts, Set.length ends
  in
  (let l1, l2, l3 = length_tripple in
   if l1 <> l2 || l1 <> l3
   then
     raise_s
       [%message
         "line lengths are unequal"
           (length_tripple : int * int * int)]
   else ());
  let diff = Set.symmetric_diff starts ends |> Sequence.to_list in
  if not (List.is_empty diff)
  then
    raise_s
      [%message
        "symmetric diff starts -> ends"
          (diff : (Point.t, Point.t) Either.t list)]
  else ();
  Deferred.unit
;;

let command =
  Command.async
    ~summary:"convert a shape file to a linebuf file"
    (Command.Param.return main)
;;

let () = Command.run command
