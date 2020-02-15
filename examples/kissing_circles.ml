open! Core_kernel
open! Example_runner

let () =
  run
    (union
       [ circle ~x:30.0 ~y:30.0 ~r:15.0
       ; circle ~x:60.0 ~y:30.0 ~r:15.0
       ; circle ~x:30.0 ~y:60.0 ~r:15.0
       ; circle ~x:60.0 ~y:60.0 ~r:15.0
       ; circle ~x:45.0 ~y:45.0 ~r:6.21320
       ])
;;
