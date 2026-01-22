open! Core
open Example_runner

let smooth_many ~k = function
  | [] -> failwith "smooth_many on empty_list"
  | hd :: xs -> List.fold xs ~init:hd ~f:(smooth_union ~k)
;;

let () =
  run
    (smooth_many
       ~k:10.0
       [ circle ~r:10.0 ~x:35.0 ~y:20.0
       ; circle ~r:7.0 ~x:20.0 ~y:20.0
       ; circle ~r:4.0 ~x:20.0 ~y:35.0
       ])
;;
