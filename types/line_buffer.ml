open! Core

type t = Float_bigarray.t

let rec windows_4 = function
  | x1 :: y1 :: x2 :: y2 :: rest ->
    { Line.p1 = { x = x1; y = y1 }; p2 = { x = x2; y = y2 } }
    :: windows_4 rest
  | _ -> []
;;

let to_list t =
  t |> Float_bigarray.to_array |> Array.to_list |> windows_4
;;

let sexp_of_t t =
  t
  |> Float_bigarray.to_array
  |> Array.to_list
  |> windows_4
  |> [%sexp_of: Line.t list]
;;

let t_of_sexp s =
  let co_windows_4 =
    List.bind
      ~f:(fun { Line.p1 = { x = x1; y = y1 }
              ; p2 = { x = x2; y = y2 }
              }
              -> [ x1; y1; x2; y2 ])
  in
  s
  |> [%of_sexp: Line.t list]
  |> co_windows_4
  |> Array.of_list
  |> Float_bigarray.of_array
;;

let create ~line_capacity = Float_bigarray.create (line_capacity * 4)

let iteri t =
  t
  |> Float_bigarray.to_array
  |> Array.to_list
  |> windows_4
  |> List.iteri
;;

let iter t ~f = iteri t ~f:(fun _ -> f)
