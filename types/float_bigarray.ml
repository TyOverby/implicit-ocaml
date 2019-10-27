open! Core_kernel

type t =
  (float, Bigarray.float32_elt, Bigarray.c_layout) Bigarray.Array1.t

let to_array t =
  let len = Bigarray.Array1.dim t in
  let arr = Array.create ~len 0.0 in
  List.range 0 len |> List.iter ~f:(fun i -> arr.(i) <- t.{i});
  arr
;;

let of_array arr =
  let len = Array.length arr in
  let bigarray =
    Bigarray.Array1.create Bigarray.float32 Bigarray.c_layout len
  in
  List.range 0 len |> List.iter ~f:(fun i -> bigarray.{i} <- arr.(i));
  bigarray
;;

let sexp_of_t t = t |> to_array |> sexp_of_float_array
let t_of_sexp t = t |> float_array_of_sexp |> of_array
let address_of = Ctypes.bigarray_start Ctypes.array1
let length = Bigarray.Array1.dim

let create size =
  let array =
    Bigarray.Array1.create Bigarray.float32 Bigarray.c_layout size
  in
  Bigarray.Array1.fill array 0.0;
  array
;;

let get t i = t.{i}
let sub t start end_ = Bigarray.Array1.sub t start end_
