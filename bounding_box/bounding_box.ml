open! Core_kernel
open Shared_types
open Box

let both_everything =
  { Box.positive = Everything; negative = Everything }
;;

let rec compute_bounding_box = function
  | Shape.Intersection [] | Union [] | Circle { r = 0.0; _ } ->
    { positive = Nothing; negative = Everything }
  | Circle { x; y; r } ->
    let bb = { x = x -. r; y = y -. r; h = 2.0 *. r; w = 2.0 *. r } in
    { positive = Something bb; negative = Hole bb }
  | Union targets ->
    targets |> compute_all_bounding_box |> Box.union_all
  | Smooth_union { a; b; _ } ->
    [ a; b ] |> compute_all_bounding_box |> Box.union_all
  | Mix { a; b; _ } ->
    [ a; b ] |> compute_all_bounding_box |> Box.union_all
  | Intersection targets ->
    targets |> compute_all_bounding_box |> Box.intersection_all
  | Modulate { shape; by } ->
    compute_bounding_box shape |> (Fn.flip Box.grow) by
  | Invert target -> target |> compute_bounding_box |> Box.inverse
  | Repeat_x _ | Repeat_y _ -> both_everything
  | Transform { shape = target; matrix } ->
    let bb = compute_bounding_box target in
    let positive =
      match bb.positive with
      | Something b -> Something (Matrix.apply_to_rect matrix b)
      | Hole b -> Hole (Matrix.apply_to_rect matrix b)
      | Everything -> Everything
      | Nothing -> Nothing
    in
    let negative =
      match bb.negative with
      | Something b -> Something (Matrix.apply_to_rect matrix b)
      | Hole b -> Hole (Matrix.apply_to_rect matrix b)
      | Everything -> Everything
      | Nothing -> Nothing
    in
    { positive; negative }

and compute_all_bounding_box list =
  list |> List.map ~f:compute_bounding_box
;;

(*_
let rec compute_bounding_box = function
  | Shape.Transform (target, matrix) ->
    let bb = compute_bounding_box target in
    let positive =
      match bb.positive with
      | Something b -> Something (Matrix.apply_to_rect matrix b)
      | Hole b -> Hole (Matrix.apply_to_rect matrix b)
      | Everything -> Everything
      | Nothing -> Nothing
    in
    let negative =
      match bb.negative with
      | Something b -> Something (Matrix.apply_to_rect matrix b)
      | Hole b -> Hole (Matrix.apply_to_rect matrix b)
      | Everything -> Everything
      | Nothing -> Nothing
    in
    { positive; negative }
  | Intersection []
  | Union []
  | Terminal (Poly { points = []; _ })
  | Terminal (Circle { r = 0.0; _ }) ->
    { positive = Nothing; negative = Everything }
  | Terminal (Simplex _) -> both_everything
  | Terminal (Circle { x; y; r }) ->
    let bb =
      { x = x -. r; y = y -. r; h = 2.0 *. r; w = 2.0 *. r }
    in
    { positive = Something bb; negative = Hole bb }
  | Terminal (Rect { x; y; w; h }) ->
    let bb = { x; y; w; h } in
    { positive = Something bb; negative = Hole bb }
  | Terminal (Poly { points }) ->
    let box = points |> bbox_of_points |> Option.value_exn in
    { positive = Something box; negative = Everything }
  | Not target -> target |> compute_bounding_box |> Box.inverse
  | Freeze target -> target |> compute_bounding_box
  | Drag (target, dx, dy) ->
    Creator.union [ target; target |> Creator.translate ~dx ~dy ]
    |> compute_bounding_box
  (* TODO: this is potentially quadratic *)
  | Union targets ->
    targets |> compute_all_bounding_box |> Box.union_all
  | Intersection targets ->
    targets |> compute_all_bounding_box |> Box.intersection_all
  | Modulate (target, how_much) ->
    compute_bounding_box target |> (Fn.flip Box.grow) how_much

and compute_all_bounding_box list =
  list |> List.map ~f:compute_bounding_box
*)

