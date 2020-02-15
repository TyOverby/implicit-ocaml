open! Core_kernel
open Example_runner

let () =
  run
    (mix
       ~f:0.5
       (circle ~r:10.0 ~x:25.0 ~y:25.0)
       (circle ~r:10.0 ~x:15.0 ~y:15.0))
;;
