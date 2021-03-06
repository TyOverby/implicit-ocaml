open! Core_kernel
open Shared_types.Shape

let rec compile t ~x ~y =
  let open Jitsy.Ops.Float in
  match t with
  | Invert t -> Jitsy.Expr.neg_float (compile ~x ~y t)
  | Union [] -> failwith "union on empty list"
  | Union [ a ] -> compile ~x ~y a
  | Union [ a; b ] -> min (compile ~x ~y a) (compile ~x ~y b)
  | Union l ->
    let len = List.length l in
    let l1, l2 = List.split_n l Int.(len / 2) in
    min (compile ~x ~y (Union l1)) (compile ~x ~y (Union l2))
  | Intersection [] -> failwith "union on empty list"
  | Intersection [ a ] -> compile ~x ~y a
  | Intersection [ a; b ] -> max (compile ~x ~y a) (compile ~x ~y b)
  | Intersection l ->
    let len = List.length l in
    let l1, l2 = List.split_n l Int.(len / 2) in
    max
      (compile ~x ~y (Intersection l1))
      (compile ~x ~y (Intersection l2))
  | Circle { x = cx; y = cy; r } ->
    let dx = const cx - x in
    let dy = const cy - y in
    let dx2 = square dx in
    let dy2 = square dy in
    let dx2_plus_dy2 = dx2 + dy2 in
    let sqrt = sqrt dx2_plus_dy2 in
    sqrt - const r
  | Modulate { shape; by } -> compile ~x ~y shape + const by
  | Smooth_union { a; b; k } ->
    let d1 = compile ~x ~y a in
    let d2 = compile ~x ~y b in
    let k = const k
    and one = const 1.0
    and _05 = const 0.5 in
    let clamp a ~small ~large = min large (max small a) in
    let mix a b f = ((one - f) * b) + (f * a) in
    let h =
      clamp
        (_05 + (_05 * (d1 - d2) / k))
        ~small:(const 0.0)
        ~large:(const 1.0)
    in
    mix d2 d1 h - (k * h * (one - h))
  | Mix { a; b; f } ->
    let f = Float.clamp_exn ~min:0.0 ~max:1.0 f in
    let f = const f in
    let a = compile ~x ~y a in
    let b = compile ~x ~y b in
    let one = const 1.0 in
    ((one - f) * b) + (f * a)
  | Transform { shape; matrix = { m11; m12; m21; m22; m31; m32 } } ->
    let m11 = const m11
    and m12 = const m12
    and m21 = const m21
    and m22 = const m22
    and m31 = const m31
    and m32 = const m32 in
    let x = (x * m11) + (y * m21) + m31
    and y = (x * m12) + (y * m22) + m32 in
    (* and z = x * m13 + y * m23 + z * m33 + m43 in *)
    (* and w = x * m14 + y * m24 + z * m34 + m44 in *)
    compile ~x ~y shape
  | Repeat_x { shape; every } ->
    let x = x % const every in
    compile ~x ~y shape
  | Repeat_y { shape; every } ->
    let y = y % const every in
    compile ~x ~y shape
;;
