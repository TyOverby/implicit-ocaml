open! Core_kernel
open! Async
open Shared_types

let eval_chunk shape =
  let chunk = Chunk.create ~x:0 ~y:0 in
  let%bind _ = Shape_eval.Eval.eval shape chunk in
  return chunk
;;

let eval_lines shape =
  let%bind chunk = eval_chunk shape in
  let line_buffer =
    March.marching_squares ~chunk ~width:88 ~height:88
  in
  return line_buffer
;;