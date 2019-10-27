open! Core_kernel
open! Async
open Shared_types

let eval_chunk shape =
  let chunk = Chunk.create ~x:0 ~y:0 in
  let%bind _ = Shape_eval.Eval.eval shape chunk in
  return chunk
;;

let _eval_lines shape =
  let%bind chunk = eval_chunk shape in
  return chunk
;;
