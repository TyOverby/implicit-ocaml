open! Core
open! Example_runner

let () =
  run
    (union
       [ circle ~r:20.0 ~x:30.0 ~y:30.0
       ; circle ~r:20.0 ~x:40.0 ~y:40.0
       ])
;;
