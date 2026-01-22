open! Core

type t =
  { x : float
  ; y : float
  ; w : float
  ; h : float
  }
[@@deriving sexp]

type b =
  | Everything
  | Nothing
  | Something of t
  | Hole of t
[@@deriving sexp]

type bounding =
  { positive : b
  ; negative : b
  }
[@@deriving sexp, fields]

let from_extrema ~min_x ~min_y ~max_x ~max_y =
  { x = min_x; y = min_y; w = max_x -. min_x; h = max_y -. min_y }
;;

let grow_by factor box =
  let dx = Float.max_inan 2.0 (box.w *. factor) in
  let dy = Float.max_inan 2.0 (box.h *. factor) in
  { x = box.x -. dx
  ; y = box.y -. dy
  ; w = box.w +. (dx *. 2.0)
  ; h = box.h +. (dy *. 2.0)
  }
;;

let bbox_of_points = function
  | [] -> None
  | points ->
    let extract f g =
      points
      |> List.map ~f
      |> (fun l -> g l ~compare:Float.compare)
      |> Option.value_exn
    in
    let get_x (p : Point.t) = p.x in
    let get_y (p : Point.t) = p.y in
    let min_x = extract get_x List.min_elt in
    let min_y = extract get_y List.min_elt in
    let max_x = extract get_x List.max_elt in
    let max_y = extract get_y List.max_elt in
    Some (from_extrema ~min_x ~min_y ~max_x ~max_y)
;;

let intersects (a : t) (b : t) =
  let open Float in
  a.x < b.x + b.w
  && b.x < a.x + a.w
  && a.y < b.y + b.h
  && b.y < a.y + a.h
;;

let left_side { x; w; _ } = x +. w
let bottom_side { y; h; _ } = y +. h

let box_union a b =
  let ({ x = xa; y = ya; _ } : t) = a in
  let ({ x = xb; y = yb; _ } : t) = b in
  let min_x = Float.min_inan xa xb in
  let min_y = Float.min_inan ya yb in
  let max_x = Float.max_inan (left_side a) (left_side b) in
  let max_y = Float.max_inan (bottom_side a) (bottom_side b) in
  from_extrema ~min_x ~min_y ~max_x ~max_y
;;

let box_intersection a b =
  let ({ x = xa; y = ya; _ } : t) = a in
  let ({ x = xb; y = yb; _ } : t) = b in
  if not (intersects a b)
  then None
  else (
    let min_x = Float.max_inan xa xb in
    let min_y = Float.max_inan ya yb in
    let max_x = Float.min_inan (left_side a) (left_side b) in
    let max_y = Float.min_inan (bottom_side a) (bottom_side b) in
    Some
      { x = min_x; y = min_y; w = max_x -. min_x; h = max_y -. min_y })
;;

let inverse = function
  | { positive; negative } ->
    { positive = negative; negative = positive }
;;

let union_part a b =
  match a, b with
  | Nothing, other | other, Nothing -> other
  | Everything, _ | _, Everything -> Everything
  | Something a, Something b -> box_union a b |> Something
  | Hole a, Hole b ->
    (match box_intersection a b with
    | Some h -> Hole h
    | None -> Everything)
  | Hole h, Something _ | Something _, Hole h -> Hole h
;;

let intersection_part a b =
  match a, b with
  | Nothing, _ | _, Nothing -> Nothing
  | Everything, other | other, Everything -> other
  | Something a, Something b ->
    (match box_intersection a b with
    | Some a -> Something a
    | None -> Nothing)
  | Hole a, Hole b -> box_union a b |> Hole
  | Hole _, Something s | Something s, Hole _ -> Something s
;;

let union_b_all boxes =
  boxes |> List.reduce ~f:union_part |> Option.value_exn
;;

let intersection_b_all boxes =
  boxes |> List.reduce ~f:intersection_part |> Option.value_exn
;;

let union_all boundings =
  { positive =
      boundings |> List.map ~f:(fun b -> b.positive) |> union_b_all
  ; negative =
      boundings
      |> List.map ~f:(fun b -> b.negative)
      |> intersection_b_all
  }
;;

let intersection_all boundings =
  { positive =
      boundings
      |> List.map ~f:(fun b -> b.positive)
      |> intersection_b_all
  ; negative =
      boundings |> List.map ~f:(fun b -> b.negative) |> union_b_all
  }
;;

let increase { x; y; w; h } how_much =
  { x = x -. how_much
  ; y = y -. how_much
  ; w = w +. (how_much *. 2.0)
  ; h = h +. (how_much *. 2.0)
  }
;;

let grow { positive; negative } how_much =
  let g_h = function
    | Something a -> Something (increase a how_much)
    | Hole a -> Hole (increase a how_much)
    | Everything -> Everything
    | Nothing -> Nothing
  in
  { positive = g_h positive; negative = g_h negative }
