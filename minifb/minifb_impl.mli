(** OCaml bindings to the minifb framebuffer library (static linking
    version) *)

type t

type pixel_buffer =
  (int32, Bigarray.int32_elt, Bigarray.c_layout) Bigarray.Array1.t

type window_options =
  { borderless : bool
  ; title : bool
  ; resize : bool
  ; topmost : bool
  ; transparency : bool
  }

val default_options : window_options

val create
  :  name:string
  -> width:int
  -> height:int
  -> ?options:window_options
  -> unit
  -> t

val close : t -> unit
val is_open : t -> bool
val update : t -> unit

val update_with_buffer
  :  t
  -> pixel_buffer
  -> width:int
  -> height:int
  -> unit

val get_size : t -> int * int
val set_title : t -> string -> unit
val set_target_fps : t -> int -> unit
val set_background_color : t -> r:int -> g:int -> b:int -> unit
val create_buffer : width:int -> height:int -> pixel_buffer

(** Keyboard key codes *)
module Key : sig
  type t =
    | Key0
    | Key1
    | Key2
    | Key3
    | Key4
    | Key5
    | Key6
    | Key7
    | Key8
    | Key9
    | A
    | B
    | C
    | D
    | E
    | F
    | G
    | H
    | I
    | J
    | K
    | L
    | M
    | N
    | O
    | P
    | Q
    | R
    | S
    | T
    | U
    | V
    | W
    | X
    | Y
    | Z
    | F1
    | F2
    | F3
    | F4
    | F5
    | F6
    | F7
    | F8
    | F9
    | F10
    | F11
    | F12
    | F13
    | F14
    | F15
    | Down
    | Left
    | Right
    | Up
    | Apostrophe
    | Backquote
    | Backslash
    | Comma
    | Equal
    | LeftBracket
    | Minus
    | Period
    | RightBracket
    | Semicolon
    | Slash
    | Backspace
    | Delete
    | End
    | Enter
    | Escape
    | Home
    | Insert
    | Menu
    | PageDown
    | PageUp
    | Pause
    | Space
    | Tab
    | NumLock
    | CapsLock
    | ScrollLock
    | LeftShift
    | RightShift
    | LeftCtrl
    | RightCtrl
    | NumPad0
    | NumPad1
    | NumPad2
    | NumPad3
    | NumPad4
    | NumPad5
    | NumPad6
    | NumPad7
    | NumPad8
    | NumPad9
    | NumPadDot
    | NumPadSlash
    | NumPadAsterisk
    | NumPadMinus
    | NumPadPlus
    | NumPadEnter
    | LeftAlt
    | RightAlt
    | LeftSuper
    | RightSuper
    | Unknown
end

(** Mouse buttons *)
module MouseButton : sig
  type t =
    | Left
    | Middle
    | Right
end

(** Mouse coordinate modes *)
module MouseMode : sig
  type t =
    | Pass
    | Clamp
    | Discard
end

(** Keyboard input *)

val is_key_down : t -> Key.t -> bool
val is_key_pressed : t -> Key.t -> repeat:bool -> bool
val is_key_released : t -> Key.t -> bool
val get_keys : t -> Key.t list

(** Mouse input *)

val get_mouse_pos
  :  t
  -> ?mode:MouseMode.t
  -> unit
  -> (float * float) option

val is_mouse_down : t -> MouseButton.t -> bool
val get_scroll_wheel : t -> (float * float) option
