open! Core_kernel
open! Async_kernel
open Shared_types

let eval
    (type d)
    (module B : Jitsy.Backend.S with type Debug.t = d)
    shape
    chunk
  =
  let compiled = Compile.compile shape in
  let f =
    let open Jitsy in
    let open Function.Let_syntax in
    let%bind x_offset = Type.int in
    let%bind y_offset = Type.int in
    let%bind array = Type.float_array in
    let%bind a = Type.int in
    let open Expr in
    let iwidth = int_lit (Chunk.width chunk) in
    let iheight = int_lit (Chunk.height chunk) in
    return
      (Expr.progn
         [ Expr.range2
             ~width:iwidth
             ~height:iheight
             ~f:(fun ~x ~y ~pos ->
               let x, y = int_to_float x, int_to_float y in
               let x =
                 x_offset
                 |> mul_int iwidth
                 |> int_to_float
                 |> add_float x
               in
               let y =
                 y_offset
                 |> mul_int iheight
                 |> int_to_float
                 |> add_float y
               in
               array_set array pos (compiled ~x ~y))
         ]
         a)
  in
  let%map fn, debug = B.run f in
  let fn ~x ~y = fn x y in
  let (_ : _) = B.apply chunk ~f:fn in
  debug
;;