module ComputeBB_Test = struct
  open Shape

  let run_bb_test shape =
    shape
    |> compute_bounding_box
    |> sexp_of_bounding
    |> Sexp.to_string_hum
    |> print_endline
  ;;

  (*_
    let%expect_test _ =
      rect ~x:0.0 ~y:0.0 ~w:10.0 ~h:20.0 |> run_bb_test;
      [%expect
        {|
         ((positive (Something ((x 0) (y 0) (w 10) (h 20))))
          (negative (Hole ((x 0) (y 0) (w 10) (h 20)))))|}]
    ;;

    let%expect_test _ =
      rect ~x:0.0 ~y:0.0 ~w:10.0 ~h:10.0
      |> scale ~dx:3.0 ~dy:5.0
      |> run_bb_test;
      [%expect
        {|
         ((positive (Something ((x 0) (y 0) (w 30) (h 50))))
          (negative (Hole ((x 0) (y 0) (w 30) (h 50)))))|}]
    ;;

    let%expect_test _ =
      rect ~x:0.0 ~y:0.0 ~w:10.0 ~h:10.0
      |> scale ~dx:3.0 ~dy:3.0
      |> translate ~dx:5.0 ~dy:5.0
      |> run_bb_test;
      [%expect
        {|
         ((positive (Something ((x 5) (y 5) (w 30) (h 30))))
          (negative (Hole ((x 5) (y 5) (w 30) (h 30)))))|}]
    ;;
  *)
  let%expect_test _ =
    circle ~x:0.0 ~y:0.0 ~r:10.0
    |> scale ~dx:3.0 ~dy:3.0
    |> run_bb_test;
    [%expect
      {|
       ((positive
         (Something
          ((x -3.333333333333333) (y -3.333333333333333) (w 6.6666666666666661)
           (h 6.6666666666666661))))
        (negative
         (Hole
          ((x -3.333333333333333) (y -3.333333333333333) (w 6.6666666666666661)
           (h 6.6666666666666661)))))|}]
  ;;

  (*
  let%expect_test _ =
    rect ~x:(-10.0) ~y:(-10.0) ~w:20.0 ~h:20.0
    |> scale ~dx:3.0 ~dy:3.0
    |> run_bb_test;
    [%expect
      {|
       ((positive (Something ((x -30) (y -30) (w 60) (h 60))))
        (negative (Hole ((x -30) (y -30) (w 60) (h 60)))))|}]
  ;;
  *)

  let%expect_test _ =
    let outer = circle ~x:0.0 ~y:0.0 ~r:10.0 in
    let inner = circle ~x:0.0 ~y:0.0 ~r:5.0 in
    let ring = intersection [ outer; invert inner ] in
    ring |> scale ~dy:3.0 ~dx:3.0 |> run_bb_test;
    [%expect
      {|
       ((positive
         (Something
          ((x -3.333333333333333) (y -3.333333333333333) (w 6.6666666666666661)
           (h 6.6666666666666661))))
        (negative
         (Hole
          ((x -3.333333333333333) (y -3.333333333333333) (w 6.6666666666666661)
           (h 6.6666666666666661)))))|}]
  ;;

  let%expect_test _ =
    let outer = circle ~x:0.0 ~y:0.0 ~r:10.0 in
    let inner = circle ~x:0.0 ~y:0.0 ~r:5.0 in
    let ring = intersection [ outer; invert inner ] in
    ring
    |> scale ~dy:3.0 ~dx:3.0
    |> translate ~dy:30.0 ~dx:30.0
    |> run_bb_test;
    [%expect
      {|
       ((positive
         (Something
          ((x -33.333333333333336) (y -33.333333333333336) (w 6.6666666666666679)
           (h 6.6666666666666679))))
        (negative
         (Hole
          ((x -33.333333333333336) (y -33.333333333333336) (w 6.6666666666666679)
           (h 6.6666666666666679)))))|}]
  ;;

  let%expect_test _ =
    let outer = circle ~x:0.0 ~y:0.0 ~r:10.0 in
    let inner = circle ~x:0.0 ~y:0.0 ~r:5.0 in
    let ring = intersection [ outer; invert inner ] in
    ring
    |> scale ~dy:3.0 ~dx:3.0
    |> translate ~dy:30.0 ~dx:30.0
    |> invert
    |> run_bb_test;
    [%expect
      {|
       ((positive
         (Hole
          ((x -33.333333333333336) (y -33.333333333333336) (w 6.6666666666666679)
           (h 6.6666666666666679))))
        (negative
         (Something
          ((x -33.333333333333336) (y -33.333333333333336) (w 6.6666666666666679)
           (h 6.6666666666666679)))))|}]
  ;;

  let%expect_test _ =
    circle ~x:0.0 ~y:0.0 ~r:10.0
    |> scale ~dy:3.0 ~dx:3.0
    |> run_bb_test;
    [%expect
      {|
       ((positive
         (Something
          ((x -3.333333333333333) (y -3.333333333333333) (w 6.6666666666666661)
           (h 6.6666666666666661))))
        (negative
         (Hole
          ((x -3.333333333333333) (y -3.333333333333333) (w 6.6666666666666661)
           (h 6.6666666666666661)))))|}]
  ;;

  let%expect_test _ =
    circle ~x:0.0 ~y:0.0 ~r:10.0 |> modulate ~by:10.0 |> run_bb_test;
    [%expect
      {| 
      ((positive (Something ((x -20) (y -20) (w 40) (h 40))))
       (negative (Hole ((x -20) (y -20) (w 40) (h 40)))))|}]
  ;;

  (*
  let%expect_test _ =
    circle ~x:0.0 ~y:0.0 ~r:10.0
    |> drag ~dx:10.0 ~dy:0.0
    |> run_bb_test;
    [%expect
      {|
       ((positive (Something ((x -10) (y -10) (w 30) (h 20))))
        (negative (Hole ((x -10) (y -10) (w 30) (h 20)))))|}]
  ;;
  *)
end
