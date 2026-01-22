# OCaml Bindings for minifb Rust Crate

## Overview

Create OCaml bindings to Rust's [minifb](https://crates.io/crates/minifb) library - a minimal cross-platform framebuffer for window creation and pixel buffer rendering.

**Architecture**: Rust wrapper (C API via `extern "C"`) → cbindgen-generated headers → OCaml ctypes bindings

## Directory Structure

```
implicit-ocaml/
├── minifb/                      # OCaml library
│   ├── dune
│   ├── minifb.ml
│   └── minifb.mli
│
└── minifb-ffi/                  # Rust crate exposing C API
    ├── Cargo.toml
    ├── cbindgen.toml
    ├── build.rs
    └── src/lib.rs
```

## Phase 1: Rust FFI Crate (minifb-ffi)

### Files to Create

**minifb-ffi/Cargo.toml**
```toml
[package]
name = "minifb-ffi"
version = "0.1.0"
edition = "2021"

[lib]
crate-type = ["staticlib", "cdylib"]

[dependencies]
minifb = "0.28"

[build-dependencies]
cbindgen = "0.29"
```

**minifb-ffi/cbindgen.toml** - Configure header generation

**minifb-ffi/build.rs** - Invoke cbindgen to generate `minifb_ffi.h`

**minifb-ffi/src/lib.rs** - Core implementation:

### C API Functions to Expose

```rust
// Window lifecycle
#[no_mangle] pub extern "C" fn minifb_window_new(...) -> *mut MiniFBWindow
#[no_mangle] pub extern "C" fn minifb_window_free(window: *mut MiniFBWindow)
#[no_mangle] pub extern "C" fn minifb_window_is_open(...) -> bool

// Buffer rendering
#[no_mangle] pub extern "C" fn minifb_window_update(...)
#[no_mangle] pub extern "C" fn minifb_window_update_with_buffer(
    window: *mut MiniFBWindow,
    buffer: *const u32,  // 32-bit ARGB pixels
    width: usize,
    height: usize
) -> i32

// Keyboard input
#[no_mangle] pub extern "C" fn minifb_window_is_key_down(...) -> bool
#[no_mangle] pub extern "C" fn minifb_window_get_keys(...)

// Mouse input
#[no_mangle] pub extern "C" fn minifb_window_get_mouse_pos(...) -> bool
#[no_mangle] pub extern "C" fn minifb_window_get_mouse_down(...) -> bool
#[no_mangle] pub extern "C" fn minifb_window_get_scroll_wheel(...) -> bool

// Window properties
#[no_mangle] pub extern "C" fn minifb_window_set_title(...)
#[no_mangle] pub extern "C" fn minifb_window_get_size(...)
#[no_mangle] pub extern "C" fn minifb_window_set_position(...)

// Cursor & performance
#[no_mangle] pub extern "C" fn minifb_window_set_cursor_style(...)
#[no_mangle] pub extern "C" fn minifb_window_set_target_fps(...)
```

### Key Design Decisions

1. **Opaque pointer pattern**: `Box::into_raw()` for Window, `Box::from_raw()` for cleanup
2. **Enums as C-compatible integers**: `#[repr(C)]` for Key (108 variants), MouseButton, CursorStyle, etc.
3. **WindowOptions as struct**: Pass configuration at creation time

## Phase 2: OCaml Bindings (minifb/)

### Files to Create

**minifb/minifb.mli** - Public interface:
```ocaml
type t  (* opaque window handle *)
type pixel_buffer = (int32, Bigarray.int32_elt, Bigarray.c_layout) Bigarray.Array1.t

type key = Key0 | Key1 | ... | Escape | Space | ... (* 108 keys *)
type mouse_button = Left | Middle | Right
type cursor_style = Arrow | Ibeam | Crosshair | ...

val create : name:string -> width:int -> height:int -> unit -> t
val close : t -> unit
val is_open : t -> bool
val update : t -> unit
val update_with_buffer : t -> pixel_buffer -> width:int -> height:int -> unit

val is_key_down : t -> key -> bool
val get_mouse_pos : t -> (float * float) option
val get_mouse_down : t -> mouse_button -> bool

val create_buffer : width:int -> height:int -> pixel_buffer
```

**minifb/minifb.ml** - Implementation following `march/march.ml` pattern:
```ocaml
open Ctypes

type t = unit ptr
type pixel_buffer = (int32, Bigarray.int32_elt, Bigarray.c_layout) Bigarray.Array1.t

let address_of = Ctypes.bigarray_start Ctypes.array1

let update_with_buffer_ffi =
  Foreign.foreign "minifb_window_update_with_buffer"
    (ptr void @-> ptr int32_t @-> size_t @-> size_t @-> returning int)
(* ... etc *)
```

