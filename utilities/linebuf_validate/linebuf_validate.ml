open! Core
open! Async
open Shared_types

module Point = struct
  module T = struct
    type t = float * float [@@deriving compare, sexp]
  end

  include T
  include Comparable.Make (T)
end

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
         ~f:(fun (starts, ends)
                 { Line.p1 = { x = x1; y = y1 }
                 ; p2 = { x = x2; y = y2 }
                 }
                 ->
                  if Point.Set.mem starts (x1, y1) then raise_s [%message (x1: float ) (y1: float) "already included in" (starts: Point.Set.t)] 
                  else
           Point.Set.add starts (x1, y1), Point.Set.add ends (x2, y2))
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
          (diff : (Point.T.t, Point.T.t) Either.t list)]
  else ();
  Deferred.unit
;;

let command =
  Command.async
    ~summary:"convert a shape file to a linebuf file"
    (Command.Param.return main)
;;

let () = Command.run command