;;

module BboxExpectTests = struct
  let box_test_stub f a b =
    let open Poly in
    let decode a = a |> Sexp.of_string |> t_of_sexp in
    let a = decode a in
    let b = decode b in
    let ab = f a b in
    let ba = f b a in
    assert (ab = ba);
    ab |> sexp_of_t |> Sexp.to_string_hum |> print_endline
  ;;

  let bounding_test_stub f a b =
    let open Poly in
    let ab = f a b in
    let ba = f b a in
    assert (ab = ba);
    ab |> sexp_of_b |> Sexp.to_string_hum |> print_endline
  ;;

  let union_box_test = box_test_stub box_union

  let intersection_box_test_some =
    box_test_stub (fun a b ->
        box_intersection a b |> Option.value_exn)
  ;;

  let union_test = bounding_test_stub union_part
  let intersection_test = bounding_test_stub intersection_part

  let%expect_test _ =
    union_box_test
      "((x 0) (y 0) (w 10) (h 10))"
      "((x 0) (y 0) (w 10) (h 10))";
    [%expect "((x 0) (y 0) (w 10) (h 10))"]
  ;;

  let%expect_test _ =
    intersection_box_test_some
      "((x 0) (y 0) (w 10) (h 10))"
      "((x 0) (y 0) (w 10) (h 10))";
    [%expect "((x 0) (y 0) (w 10) (h 10))"]
  ;;

  let%expect_test _ =
    union_box_test
      "((x 0) (y 0) (w 10) (h 10))"
      "((x 0) (y 0) (w 20) (h 20))";
    [%expect "((x 0) (y 0) (w 20) (h 20))"]
  ;;

  let%expect_test _ =
    union_box_test
      "((x 0) (y 0) (w 10) (h 10))"
      "((x 10) (y 10) (w 10) (h 10))";
    [%expect "((x 0) (y 0) (w 20) (h 20))"]
  ;;

  let%expect_test _ =
    union_box_test
      "((x 0) (y 0) (w 10) (h 10))"
      "((x 15) (y 15) (w 5) (h 5))";
    [%expect "((x 0) (y 0) (w 20) (h 20))"]
  ;;

  let%expect_test _ =
    union_box_test
      "((x 0) (y 0) (w 10) (h 10))"
      "((x 15) (y 15) (w 5) (h 5))";
    [%expect "((x 0) (y 0) (w 20) (h 20))"]
  ;;

  let%expect_test _ =
    intersection_box_test_some
      "((x 0) (y 0) (w 10) (h 10))"
      "((x 0) (y 0) (w 10) (h 10))";
    [%expect "((x 0) (y 0) (w 10) (h 10))"]
  ;;

  let%expect_test _ =
    intersection_box_test_some
      "((x 0) (y 0) (w 10) (h 10))"
      "((x 5) (y 5) (w 10) (h 10))";
    [%expect "((x 5) (y 5) (w 5) (h 5))"]
  ;;

  let%expect_test _ =
    intersection_box_test_some
      "((x 0) (y 0) (w 10) (h 10))"
      "((x 5) (y 0) (w 10) (h 10))";
    [%expect "((x 5) (y 0) (w 5) (h 10))"]
  ;;

  let%expect_test _ =
    let convert s = s |> Sexp.of_string |> t_of_sexp in
    let a = "((x 0) (y 0) (w 10) (h 10))" |> convert in
    let b = "((x 10) (y 10) (w 10) (h 10))" |> convert in
    box_intersection a b
    |> sexp_of_option sexp_of_t
    |> Sexp.to_string_hum
    |> print_endline;
    [%expect "()"]
  ;;

  let%expect_test _ =
    union_test Everything Everything;
    [%expect "Everything"]
  ;;

  let%expect_test _ =
    intersection_test Everything Everything;
    [%expect "Everything"]
  ;;

  let%expect_test _ =
    union_test Everything Nothing;
    [%expect "Everything"]
  ;;

  let%expect_test _ =
    union_test Nothing Nothing;
    [%expect "Nothing"]
  ;;

  let%expect_test _ =
    union_test
      (Something { x = 10.0; y = 10.0; w = 10.0; h = 10.0 })
      Nothing;
    [%expect "(Something ((x 10) (y 10) (w 10) (h 10)))"]
  ;;

  let%expect_test _ =
    union_test
      (Something { x = 10.0; y = 10.0; w = 10.0; h = 10.0 })
      (Something { x = 50.0; y = 50.0; w = 10.0; h = 10.0 });
    [%expect "(Something ((x 10) (y 10) (w 50) (h 50)))"]
  ;;

  let%expect_test _ =
    intersection_test
      (Something { x = 10.0; y = 10.0; w = 10.0; h = 10.0 })
      Nothing;
    [%expect "Nothing"]
  ;;
end
