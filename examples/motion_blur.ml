open! Core_kernel
open Example_runner

let boilerplate shape =
  run_scene
    (Scene.create
       ~padding:6
       ~target_width:88
       ~target_height:88
       ~layers:[ Layer.create ~shape ~color:"black" ])
;;

let smooth_many ~k = function
  | [] -> failwith "smooth_many on empty_list"
  | hd :: xs -> List.fold xs ~init:hd ~f:(smooth_union ~k)
;;

let () =
  boilerplate
    (smooth_many
       ~k:10.0
       [ circle ~r:10.0 ~x:35.0 ~y:20.0
       ; circle ~r:7.0 ~x:20.0 ~y:20.0
       ; circle ~r:4.0 ~x:20.0 ~y:35.0
       ])
;;
