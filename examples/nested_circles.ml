open! Core_kernel
open Example_runner

let boilerplate shape =
  run_scene
    (Scene.create
       ~padding:6
       ~target_width:500
       ~target_height:500
       ~layers:[ Layer.create ~shape ~color:"black" ])
;;

let repeat a ~every = a |> repeat_x ~every |> repeat_y ~every
let b r = circle ~r ~x:r ~y:r |> repeat ~every:(r *. 2.0)

let () =
  boilerplate
    (intersection
       [ circle ~r:54.0 ~x:54.0 ~y:54.0; b 18.0; b 6.0; b 2.0 ])
;;