**minifb/dune** - Build configuration (dune 1.10 compatible):
```lisp
(library
 (name minifb)
 (modules minifb)
 (c_names minifb_stubs)  ; thin C wrapper that links to Rust static lib
 (c_flags :standard)
 (c_library_flags (-L../minifb-ffi/target/release -lminifb_ffi -lpthread -ldl -lX11))
 (preprocess (pps ppx_jane))
 (libraries ctypes ctypes.foreign))
```

Note: Since dune 1.10 doesn't support `foreign_archives`, we'll need a thin C stub file (`minifb_stubs.c`) or a Makefile/shell script to build the Rust library first.

## Phase 3: Build Integration

**Decision**: Upgrade dune to 3.x for native Rust/foreign archive support.

### Update dune-project
```lisp
(lang dune 3.0)
```

### Dune Rule for Cargo Build
```lisp
(rule
 (deps (source_tree ../minifb-ffi))
 (targets libminifb_ffi.a)
 (action
  (progn
   (run cargo build --release --manifest-path ../minifb-ffi/Cargo.toml)
   (copy ../minifb-ffi/target/release/libminifb_ffi.a libminifb_ffi.a))))

(library
 (name minifb)
 (foreign_archives minifb_ffi)
 (c_library_flags -lpthread -ldl -lX11)
 (libraries ctypes ctypes.foreign))
```

### Platform: Linux/X11 First
- Initial linking flags: `-lpthread -ldl -lX11`
- Expand to macOS/Windows later

## Implementation Order

**Approach**: Start minimal, expand incrementally.

### Stage 1: Minimal (Window + Buffer Display)
1. Upgrade `dune-project` to dune 3.0
2. Create `minifb-ffi/` Rust crate:
   - Cargo.toml, cbindgen.toml, build.rs
   - `minifb_window_new`, `_free`, `_is_open`, `_update`, `_update_with_buffer`
3. Create `minifb/` OCaml library:
   - Basic types: `t`, `pixel_buffer`
   - Functions: `create`, `close`, `is_open`, `update`, `update_with_buffer`, `create_buffer`
4. Dune build integration with `foreign_archives`
5. **Test**: Display solid color in window

### Stage 2: Core (Add Input Handling)
1. Add Key enum (108 variants) to both Rust and OCaml
2. Keyboard: `is_key_down`, `is_key_pressed`, `is_key_released`, `get_keys`
3. Add MouseButton, MouseMode enums
4. Mouse: `get_mouse_pos`, `get_mouse_down`, `get_scroll_wheel`
5. **Test**: Interactive demo responding to keyboard/mouse

### Stage 3: Full API (Complete Feature Set)
1. WindowOptions struct for creation parameters (borderless, resize, scale, etc.)
2. Window properties: `set_title`, `set_position`, `get_size`, `topmost`
3. CursorStyle enum and cursor control: `set_cursor_visibility`, `set_cursor_style`
4. Performance: `set_target_fps`
5. Error handling with Result types
6. Memory safety verification (GC finalizers)
7. **Test**: Full-featured demo application

## Key Files to Reference

- `march/march.ml:6-31` - ctypes Foreign.foreign pattern with Bigarray
- `march/dune:1-9` - C library integration pattern
- `types/float_bigarray.ml` - Bigarray wrapper (adapt for int32)

## Testing Strategy

### 1. Rust FFI Crate Tests (minifb-ffi/)

**Unit tests** in `src/lib.rs`:
```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_window_options_default() {
        let opts = minifb_window_options_default();
        assert!(!opts.borderless);
        assert!(opts.title);
    }

    // Note: Window creation tests require a display, so they should be
    // marked #[ignore] for CI environments without X11
    #[test]
    #[ignore]
    fn test_window_lifecycle() {
        let name = std::ffi::CString::new("Test").unwrap();
        let opts = minifb_window_options_default();
        let window = minifb_window_new(name.as_ptr(), 100, 100, &opts);
        assert!(!window.is_null());
        assert!(minifb_window_is_open(window));
        minifb_window_free(window);
    }
}
```

Run with: `cd minifb-ffi && cargo test` (use `cargo test -- --ignored` for display tests)

### 2. OCaml Tests (minifb/)

