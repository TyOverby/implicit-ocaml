open! Core_kernel
open! Async_kernel
open Shared_types

let eval_chunk backend shape =
  let chunk = Chunk.create ~width:88 ~height:88 ~x:0 ~y:0 in
  let%bind _ = Shape.Eval.eval backend shape chunk in
  return chunk
;;

let eval_lines backend shape =
  let%bind chunk = eval_chunk backend shape in
  let line_buffer =
    March.marching_squares ~chunk ~width:88 ~height:88
  in
  return line_buffer
;;

let eval_connect backend shape =
  let%bind linebuf = eval_lines backend shape in
  let connected = Line_join.f linebuf in
  return connected
;;
