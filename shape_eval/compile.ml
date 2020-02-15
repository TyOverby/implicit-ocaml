open! Core_kernel
open Shape

let rec compile t ~x ~y =
  match t with
  | Invert t -> Jitsy.Expr.neg_float (compile ~x ~y t)
  | Union [] -> failwith "union on empty list"
  | Union [ a ] -> compile ~x ~y a
  | Union [ a; b ] ->
    Jitsy.Expr.min_float (compile ~x ~y a) (compile ~x ~y b)
  | Union l ->
    let len = List.length l in
    let l1, l2 = List.split_n l (len / 2) in
    Jitsy.Expr.min_float
      (compile ~x ~y (Union l1))
      (compile ~x ~y (Union l2))
  | Intersection [] -> failwith "union on empty list"
  | Intersection [ a ] -> compile ~x ~y a
  | Intersection [ a; b ] ->
    Jitsy.Expr.max_float (compile ~x ~y a) (compile ~x ~y b)
  | Intersection l ->
    let len = List.length l in
    let l1, l2 = List.split_n l (len / 2) in
    Jitsy.Expr.max_float
      (compile ~x ~y (Intersection l1))
      (compile ~x ~y (Intersection l2))
  | Circle { x = cx; y = cy; r } ->
    let open Jitsy.Expr in
    let dx = sub_float (float_lit cx) x in
    let dy = sub_float (float_lit cy) y in
    let dx2 = square_float dx in
    let dy2 = square_float dy in
    let dx2_plus_dy2 = add_float dx2 dy2 in
    let sqrt = sqrt_float dx2_plus_dy2 in
    sub_float sqrt (float_lit r)
  | Modulate { shape; by } ->
    let open Jitsy.Expr in
    add_float (compile ~x ~y shape) (float_lit by)
  | Transform { shape = _; matrix = _ } -> failwith "unimplemented"
;;
