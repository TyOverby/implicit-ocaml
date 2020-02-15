open! Core_kernel
open Example_runner

let () =
  let r : inexact t =
    subtract
      (circle ~r:10.0 ~x:15.0 ~y:15.0 |> scale ~dx:2.0 ~dy:2.0)
      (circle ~r:10.0 ~x:15.0 ~y:15.0)
  in
  run r
;;
