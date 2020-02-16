open! Core_kernel

type t =
  { m11 : float
  ; m12 : float
  ; m21 : float
  ; m22 : float
  ; m31 : float
  ; m32 : float
  }
[@@deriving sexp]

let row_major m11 m12 m21 m22 m31 m32 =
  { m11; m12; m21; m22; m31; m32 }
;;

let id = row_major 1.0 0.0 0.0 1.0 0.0 0.0

let mul a b =
  row_major
    ((a.m11 *. b.m11) +. (a.m12 *. b.m21))
    ((a.m11 *. b.m12) +. (a.m12 *. b.m22))
    ((a.m21 *. b.m11) +. (a.m22 *. b.m21))
    ((a.m21 *. b.m12) +. (a.m22 *. b.m22))
    ((a.m31 *. b.m11) +. (a.m32 *. b.m21) +. b.m31)
    ((a.m31 *. b.m12) +. (a.m32 *. b.m22) +. b.m32)
;;

let create_rotation theta =
  let cos = Float.cos theta in
  let sin = Float.sin theta in
  row_major cos (sin *. -1.) sin cos 0.0 0.0
;;

let create_translation dx dy = row_major 1.0 0.0 0.0 1.0 dx dy
let create_scale dx dy = row_major dx 0.0 0.0 dy 0.0 0.0

let apply_to_point matrix (point : Point.t) : Point.t =
  { x =
      (point.x *. matrix.m11) +. (point.y *. matrix.m21) +. matrix.m31
  ; y =
      (point.x *. matrix.m12) +. (point.y *. matrix.m22) +. matrix.m32
  }
;;

let apply_to_rect matrix (rect : Box.t) =
  [ apply_to_point matrix { x = rect.x; y = rect.y }
  ; apply_to_point matrix { x = rect.x +. rect.w; y = rect.y }
  ; apply_to_point matrix { x = rect.x; y = rect.y +. rect.h }
  ; apply_to_point
      matrix
      { x = rect.x +. rect.w; y = rect.y +. rect.h }
  ]
  |> Box.bbox_of_points
  |> Option.value_exn
;;

let%expect_test _ =
  let id = id in
  let scale = create_scale 2.0 2.0 in
  let translate = create_translation 10.0 10.0 in
  let combined = mul (mul id scale) translate in
  let pt : Point.t = { x = 0.0; y = 0.0 } in
  let applied = apply_to_point combined pt in
  Point.sexp_of_t applied |> Sexp.to_string_hum |> print_endline;
  [%expect "((x 10) (y 10))"]
;;

let%expect_test _ =
  let id = id in
  let scale = create_scale 2.0 2.0 in
  let translate = create_translation 10.0 10.0 in
  let combined = mul (mul id translate) scale in
  let pt : Point.t = { x = 0.0; y = 0.0 } in
  let applied = apply_to_point combined pt in
  Point.sexp_of_t applied |> Sexp.to_string_hum |> print_endline;
  [%expect "((x 20) (y 20))"]
;;
