open! Core_kernel
open! Async
open Shared_types

let eval_chunk shape =
  let chunk = Chunk.create ~width:88 ~height:88 ~x:0 ~y:0 in
  let%bind _ = Shape.Eval.eval shape chunk in
  return chunk
;;

let eval_lines shape =
  let%bind chunk = eval_chunk shape in
  let line_buffer =
    March.marching_squares ~chunk ~width:88 ~height:88
  in
  return line_buffer
;;

let eval_connect shape =
  let%bind linebuf = eval_lines shape in
  let connected = Line_join.f linebuf in
  return connected
;;
