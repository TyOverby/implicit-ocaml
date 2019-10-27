open! Core_kernel

type t = Float_bigarray.t

let rec windows_4 = function
  | a :: b :: c :: d :: rest -> (a, b, c, d) :: windows_4 rest
  | _ -> []
;;

let sexp_of_t t =
  t
  |> Float_bigarray.to_array
  |> Array.to_list
  |> windows_4
  |> [%sexp_of: (float * float * float * float) list]
;;

let t_of_sexp s =
  let co_windows_4 =
    List.bind ~f:(fun (a, b, c, d) -> [ a; b; c; d ])
  in
  s
  |> [%of_sexp: (float * float * float * float) list]
  |> co_windows_4
  |> Array.of_list
  |> Float_bigarray.of_array
;;

let create ~line_capacity = Float_bigarray.create (line_capacity * 4)

let iter t ~f =
  t
  |> Float_bigarray.to_array
  |> Array.to_list
  |> windows_4
  |> List.iter ~f:(fun (x1, y1, x2, y2) -> f ~x1 ~y1 ~x2 ~y2)
;;
