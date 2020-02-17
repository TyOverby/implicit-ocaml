open! Core_kernel
open Example_runner

let () =
  run
    (intersection
       [ circle ~r:40.0 ~x:44.0 ~y:44.0
       ; circle ~r:10.0 ~x:10.0 ~y:10.0
         |> repeat_x ~every:22.0
         |> repeat_y ~every:22.0
       ; circle ~r:5.0 ~x:2.0 ~y:2.0
         |> repeat_x ~every:7.0
         |> repeat_y ~every:7.0
       ])
;;
