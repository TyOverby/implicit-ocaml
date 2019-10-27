open! Core_kernel

type t = { buffer : Float_bigarray.t }

let sexp_of_t t =
  let rec windows_4 = function
    | a :: b :: c :: d :: rest -> (a, b, c, d) :: windows_4 rest
    | _ -> []
  in
  t
  |> (fun { buffer } -> buffer)
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
  |> fun buffer -> { buffer }
;;
