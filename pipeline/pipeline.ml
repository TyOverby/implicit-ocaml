open! Core_kernel
open! Async_kernel
open Shared_types

let reshape = Reshape.reshape

let eval_chunk profile backend shape ~width ~height =
  Profile.start profile "eval chunk";
  let chunk = Chunk.create ~width ~height ~x:0 ~y:0 in
  let%bind _ = Eval.eval profile backend shape chunk in
  Profile.stop profile "eval chunk";
  return chunk
;;

let eval_lines profile backend shape ~width ~height =
  let%bind chunk = eval_chunk profile backend shape ~width ~height in
  Profile.start profile "marching squares";
  let line_buffer = March.marching_squares ~chunk in
  Profile.stop profile "marching squares";
  return line_buffer
;;

let eval_connect profile backend shape ~width ~height =
  let%bind linebuf =
    eval_lines profile backend shape ~width ~height
  in
  Profile.start profile "connect lines";
  let connected = Line_join.f linebuf in
  Profile.stop profile "connect lines";
  return connected
;;
