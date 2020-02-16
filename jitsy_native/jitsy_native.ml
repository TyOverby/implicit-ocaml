open! Core_kernel
open! Async
open Shared_types
module Debug = Compile.Debug

let run = Compile.jit
let address_of = Ctypes.bigarray_start Ctypes.array1

let apply t ~f =
  let array = Chunk.to_underlying t in
  let ptr = address_of array in
  let length = Float_bigarray.length array in
  f ~x:(Chunk.x t) ~y:(Chunk.y t) ptr length
;;
