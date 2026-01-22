(** OCaml bindings to the minifb framebuffer library *)

(** Opaque window handle *)
type t

(** Pixel buffer type - Bigarray of 32-bit unsigned integers in 0xAARRGGBB format *)
type pixel_buffer = (int32, Bigarray.int32_elt, Bigarray.c_layout) Bigarray.Array1.t

(** Window creation options *)
type window_options = {
  borderless : bool;
  title : bool;
  resize : bool;
  topmost : bool;
  transparency : bool;
}

(** Default window options *)
val default_options : window_options

(** Create a new window.
    @param name Window title
    @param width Window width in pixels
    @param height Window height in pixels
    @param options Window creation options (optional, uses defaults if not provided)
    @return A new window handle
    @raise Failure if window creation fails *)
val create : name:string -> width:int -> height:int -> ?options:window_options -> unit -> t

(** Close and free window resources. The window handle should not be used after this. *)
val close : t -> unit

(** Check if window is still open (user hasn't closed it) *)
val is_open : t -> bool

(** Update window - process events without updating the buffer *)
val update : t -> unit

(** Update window with pixel buffer.
    @param t Window handle
    @param buffer Pixel buffer (must have at least width * height elements)
    @param width Buffer width
    @param height Buffer height
    @raise Failure if buffer update fails *)
val update_with_buffer : t -> pixel_buffer -> width:int -> height:int -> unit

(** Get the current window size.
    @return (width, height) tuple *)
val get_size : t -> int * int

(** Set the window title *)
val set_title : t -> string -> unit

(** Set target frames per second (limits update rate) *)
val set_target_fps : t -> int -> unit

(** Set background color (RGB, 0-255 each) *)
val set_background_color : t -> r:int -> g:int -> b:int -> unit

(** Create a pixel buffer of the given dimensions, initialized to black *)
val create_buffer : width:int -> height:int -> pixel_buffer
