open Ctypes 
open Shared_types

(* Marching Squares
  extern void run_marching_squares(
    float* buffer,
    unsigned int width,
    unsigned int height,
    int* atomic
    float* out)
 *)

external _marching_squares : unit -> unit = "run_marching_squares"

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
  fun ~input_block ~width ~height ->
    let intpos = (Ctypes.allocate int) 0 in 
    let out_size = 88 * 88 * 2 in 
    let out = Float_bigarray.create out_size in
    fn
      (Float_bigarray.address_of input_block)
      width
      height
      intpos
      (Float_bigarray.address_of out);
    print_int !@intpos;
    out, !@intpos
;;
