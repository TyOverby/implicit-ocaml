//! C FFI bindings for the minifb crate
//!
//! This crate provides a C-compatible API for minifb, enabling use from OCaml via ctypes.

use minifb::{Window, WindowOptions};
use std::ffi::CStr;
use std::os::raw::c_char;
use std::slice;

/// Opaque window handle
pub struct MiniFBWindow {
    window: Window,
    // Store dimensions for buffer validation
    width: usize,
    height: usize,
}

/// Window creation options
#[repr(C)]
pub struct MiniFBWindowOptions {
    pub borderless: bool,
    pub title: bool,
    pub resize: bool,
    pub topmost: bool,
    pub transparency: bool,
}

/// Create default window options
#[no_mangle]
pub extern "C" fn minifb_window_options_default() -> MiniFBWindowOptions {
    MiniFBWindowOptions {
        borderless: false,
        title: true,
        resize: false,
        topmost: false,
        transparency: false,
    }
}

/// Create a new window
///
/// # Safety
/// - `name` must be a valid null-terminated C string
/// - `opts` must be a valid pointer to MiniFBWindowOptions
///
/// Returns null on failure
#[no_mangle]
pub unsafe extern "C" fn minifb_window_new(
    name: *const c_char,
    width: usize,
    height: usize,
    opts: *const MiniFBWindowOptions,
) -> *mut MiniFBWindow {
    if name.is_null() || opts.is_null() {
        return std::ptr::null_mut();
    }

    let name = match CStr::from_ptr(name).to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };

    let opts = &*opts;
    let window_opts = WindowOptions {
        borderless: opts.borderless,
        title: opts.title,
        resize: opts.resize,
        topmost: opts.topmost,
        transparency: opts.transparency,
        ..WindowOptions::default()
    };

    match Window::new(name, width, height, window_opts) {
        Ok(window) => Box::into_raw(Box::new(MiniFBWindow {
            window,
            width,
            height,
        })),
        Err(_) => std::ptr::null_mut(),
    }
}

/// Free a window
///
/// # Safety
/// - `window` must be a valid pointer returned by `minifb_window_new`, or null
/// - After calling this function, the pointer is invalid and must not be used
#[no_mangle]
pub unsafe extern "C" fn minifb_window_free(window: *mut MiniFBWindow) {
    if !window.is_null() {
        drop(Box::from_raw(window));
    }
}

/// Check if window is still open
///
/// # Safety
/// - `window` must be a valid pointer returned by `minifb_window_new`
#[no_mangle]
pub unsafe extern "C" fn minifb_window_is_open(window: *const MiniFBWindow) -> bool {
    if window.is_null() {
        return false;
    }
    (*window).window.is_open()
}

/// Update the window (process events, no buffer update)
///
/// # Safety
/// - `window` must be a valid pointer returned by `minifb_window_new`
#[no_mangle]
pub unsafe extern "C" fn minifb_window_update(window: *mut MiniFBWindow) {
    if window.is_null() {
        return;
    }
    (*window).window.update();
}

/// Update the window with a pixel buffer
///
/// # Safety
/// - `window` must be a valid pointer returned by `minifb_window_new`
/// - `buffer` must point to at least `width * height` u32 values
///
/// Returns 0 on success, -1 on error
#[no_mangle]
pub unsafe extern "C" fn minifb_window_update_with_buffer(
    window: *mut MiniFBWindow,
    buffer: *const u32,
    width: usize,
    height: usize,
) -> i32 {
    if window.is_null() || buffer.is_null() {
        return -1;
    }

    let buffer_slice = slice::from_raw_parts(buffer, width * height);
    match (*window).window.update_with_buffer(buffer_slice, width, height) {
        Ok(_) => 0,
        Err(_) => -1,
    }
}

/// Get the window size
///
/// # Safety
/// - `window` must be a valid pointer returned by `minifb_window_new`
/// - `out_width` and `out_height` must be valid pointers
#[no_mangle]
pub unsafe extern "C" fn minifb_window_get_size(
    window: *const MiniFBWindow,
    out_width: *mut usize,
    out_height: *mut usize,
) {
    if window.is_null() || out_width.is_null() || out_height.is_null() {
        return;
    }
    let (w, h) = (*window).window.get_size();
    *out_width = w;
    *out_height = h;
}

/// Set the window title
///
/// # Safety
/// - `window` must be a valid pointer returned by `minifb_window_new`
/// - `title` must be a valid null-terminated C string
#[no_mangle]
pub unsafe extern "C" fn minifb_window_set_title(window: *mut MiniFBWindow, title: *const c_char) {
    if window.is_null() || title.is_null() {
        return;
    }
    if let Ok(title_str) = CStr::from_ptr(title).to_str() {
        (*window).window.set_title(title_str);
    }
}

/// Set target FPS (limits update rate)
///
/// # Safety
/// - `window` must be a valid pointer returned by `minifb_window_new`
#[no_mangle]
pub unsafe extern "C" fn minifb_window_set_target_fps(window: *mut MiniFBWindow, fps: usize) {
    if window.is_null() {
        return;
    }
    (*window).window.set_target_fps(fps);
}

/// Set background color (RGB, 0-255 each)
///
/// # Safety
/// - `window` must be a valid pointer returned by `minifb_window_new`
#[no_mangle]
pub unsafe extern "C" fn minifb_window_set_background_color(
    window: *mut MiniFBWindow,
    red: u8,
    green: u8,
    blue: u8,
) {
    if window.is_null() {
        return;
    }
    (*window).window.set_background_color(red, green, blue);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_window_options_default() {
        let opts = minifb_window_options_default();
        assert!(!opts.borderless);
        assert!(opts.title);
        assert!(!opts.resize);
        assert!(!opts.topmost);
        assert!(!opts.transparency);
    }
}
