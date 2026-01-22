(* FFI bindings description - used by generator to produce C stubs *)
open Ctypes
open Minifb_types

module Bindings (F : Ctypes.FOREIGN) = struct
  open F

  let get_last_error =
    foreign "minifb_get_last_error" (void @-> returning (ptr char))
  ;;

  let window_new =
    foreign
      "minifb_window_new"
      (string
       @-> size_t
       @-> size_t
       @-> ptr WindowOptions.t
       @-> returning (ptr Window.t))
  ;;

  let window_free =
    foreign "minifb_window_free" (ptr Window.t @-> returning void)
  ;;

  let window_is_open =
    foreign "minifb_window_is_open" (ptr Window.t @-> returning bool)
  ;;

  let window_update =
    foreign "minifb_window_update" (ptr Window.t @-> returning void)
  ;;

  let window_update_with_buffer =
    foreign
      "minifb_window_update_with_buffer"
      (ptr Window.t
       @-> ptr uint32_t
       @-> size_t
       @-> size_t
       @-> returning int32_t)
  ;;

  let window_get_size =
    foreign
      "minifb_window_get_size"
      (ptr Window.t @-> ptr size_t @-> ptr size_t @-> returning void)
  ;;

  let window_set_title =
    foreign
      "minifb_window_set_title"
      (ptr Window.t @-> string @-> returning void)
  ;;

  let window_set_target_fps =
    foreign
      "minifb_window_set_target_fps"
      (ptr Window.t @-> size_t @-> returning void)
  ;;

  let window_set_background_color =
    foreign
      "minifb_window_set_background_color"
      (ptr Window.t
       @-> uint8_t
       @-> uint8_t
       @-> uint8_t
       @-> returning void)
  ;;

  (* Keyboard input functions *)
  let window_is_key_down =
    foreign
      "minifb_window_is_key_down"
      (ptr Window.t @-> Key.t @-> returning bool)
  ;;

  let window_is_key_pressed =
    foreign
      "minifb_window_is_key_pressed"
      (ptr Window.t @-> Key.t @-> bool @-> returning bool)
  ;;

  let window_is_key_released =
    foreign
      "minifb_window_is_key_released"
      (ptr Window.t @-> Key.t @-> returning bool)
  ;;

  let window_get_keys =
    foreign
      "minifb_window_get_keys"
      (ptr Window.t
       @-> ptr int
       @-> ptr size_t
       @-> size_t
       @-> returning void)
  ;;

  (* Mouse input functions *)
  let window_get_mouse_pos =
    foreign
      "minifb_window_get_mouse_pos"
      (ptr Window.t
       @-> MouseMode.t
       @-> ptr float
       @-> ptr float
       @-> returning bool)
  ;;

  let window_get_mouse_down =
    foreign
      "minifb_window_get_mouse_down"
      (ptr Window.t @-> MouseButton.t @-> returning bool)
  ;;

  let window_get_scroll_wheel =
    foreign
      "minifb_window_get_scroll_wheel"
      (ptr Window.t @-> ptr float @-> ptr float @-> returning bool)
  ;;

  (* Window properties *)
  let window_set_position =
    foreign
      "minifb_window_set_position"
      (ptr Window.t @-> nativeint @-> nativeint @-> returning void)
  ;;

  let window_get_position =
    foreign
      "minifb_window_get_position"
      (ptr Window.t
       @-> ptr nativeint
       @-> ptr nativeint
       @-> returning void)
  ;;

  let window_topmost =
    foreign
      "minifb_window_topmost"
      (ptr Window.t @-> bool @-> returning void)
  ;;

  (* Cursor control *)
  let window_set_cursor_visibility =
    foreign
      "minifb_window_set_cursor_visibility"
      (ptr Window.t @-> bool @-> returning void)
  ;;

  let window_set_cursor_style =
    foreign
      "minifb_window_set_cursor_style"
      (ptr Window.t @-> CursorStyle.t @-> returning void)
  ;;
end
