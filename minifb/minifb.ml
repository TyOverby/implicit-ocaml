open Ctypes

(* Pixel buffer type *)
type pixel_buffer = (int32, Bigarray.int32_elt, Bigarray.c_layout) Bigarray.Array1.t

(* Window options *)
type window_options = {
  borderless : bool;
  title : bool;
  resize : bool;
  topmost : bool;
  transparency : bool;
}

let default_options =
  { borderless = false; title = true; resize = false; topmost = false; transparency = false }
;;

(* C struct for window options *)
let window_options_struct : window_options structure typ = structure "MiniFBWindowOptions"
let opt_borderless = field window_options_struct "borderless" bool
let opt_title = field window_options_struct "title" bool
let opt_resize = field window_options_struct "resize" bool
let opt_topmost = field window_options_struct "topmost" bool
let opt_transparency = field window_options_struct "transparency" bool
let () = seal window_options_struct

(* Opaque window pointer *)
type minifb_window

let minifb_window : minifb_window structure typ = structure "MiniFBWindow"

(* Window handle - wraps the pointer *)
type t = minifb_window structure ptr

(* Load the shared library explicitly *)
let lib =
  (* Get the directory containing the executable *)
  let exe_dir =
    try Filename.dirname (Unix.readlink "/proc/self/exe") with
    | _ -> Filename.dirname Sys.executable_name
  in
  let paths_to_try =
    [ (* Same directory as executable *)
      Filename.concat exe_dir "dllminifb_ffi.so"
    ; (* Current working directory *)
      "dllminifb_ffi.so"
    ; "./dllminifb_ffi.so"
    ; "_build/default/minifb/dllminifb_ffi.so"
      (* System library paths *)
    ; "libminifb_ffi.so"
    ]
  in
  let rec try_paths = function
    | [] -> Dl.dlopen ~filename:"" ~flags:[ Dl.RTLD_NOW ]
    | path :: rest ->
      (try Dl.dlopen ~filename:path ~flags:[ Dl.RTLD_NOW; Dl.RTLD_GLOBAL ] with
       | Dl.DL_error _ -> try_paths rest)
  in
  try_paths paths_to_try
;;

let foreign name typ = Foreign.foreign ~from:lib name typ

(* FFI bindings *)
let minifb_window_new =
  foreign
    "minifb_window_new"
    (string @-> size_t @-> size_t @-> ptr window_options_struct @-> returning (ptr minifb_window))
;;

let minifb_window_free = foreign "minifb_window_free" (ptr minifb_window @-> returning void)

let minifb_window_is_open =
  foreign "minifb_window_is_open" (ptr minifb_window @-> returning bool)
;;

let minifb_window_update = foreign "minifb_window_update" (ptr minifb_window @-> returning void)

let minifb_window_update_with_buffer =
  foreign
    "minifb_window_update_with_buffer"
    (ptr minifb_window @-> ptr uint32_t @-> size_t @-> size_t @-> returning int32_t)
;;

let minifb_window_get_size =
  foreign
    "minifb_window_get_size"
    (ptr minifb_window @-> ptr size_t @-> ptr size_t @-> returning void)
;;

let minifb_window_set_title =
  foreign "minifb_window_set_title" (ptr minifb_window @-> string @-> returning void)
;;

let minifb_window_set_target_fps =
  foreign "minifb_window_set_target_fps" (ptr minifb_window @-> size_t @-> returning void)
;;

let minifb_window_set_background_color =
  foreign
    "minifb_window_set_background_color"
    (ptr minifb_window @-> uint8_t @-> uint8_t @-> uint8_t @-> returning void)
;;

(* Helper to get bigarray start pointer *)
let address_of ba = Ctypes.bigarray_start Ctypes.array1 ba

(* OCaml API *)
let create ~name ~width ~height ?(options = default_options) () =
  let c_opts = make window_options_struct in
  setf c_opts opt_borderless options.borderless;
  setf c_opts opt_title options.title;
  setf c_opts opt_resize options.resize;
  setf c_opts opt_topmost options.topmost;
  setf c_opts opt_transparency options.transparency;
  let window =
    minifb_window_new
      name
      (Unsigned.Size_t.of_int width)
      (Unsigned.Size_t.of_int height)
      (addr c_opts)
  in
  if is_null window then failwith "Failed to create window";
  window
;;

let close window = minifb_window_free window
let is_open window = minifb_window_is_open window
let update window = minifb_window_update window

let update_with_buffer window buffer ~width ~height =
  (* Cast int32 bigarray to uint32 pointer *)
  let ptr = address_of buffer |> Ctypes.coerce (ptr int32_t) (ptr uint32_t) in
  let result =
    minifb_window_update_with_buffer
      window
      ptr
      (Unsigned.Size_t.of_int width)
      (Unsigned.Size_t.of_int height)
  in
  if Int32.compare result 0l <> 0 then failwith "Failed to update buffer"
;;

let get_size window =
  let out_width = allocate size_t Unsigned.Size_t.zero in
  let out_height = allocate size_t Unsigned.Size_t.zero in
  minifb_window_get_size window out_width out_height;
  Unsigned.Size_t.to_int !@out_width, Unsigned.Size_t.to_int !@out_height
;;

let set_title window title = minifb_window_set_title window title
let set_target_fps window fps = minifb_window_set_target_fps window (Unsigned.Size_t.of_int fps)

let set_background_color window ~r ~g ~b =
  minifb_window_set_background_color
    window
    (Unsigned.UInt8.of_int r)
    (Unsigned.UInt8.of_int g)
    (Unsigned.UInt8.of_int b)
;;

let create_buffer ~width ~height =
  let size = width * height in
  let buffer = Bigarray.Array1.create Bigarray.int32 Bigarray.c_layout size in
  Bigarray.Array1.fill buffer 0l;
  buffer
;;
