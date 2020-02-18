open! Core_kernel
open Example_runner

let repeat a ~every = a |> repeat_x ~every |> repeat_y ~every
let b r = circle ~r ~x:r ~y:r |> repeat ~every:(r *. 2.0)

let () =
  run
    (intersection
       [ circle ~r:40.0 ~x:44.0 ~y:44.0; b 18.0; b 6.0; b 2.0 ])
;;
