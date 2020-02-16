open! Core_kernel
open! Example_runner

let s =
  {|
(Transform
     (shape
      (Transform
       (shape
        (Transform
         (shape
          (Intersection
           ((Circle (x 40) (y 40) (r 10))
            (Invert (Circle (x 40) (y 40) (r 7.5))))))
         (matrix ((m11 1) (m12 0) (m21 0) (m22 1) (m31 30) (m32 30)))))
       (matrix
        ((m11 0.26315789473684209) (m12 0) (m21 0) (m22 0.26315789473684209)
         (m31 0) (m32 0)))))
     (matrix ((m11 1) (m12 0) (m21 0) (m22 1) (m31 -6) (m32 -6))))
|}
  |> Sexp.of_string
  |> Shared_types.Shape.t_of_sexp
  |> Shared_types.Shape.to_type_safe
;;

let () = run s
