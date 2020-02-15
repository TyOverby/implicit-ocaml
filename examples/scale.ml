open! Core_kernel
open Example_runner

let () =
  run
    (subtract
       (circle ~r:10.0 ~x:15.0 ~y:15.0 |> scale ~dx:2.0 ~dy:2.0)
       (circle ~r:10.0 ~x:15.0 ~y:15.0))
;;
