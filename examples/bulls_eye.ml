open! Core
open Example_runner

let () =
  run_scene
    (Scene.create
       ~padding:6
       ~target_width:88
       ~target_height:88
       ~layers:
         [ Layer.create
             ~shape:
               (subtract
                  (circle ~r:10.0 ~x:40.0 ~y:40.0)
                  (circle ~r:7.5 ~x:40.0 ~y:40.0))
             ~color:"red"
         ; Layer.create
             ~shape:(circle ~r:5.0 ~x:40.0 ~y:40.0)
             ~color:"black"
         ])
;;
