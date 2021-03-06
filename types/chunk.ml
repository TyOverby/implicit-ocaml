open! Core_kernel

type t =
  { width : int
  ; height : int
  ; x : int
  ; y : int
  ; array : Float_bigarray.t
  }
[@@deriving sexp, fields]

let create ~width ~height ~x ~y =
  let size = width * height in
  let array = Float_bigarray.create size in
  { width; height; x; y; array }
;;

let to_underlying t = t.array

module Debug = struct
  let debug t ~f =
    List.iter (List.range ~stride:2 0 t.height) ~f:(fun y ->
        List.iter (List.range ~stride:2 0 t.width) ~f:(fun x ->
            let idx = (y * 88) + x in
            let v = Float_bigarray.get t.array idx in
            let s = f v in
            Out_channel.(output_string stdout s));
        print_endline "")
  ;;

  let borders =
    debug ~f:(fun v ->
        (match Float.sign_exn v with
        | Sign.Neg -> '_'
        | Sign.Zero -> '-'
        | Sign.Pos -> '#')
        |> Char.to_string)
  ;;

  let values = debug ~f:(fun v -> Float.to_string_hum v ^ " ")
end

let%expect_test "empty chunk" =
  Debug.borders (create ~width:88 ~height:88 ~x:0 ~y:0);
  [%expect
    {|
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      --------------------------------------------
      -------------------------------------------- |}]
;;
