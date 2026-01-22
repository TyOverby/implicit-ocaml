open! Core
open Shared_types
open Box

let reshape profile bb shape ~target_width ~target_height ~padding =
  Profile.start profile "reshape";
  let bb =
    match bb.positive with
    | Something bb -> bb
    | _ -> failwith "non-normal shapes can't be reshaped yet"
  in
  let target_width = Float.of_int (target_width - (padding * 2)) in
  let target_height = Float.of_int (target_height - (padding * 2)) in
  let scale_x = target_width /. bb.Box.w in
  let scale_y = target_height /. bb.Box.h in
  let scale = Float.min scale_x scale_y in
  let shape =
    shape
    |> Shape.translate ~dx:(-.bb.x) ~dy:(-.bb.y)
    |> Shape.scale ~dx:scale ~dy:scale
    |> Shape.translate
         ~dx:(Float.of_int padding)
         ~dy:(Float.of_int padding)
  in
  Profile.stop profile "reshape";
  shape
;;
