open! Core
open! Async
open Shared_types
module Debug = Compile.Debug

let run = Compile.jit
let address_of = Ctypes.bigarray_start Ctypes.array1

let apply profile t ~f =
  Profile.start profile "run sampling";
  let array = Chunk.to_underlying t in
  let ptr = address_of array in
  let length = Float_bigarray.length array in
  let r = f ~x:(Chunk.x t) ~y:(Chunk.y t) ptr length in
  Profile.stop profile "run sampling";
  r
;;