**Inline expect tests** in `minifb.ml` using ppx_jane:
```ocaml
let%expect_test "buffer creation" =
  let buf = create_buffer ~width:10 ~height:10 in
  printf "Buffer size: %d\n" (Bigarray.Array1.dim buf);
  [%expect {| Buffer size: 100 |}]

(* Window tests require display, use separate test executable *)
```

**Dedicated test executable** `minifb/test_minifb.ml`:
```ocaml
(* Manual visual tests - run interactively *)
let () =
  let w = Minifb.create ~name:"Test" ~width:200 ~height:200 () in
  let buf = Minifb.create_buffer ~width:200 ~height:200 in
  (* Fill with gradient *)
  for y = 0 to 199 do
    for x = 0 to 199 do
      let r = x * 255 / 200 in
      let g = y * 255 / 200 in
      Bigarray.Array1.set buf (y * 200 + x) (Int32.of_int (r lsl 16 lor g lsl 8))
    done
  done;
  for _ = 1 to 100 do  (* Run for ~100 frames then exit *)
    Minifb.update_with_buffer w buf ~width:200 ~height:200;
    Minifb.update w
  done;
  Minifb.close w;
  print_endline "Test passed: window displayed gradient"
```

### 3. Test Dune Configuration

Add to `minifb/dune`:
```lisp
(executable
 (name test_minifb)
 (modules test_minifb)
 (libraries minifb))

(rule
 (alias runtest)
 (deps test_minifb.exe)
 (action (run %{deps})))
```

### 4. Screenshot-Based Testing (Headless CI)

Use Xvfb + ImageMagick for automated visual testing (see `screenshot_test_demo.sh`):

**test_minifb_screenshot.sh**:
```bash
#!/bin/bash
set -e

DISPLAY_NUM=99
SCREEN_SIZE="800x600x24"
SCREENSHOT="./test_output.png"
EXPECTED="./expected_output.png"

cleanup() {
    [ -n "$APP_PID" ] && kill "$APP_PID" 2>/dev/null || true
    [ -n "$XVFB_PID" ] && kill "$XVFB_PID" 2>/dev/null || true
}
trap cleanup EXIT

# Start virtual display
Xvfb :$DISPLAY_NUM -screen 0 $SCREEN_SIZE &
XVFB_PID=$!
export DISPLAY=:$DISPLAY_NUM
sleep 1

# Run minifb test app (renders for N frames then exits)
./test_minifb.exe &
APP_PID=$!
sleep 2  # wait for window to render

# Capture screenshot
import -window root "$SCREENSHOT"

# Compare with expected (optional - use perceptual diff)
# compare -metric AE "$SCREENSHOT" "$EXPECTED" diff.png
echo "Screenshot saved to $SCREENSHOT"
```

**Key tools**:
- `Xvfb` - X virtual framebuffer (headless display)
- `import` - ImageMagick screenshot capture
- `compare` - ImageMagick image comparison (for regression testing)

**CI workflow**:
1. Build test executable that renders known pattern and exits after N frames
2. Run in Xvfb environment
3. Capture screenshot
4. Compare against expected baseline (or just verify it doesn't crash)

### 5. Test Checklist by Stage

**Stage 1 (Minimal)**:
- [ ] Rust: `cargo test` passes
- [ ] Rust: `cargo build --release` produces `libminifb_ffi.a`
- [ ] OCaml: `dune build @minifb/all` succeeds
- [ ] Visual: Window opens and displays solid color

**Stage 2 (Core)**:
- [ ] Keyboard: Press Escape closes window
- [ ] Keyboard: `get_keys` returns correct key list
- [ ] Mouse: Position tracking works
- [ ] Mouse: Button clicks detected

**Stage 3 (Full)**:
- [ ] Window title changes correctly
- [ ] Window position/size APIs work
- [ ] Cursor styles change visually
- [ ] FPS limiting works (measure frame timing)
- [ ] No memory leaks (run with valgrind or similar)

## Verification

After implementation, test with:
```ocaml
let () =
  let w = Minifb.create ~name:"Test" ~width:640 ~height:480 () in
  let buf = Minifb.create_buffer ~width:640 ~height:480 in
  (* Fill with red *)
  for i = 0 to 640 * 480 - 1 do
    Bigarray.Array1.set buf i 0x00FF0000l
  done;
  while Minifb.is_open w do
    Minifb.update_with_buffer w buf ~width:640 ~height:480;
    Minifb.update w;
    if Minifb.is_key_down w Minifb.Escape then Minifb.close w
  done
```
