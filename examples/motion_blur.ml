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

let () =
  boilerplate
    (mix
       ~f:0.5
       (circle ~r:10.0 ~x:15.0 ~y:0.0)
       (mix
          ~f:1.0
          (circle ~r:10.0 ~x:0.0 ~y:0.0)
          (circle ~r:10.0 ~x:0.0 ~y:15.0)))
;;
