open Ctypes
open Shared_types

external _marching_squares : unit -> unit = "run_marching_squares"

let address_of = Ctypes.bigarray_start Ctypes.array1

let marching_squares =
  let typ =
    ptr float
    @-> uint
    @-> uint
    @-> ptr int
    @-> ptr float
    @-> returning void
  in
  let fn = Foreign.foreign "run_marching_squares" typ in
  fun ~chunk ->
    let width = Chunk.width chunk
    and height = Chunk.height chunk in
    let intpos = (Ctypes.allocate int) 0 in
    let out_size = width * height * 4 in
    let out = Float_bigarray.create out_size in
    fn
      (chunk |> Chunk.to_underlying |> address_of)
      (Unsigned.UInt.of_int width)
      (Unsigned.UInt.of_int height)
      intpos
      (address_of out);
    assert (!@intpos < out_size);
    Float_bigarray.sub out 0 (!@intpos * 4)
;;
