(* Static bindings implementation - uses generated C stubs, no dlopen *)
open Ctypes
module T = Minifb_types

(* Instantiate the bindings with the generated stubs *)
module C = Minifb_bindings.Bindings (Minifb_generated)

(* Pixel buffer type *)
type pixel_buffer =
  (int32, Bigarray.int32_elt, Bigarray.c_layout) Bigarray.Array1.t

(* Window options *)
type window_options =
  { borderless : bool
  ; title : bool
  ; resize : bool
  ; topmost : bool
  ; transparency : bool
  }

let default_options =
  { borderless = false
  ; title = true
  ; resize = false
  ; topmost = false
  ; transparency = false
  }
;;

(* Window handle *)
type t = T.Window.t structure ptr

(* Helper to get bigarray start pointer *)
let address_of ba = Ctypes.bigarray_start Ctypes.array1 ba

(* OCaml API *)
let create ~name ~width ~height ?(options = default_options) () =
  let c_opts = make T.WindowOptions.t in
  setf c_opts T.WindowOptions.borderless options.borderless;
  setf c_opts T.WindowOptions.title options.title;
  setf c_opts T.WindowOptions.resize options.resize;
  setf c_opts T.WindowOptions.topmost options.topmost;
  setf c_opts T.WindowOptions.transparency options.transparency;
  let window =
    C.window_new
      name
      (Unsigned.Size_t.of_int width)
      (Unsigned.Size_t.of_int height)
      (addr c_opts)
  in
  if is_null window
  then (
    let err_ptr = C.get_last_error () in
    let msg =
      if is_null err_ptr
      then "Failed to create window (unknown error)"
      else
        Printf.sprintf
          "Failed to create window: %s"
          (coerce (ptr char) string err_ptr)
    in
    failwith msg);
  window
;;

let close window = C.window_free window
let is_open window = C.window_is_open window
let update window = C.window_update window

let update_with_buffer window buffer ~width ~height =
  let ptr =
    address_of buffer |> Ctypes.coerce (ptr int32_t) (ptr uint32_t)
  in
  let result =
    C.window_update_with_buffer
      window
      ptr
      (Unsigned.Size_t.of_int width)
      (Unsigned.Size_t.of_int height)
  in
  if Int32.compare result 0l <> 0
  then failwith "Failed to update buffer"
;;

let get_size window =
  let out_width = allocate size_t Unsigned.Size_t.zero in
  let out_height = allocate size_t Unsigned.Size_t.zero in
  C.window_get_size window out_width out_height;
  ( Unsigned.Size_t.to_int !@out_width
  , Unsigned.Size_t.to_int !@out_height )
;;

let set_title window title = C.window_set_title window title

let set_target_fps window fps =
  C.window_set_target_fps window (Unsigned.Size_t.of_int fps)
;;

let set_background_color window ~r ~g ~b =
  C.window_set_background_color
    window
    (Unsigned.UInt8.of_int r)
    (Unsigned.UInt8.of_int g)
    (Unsigned.UInt8.of_int b)
;;

let create_buffer ~width ~height =
  let size = width * height in
  let buffer =
    Bigarray.Array1.create Bigarray.int32 Bigarray.c_layout size
  in
  Bigarray.Array1.fill buffer 0l;
  buffer
;;

(* Re-export types from minifb_types *)
module Key = T.Key
module MouseButton = T.MouseButton
module MouseMode = T.MouseMode

(* Keyboard input *)
let is_key_down window key =
  C.window_is_key_down window (Key.to_int key)
;;

let is_key_pressed window key ~repeat =
  C.window_is_key_pressed window (Key.to_int key) repeat
;;

let is_key_released window key =
  C.window_is_key_released window (Key.to_int key)
;;

let get_keys window =
  let max_keys = 128 in
  let out_keys = CArray.make int max_keys in
  let out_count = allocate size_t Unsigned.Size_t.zero in
  C.window_get_keys
    window
    (CArray.start out_keys)
    out_count
    (Unsigned.Size_t.of_int max_keys);
  let count = Unsigned.Size_t.to_int !@out_count in
  let keys = ref [] in
  for i = 0 to count - 1 do
    keys := Key.of_int (CArray.get out_keys i) :: !keys
  done;
  List.rev !keys
;;

(* Mouse input *)
let get_mouse_pos window ?(mode = MouseMode.Pass) () =
  let out_x = allocate float 0.0 in
  let out_y = allocate float 0.0 in
  let valid =
    C.window_get_mouse_pos window (MouseMode.to_int mode) out_x out_y
  in
  if valid then Some (!@out_x, !@out_y) else None
;;

let is_mouse_down window button =
  C.window_get_mouse_down window (MouseButton.to_int button)
;;

let get_scroll_wheel window =
  let out_x = allocate float 0.0 in
  let out_y = allocate float 0.0 in
  let valid = C.window_get_scroll_wheel window out_x out_y in
  if valid then Some (!@out_x, !@out_y) else None
;;

(* Re-export CursorStyle *)
module CursorStyle = T.CursorStyle

(* Window properties *)
let set_position window ~x ~y =
  C.window_set_position
    window
    (Nativeint.of_int x)
    (Nativeint.of_int y)
;;

let get_position window =
  let out_x = allocate nativeint Nativeint.zero in
  let out_y = allocate nativeint Nativeint.zero in
  C.window_get_position window out_x out_y;
  Nativeint.to_int !@out_x, Nativeint.to_int !@out_y
;;

let set_topmost window topmost = C.window_topmost window topmost

(* Cursor control *)
let set_cursor_visibility window visible =
  C.window_set_cursor_visibility window visible
;;

let set_cursor_style window style =
  C.window_set_cursor_style window (CursorStyle.to_int style)
;;
