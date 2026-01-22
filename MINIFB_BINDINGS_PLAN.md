# OCaml Bindings for minifb Rust Crate

## Overview

Create OCaml bindings to Rust's [minifb](https://crates.io/crates/minifb) library - a minimal cross-platform framebuffer for window creation and pixel buffer rendering.

**Architecture**: Rust wrapper (C API via `extern "C"`) → cbindgen-generated headers → OCaml ctypes.stubs (static linking)

## Directory Structure

```
implicit-ocaml/
├── minifb/                          # OCaml library (static linking)
│   ├── dune                         # Build config with stub generation
│   ├── minifb_types.ml              # Shared ctypes type definitions
│   ├── minifb_bindings.ml           # FFI bindings functor
│   ├── minifb_stubs_gen.ml          # Stub generator (build-time)
│   ├── minifb_impl.ml               # User-facing API implementation
│   ├── minifb_impl.mli              # Public interface
│   └── test_minifb.ml               # Test executable
│
└── minifb-ffi/                      # Rust crate exposing C API
    ├── Cargo.toml
    ├── cbindgen.toml
    ├── build.rs
    ├── src/lib.rs
    └── include/minifb_ffi.h         # Generated C header
```

## Implementation Status

### ✅ Stage 1: Minimal (Window + Buffer Display) - COMPLETE

**Rust FFI Crate:**
- [x] Cargo.toml with minifb + cbindgen dependencies
- [x] cbindgen.toml for C header generation
- [x] build.rs to invoke cbindgen
- [x] C API: `window_new`, `window_free`, `is_open`, `update`, `update_with_buffer`
- [x] Additional: `get_size`, `set_title`, `set_target_fps`, `set_background_color`

**OCaml Library (static linking via ctypes.stubs):**
- [x] minifb_types.ml - WindowOptions and Window struct definitions
- [x] minifb_bindings.ml - Bindings functor using FOREIGN signature
- [x] minifb_stubs_gen.ml - Generates C stubs and ML bindings at build time
- [x] minifb_impl.ml - High-level OCaml API
- [x] dune - Build rules for Cargo, stub generation, static linking

**Build Integration:**
- [x] dune 3.0 with foreign_stubs and foreign_archives
- [x] Cargo build integrated via dune rule
- [x] C header copied for stub compilation
- [x] Static linking - no runtime library dependencies

**Test:**
- [x] test_minifb.ml displays gradient for 100 frames
- [x] Works with `xvfb-run` for headless testing

### ✅ Stage 2: Core (Add Input Handling) - COMPLETE

**Rust FFI:**
1. [x] Add Key enum (108 variants) with `#[repr(C)]`
2. [x] Add `minifb_window_is_key_down(window, key) -> bool`
3. [x] Add `minifb_window_is_key_pressed(window, key, repeat) -> bool`
4. [x] Add `minifb_window_get_keys(window, out_keys, out_count, max_keys)`
5. [x] Add MouseButton, MouseMode enums
6. [x] Add `minifb_window_get_mouse_pos(window, mode, out_x, out_y) -> bool`
7. [x] Add `minifb_window_get_mouse_down(window, button) -> bool`
8. [x] Add `minifb_window_get_scroll_wheel(window, out_x, out_y) -> bool`

**OCaml Bindings:**
1. [x] Add Key variant type (108 cases)
2. [x] Add key_to_int / int_to_key conversion
3. [x] Bind keyboard functions in minifb_bindings.ml
4. [x] Add MouseButton, MouseMode types
5. [x] Bind mouse functions
6. [x] Update minifb_impl.ml with high-level API
7. [x] Update minifb_impl.mli

**Test:**
- [x] Interactive demo: Escape key closes window
- [x] Mouse position affects rendering

### ✅ Stage 3: Full API (Complete Feature Set) - COMPLETE

1. [x] WindowOptions struct for creation parameters (already in Stage 1)
2. [x] Window properties: `set_position`, `get_position`, `set_topmost`
3. [x] CursorStyle enum and cursor control (`set_cursor_visibility`, `set_cursor_style`)
4. [x] Error handling improvements (detailed error messages from minifb)
5. [x] Documentation (mli file with doc comments)

**Note:** On i3 and other minimalist window managers, run with `XMODIFIERS=''` to avoid XIM issues.

## Current Usage

```ocaml
module M = Minifb.Minifb_impl

let () =
  let width = 640 and height = 480 in

  (* Create with custom options *)
  let options = { M.default_options with resize = true } in
  let window = M.create ~name:"My App" ~width ~height ~options () in
  let buffer = M.create_buffer ~width ~height in

  (* Window properties *)
  M.set_position window ~x:100 ~y:100;
  M.set_topmost window true;
  M.set_cursor_style window M.CursorStyle.Crosshair;

  (* Fill buffer with red *)
  for i = 0 to width * height - 1 do
    Bigarray.Array1.set buffer i 0x00FF0000l
  done;

  M.set_target_fps window 60;

  while M.is_open window do
    (* Check for Escape to exit *)
    if M.is_key_down window M.Key.Escape then M.close window;

    (* Get mouse position *)
    (match M.get_mouse_pos window () with
     | Some (x, y) -> Printf.printf "Mouse: %.0f, %.0f\n" x y
     | None -> ());

    (* Check mouse button *)
    if M.is_mouse_down window M.MouseButton.Left then
      print_endline "Left click!";

    M.update_with_buffer window buffer ~width ~height;
    M.update window
  done;

  M.close window
```

## Build Commands

```bash
# Build library
dune build minifb/minifb.a

# Build and run test (headless)
dune build minifb/test_minifb.exe
xvfb-run -a dune exec minifb/test_minifb.exe

# Run on i3 or other minimalist WMs (workaround for XIM issue)
XMODIFIERS='' dune exec minifb/test_minifb.exe

# Or run directly (no LD_LIBRARY_PATH needed - static linking!)
xvfb-run -a _build/default/minifb/test_minifb.exe
```

## Key Design Decisions

1. **Static linking via ctypes.stubs** - No runtime library dependencies, single executable
2. **Opaque pointer pattern** - Window handle is abstract, prevents misuse
3. **Enums as C-compatible integers** - `#[repr(C)]` in Rust, int conversion in OCaml
4. **Bigarray for pixel buffer** - Zero-copy, efficient memory sharing with Rust
5. **Build-time code generation** - minifb_stubs_gen.ml produces C and ML stubs
