open! Core_kernel
open Shared_types
open Bounding_box
open Box

let reshape shape ~target_width ~target_height ~padding =
  let bb, shape =
    match (compute_bounding_box shape).positive with
    | Something b -> b, shape
    | _ -> failwith "non-normal shapes can't be reshaped yet"
  in
  let target_width = Float.of_int (target_width - (padding * 2)) in
  let target_height = Float.of_int (target_height - (padding * 2)) in
  shape
  |> Shape.translate ~dx:(-.bb.x) ~dy:(-.bb.y)
  |> Shape.scale
       ~dx:(target_width /. bb.Box.w)
       ~dy:(target_height /. bb.Box.h)
  |> Shape.translate
       ~dx:(Float.of_int padding)
       ~dy:(Float.of_int padding)
;;
