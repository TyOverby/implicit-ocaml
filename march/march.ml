open Ctypes

let typ = ptr float @-> uint32_t @-> uint32_t @-> returning void
;;

let rust_march = 
 let lib = Dl.dlopen ~filename:"/home/tyoverby/workspace/ocaml/jitsy/_build/default/march/dllmarch_stubs.so" ~flags:[Dl.RTLD_NOW] in
(* let lib = Dl.dlopen ~filename:"dllmarch_stubs.so" ~flags:[Dl.RTLD_NOW] in *)
 Foreign.foreign ~from:lib "rust_march"  typ
;;

let run () = 
 print_endline "hi from ocaml";
 let w = Unsigned.UInt32.of_int (88) in 
 let h = Unsigned.UInt32.of_int (99) in 
 rust_march (Obj.magic (Ctypes.ptr_of_raw_address (Nativeint.of_int 0))) w h;
 ()

