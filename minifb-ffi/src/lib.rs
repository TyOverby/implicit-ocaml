//! C FFI bindings for the minifb crate
//!
//! This crate provides a C-compatible API for minifb, enabling use from OCaml via ctypes.

use minifb::{Key, KeyRepeat, MouseButton, MouseMode, Window, WindowOptions};
use std::cell::RefCell;
use std::ffi::{CStr, CString};
use std::os::raw::c_char;
use std::slice;

// Thread-local storage for last error message
thread_local! {
    static LAST_ERROR: RefCell<Option<CString>> = RefCell::new(None);
}

fn set_last_error(msg: &str) {
    LAST_ERROR.with(|e| {
        *e.borrow_mut() = CString::new(msg).ok();
    });
}

/// Get the last error message, or null if no error
/// The returned pointer is valid until the next minifb call
#[no_mangle]
pub extern "C" fn minifb_get_last_error() -> *const c_char {
    LAST_ERROR.with(|e| {
        match e.borrow().as_ref() {
            Some(s) => s.as_ptr(),
            None => std::ptr::null(),
        }
    })
}

/// Keyboard key codes (mirrors minifb::Key)
#[repr(C)]
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum MiniFBKey {
    Key0 = 0,
    Key1,
    Key2,
    Key3,
    Key4,
    Key5,
    Key6,
    Key7,
    Key8,
    Key9,
    A,
    B,
    C,
    D,
    E,
    F,
    G,
    H,
    I,
    J,
    K,
    L,
    M,
    N,
    O,
    P,
    Q,
    R,
    S,
    T,
    U,
    V,
    W,
    X,
    Y,
    Z,
    F1,
    F2,
    F3,
    F4,
    F5,
    F6,
    F7,
    F8,
    F9,
    F10,
    F11,
    F12,
    F13,
    F14,
    F15,
    Down,
    Left,
    Right,
    Up,
    Apostrophe,
    Backquote,
    Backslash,
    Comma,
    Equal,
    LeftBracket,
    Minus,
    Period,
    RightBracket,
    Semicolon,
    Slash,
    Backspace,
    Delete,
    End,
    Enter,
    Escape,
    Home,
    Insert,
    Menu,
    PageDown,
    PageUp,
    Pause,
    Space,
    Tab,
    NumLock,
    CapsLock,
    ScrollLock,
    LeftShift,
    RightShift,
    LeftCtrl,
    RightCtrl,
    NumPad0,
    NumPad1,
    NumPad2,
    NumPad3,
    NumPad4,
    NumPad5,
    NumPad6,
    NumPad7,
    NumPad8,
    NumPad9,
    NumPadDot,
    NumPadSlash,
    NumPadAsterisk,
    NumPadMinus,
    NumPadPlus,
    NumPadEnter,
    LeftAlt,
    RightAlt,
    LeftSuper,
    RightSuper,
    Unknown,
    Count,
}

impl MiniFBKey {
    fn to_minifb(self) -> Key {
        match self {
            MiniFBKey::Key0 => Key::Key0,
            MiniFBKey::Key1 => Key::Key1,
            MiniFBKey::Key2 => Key::Key2,
            MiniFBKey::Key3 => Key::Key3,
            MiniFBKey::Key4 => Key::Key4,
            MiniFBKey::Key5 => Key::Key5,
            MiniFBKey::Key6 => Key::Key6,
            MiniFBKey::Key7 => Key::Key7,
            MiniFBKey::Key8 => Key::Key8,
            MiniFBKey::Key9 => Key::Key9,
            MiniFBKey::A => Key::A,
            MiniFBKey::B => Key::B,
            MiniFBKey::C => Key::C,
            MiniFBKey::D => Key::D,
            MiniFBKey::E => Key::E,
            MiniFBKey::F => Key::F,
            MiniFBKey::G => Key::G,
            MiniFBKey::H => Key::H,
            MiniFBKey::I => Key::I,
            MiniFBKey::J => Key::J,
            MiniFBKey::K => Key::K,
            MiniFBKey::L => Key::L,
            MiniFBKey::M => Key::M,
            MiniFBKey::N => Key::N,
            MiniFBKey::O => Key::O,
            MiniFBKey::P => Key::P,
            MiniFBKey::Q => Key::Q,
            MiniFBKey::R => Key::R,
            MiniFBKey::S => Key::S,
            MiniFBKey::T => Key::T,
            MiniFBKey::U => Key::U,
            MiniFBKey::V => Key::V,
            MiniFBKey::W => Key::W,
            MiniFBKey::X => Key::X,
            MiniFBKey::Y => Key::Y,
            MiniFBKey::Z => Key::Z,
            MiniFBKey::F1 => Key::F1,
            MiniFBKey::F2 => Key::F2,
            MiniFBKey::F3 => Key::F3,
            MiniFBKey::F4 => Key::F4,
            MiniFBKey::F5 => Key::F5,
            MiniFBKey::F6 => Key::F6,
            MiniFBKey::F7 => Key::F7,
            MiniFBKey::F8 => Key::F8,
            MiniFBKey::F9 => Key::F9,
            MiniFBKey::F10 => Key::F10,
            MiniFBKey::F11 => Key::F11,
            MiniFBKey::F12 => Key::F12,
            MiniFBKey::F13 => Key::F13,
            MiniFBKey::F14 => Key::F14,
            MiniFBKey::F15 => Key::F15,
            MiniFBKey::Down => Key::Down,
            MiniFBKey::Left => Key::Left,
            MiniFBKey::Right => Key::Right,
            MiniFBKey::Up => Key::Up,
            MiniFBKey::Apostrophe => Key::Apostrophe,
            MiniFBKey::Backquote => Key::Backquote,
            MiniFBKey::Backslash => Key::Backslash,
            MiniFBKey::Comma => Key::Comma,
            MiniFBKey::Equal => Key::Equal,
            MiniFBKey::LeftBracket => Key::LeftBracket,
            MiniFBKey::Minus => Key::Minus,
            MiniFBKey::Period => Key::Period,
            MiniFBKey::RightBracket => Key::RightBracket,
            MiniFBKey::Semicolon => Key::Semicolon,
            MiniFBKey::Slash => Key::Slash,
            MiniFBKey::Backspace => Key::Backspace,
            MiniFBKey::Delete => Key::Delete,
            MiniFBKey::End => Key::End,
            MiniFBKey::Enter => Key::Enter,
            MiniFBKey::Escape => Key::Escape,
            MiniFBKey::Home => Key::Home,
            MiniFBKey::Insert => Key::Insert,
            MiniFBKey::Menu => Key::Menu,
            MiniFBKey::PageDown => Key::PageDown,
            MiniFBKey::PageUp => Key::PageUp,
            MiniFBKey::Pause => Key::Pause,
            MiniFBKey::Space => Key::Space,
            MiniFBKey::Tab => Key::Tab,
            MiniFBKey::NumLock => Key::NumLock,
            MiniFBKey::CapsLock => Key::CapsLock,
            MiniFBKey::ScrollLock => Key::ScrollLock,
            MiniFBKey::LeftShift => Key::LeftShift,
            MiniFBKey::RightShift => Key::RightShift,
            MiniFBKey::LeftCtrl => Key::LeftCtrl,
            MiniFBKey::RightCtrl => Key::RightCtrl,
            MiniFBKey::NumPad0 => Key::NumPad0,
            MiniFBKey::NumPad1 => Key::NumPad1,
            MiniFBKey::NumPad2 => Key::NumPad2,
            MiniFBKey::NumPad3 => Key::NumPad3,
            MiniFBKey::NumPad4 => Key::NumPad4,
            MiniFBKey::NumPad5 => Key::NumPad5,
            MiniFBKey::NumPad6 => Key::NumPad6,
            MiniFBKey::NumPad7 => Key::NumPad7,
            MiniFBKey::NumPad8 => Key::NumPad8,
            MiniFBKey::NumPad9 => Key::NumPad9,
            MiniFBKey::NumPadDot => Key::NumPadDot,
            MiniFBKey::NumPadSlash => Key::NumPadSlash,
            MiniFBKey::NumPadAsterisk => Key::NumPadAsterisk,
            MiniFBKey::NumPadMinus => Key::NumPadMinus,
            MiniFBKey::NumPadPlus => Key::NumPadPlus,
            MiniFBKey::NumPadEnter => Key::NumPadEnter,
            MiniFBKey::LeftAlt => Key::LeftAlt,
            MiniFBKey::RightAlt => Key::RightAlt,
            MiniFBKey::LeftSuper => Key::LeftSuper,
            MiniFBKey::RightSuper => Key::RightSuper,
            MiniFBKey::Unknown | MiniFBKey::Count => Key::Unknown,
        }
    }

    fn from_minifb(key: Key) -> Self {
        match key {
            Key::Key0 => MiniFBKey::Key0,
            Key::Key1 => MiniFBKey::Key1,
            Key::Key2 => MiniFBKey::Key2,
            Key::Key3 => MiniFBKey::Key3,
            Key::Key4 => MiniFBKey::Key4,
            Key::Key5 => MiniFBKey::Key5,
            Key::Key6 => MiniFBKey::Key6,
            Key::Key7 => MiniFBKey::Key7,
            Key::Key8 => MiniFBKey::Key8,
            Key::Key9 => MiniFBKey::Key9,
            Key::A => MiniFBKey::A,
            Key::B => MiniFBKey::B,
            Key::C => MiniFBKey::C,
            Key::D => MiniFBKey::D,
            Key::E => MiniFBKey::E,
            Key::F => MiniFBKey::F,
            Key::G => MiniFBKey::G,
            Key::H => MiniFBKey::H,
            Key::I => MiniFBKey::I,
            Key::J => MiniFBKey::J,
            Key::K => MiniFBKey::K,
            Key::L => MiniFBKey::L,
            Key::M => MiniFBKey::M,
            Key::N => MiniFBKey::N,
            Key::O => MiniFBKey::O,
            Key::P => MiniFBKey::P,
            Key::Q => MiniFBKey::Q,
            Key::R => MiniFBKey::R,
            Key::S => MiniFBKey::S,
            Key::T => MiniFBKey::T,
            Key::U => MiniFBKey::U,
            Key::V => MiniFBKey::V,
            Key::W => MiniFBKey::W,
            Key::X => MiniFBKey::X,
            Key::Y => MiniFBKey::Y,
            Key::Z => MiniFBKey::Z,
            Key::F1 => MiniFBKey::F1,
            Key::F2 => MiniFBKey::F2,
            Key::F3 => MiniFBKey::F3,
            Key::F4 => MiniFBKey::F4,
            Key::F5 => MiniFBKey::F5,
            Key::F6 => MiniFBKey::F6,
            Key::F7 => MiniFBKey::F7,
            Key::F8 => MiniFBKey::F8,
            Key::F9 => MiniFBKey::F9,
            Key::F10 => MiniFBKey::F10,
            Key::F11 => MiniFBKey::F11,
            Key::F12 => MiniFBKey::F12,
            Key::F13 => MiniFBKey::F13,
            Key::F14 => MiniFBKey::F14,
            Key::F15 => MiniFBKey::F15,
            Key::Down => MiniFBKey::Down,
            Key::Left => MiniFBKey::Left,
            Key::Right => MiniFBKey::Right,
            Key::Up => MiniFBKey::Up,
            Key::Apostrophe => MiniFBKey::Apostrophe,
            Key::Backquote => MiniFBKey::Backquote,
            Key::Backslash => MiniFBKey::Backslash,
            Key::Comma => MiniFBKey::Comma,
            Key::Equal => MiniFBKey::Equal,
            Key::LeftBracket => MiniFBKey::LeftBracket,
            Key::Minus => MiniFBKey::Minus,
            Key::Period => MiniFBKey::Period,
            Key::RightBracket => MiniFBKey::RightBracket,
            Key::Semicolon => MiniFBKey::Semicolon,
            Key::Slash => MiniFBKey::Slash,
            Key::Backspace => MiniFBKey::Backspace,
            Key::Delete => MiniFBKey::Delete,
            Key::End => MiniFBKey::End,
            Key::Enter => MiniFBKey::Enter,
            Key::Escape => MiniFBKey::Escape,
            Key::Home => MiniFBKey::Home,
            Key::Insert => MiniFBKey::Insert,
            Key::Menu => MiniFBKey::Menu,
            Key::PageDown => MiniFBKey::PageDown,
            Key::PageUp => MiniFBKey::PageUp,
            Key::Pause => MiniFBKey::Pause,
            Key::Space => MiniFBKey::Space,
            Key::Tab => MiniFBKey::Tab,
            Key::NumLock => MiniFBKey::NumLock,
            Key::CapsLock => MiniFBKey::CapsLock,
            Key::ScrollLock => MiniFBKey::ScrollLock,
            Key::LeftShift => MiniFBKey::LeftShift,
            Key::RightShift => MiniFBKey::RightShift,
            Key::LeftCtrl => MiniFBKey::LeftCtrl,
            Key::RightCtrl => MiniFBKey::RightCtrl,
            Key::NumPad0 => MiniFBKey::NumPad0,
            Key::NumPad1 => MiniFBKey::NumPad1,
            Key::NumPad2 => MiniFBKey::NumPad2,
            Key::NumPad3 => MiniFBKey::NumPad3,
            Key::NumPad4 => MiniFBKey::NumPad4,
            Key::NumPad5 => MiniFBKey::NumPad5,
            Key::NumPad6 => MiniFBKey::NumPad6,
            Key::NumPad7 => MiniFBKey::NumPad7,
            Key::NumPad8 => MiniFBKey::NumPad8,
            Key::NumPad9 => MiniFBKey::NumPad9,
            Key::NumPadDot => MiniFBKey::NumPadDot,
            Key::NumPadSlash => MiniFBKey::NumPadSlash,
            Key::NumPadAsterisk => MiniFBKey::NumPadAsterisk,
            Key::NumPadMinus => MiniFBKey::NumPadMinus,
            Key::NumPadPlus => MiniFBKey::NumPadPlus,
            Key::NumPadEnter => MiniFBKey::NumPadEnter,
            Key::LeftAlt => MiniFBKey::LeftAlt,
            Key::RightAlt => MiniFBKey::RightAlt,
            Key::LeftSuper => MiniFBKey::LeftSuper,
            Key::RightSuper => MiniFBKey::RightSuper,
            Key::Unknown | Key::Count => MiniFBKey::Unknown,
        }
    }
}

/// Mouse button codes (prefixed to avoid C enum name collision with keys)
#[repr(C)]
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum MiniFBMouseButton {
    MouseLeft = 0,
    MouseMiddle = 1,
    MouseRight = 2,
}

impl MiniFBMouseButton {
    fn to_minifb(self) -> MouseButton {
        match self {
            MiniFBMouseButton::MouseLeft => MouseButton::Left,
            MiniFBMouseButton::MouseMiddle => MouseButton::Middle,
            MiniFBMouseButton::MouseRight => MouseButton::Right,
        }
    }
}

/// Mouse coordinate mode
#[repr(C)]
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum MiniFBMouseMode {
    Pass = 0,
    Clamp = 1,
    Discard = 2,
}

impl MiniFBMouseMode {
    fn to_minifb(self) -> MouseMode {
        match self {
            MiniFBMouseMode::Pass => MouseMode::Pass,
            MiniFBMouseMode::Clamp => MouseMode::Clamp,
            MiniFBMouseMode::Discard => MouseMode::Discard,
        }
    }
}

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
        Err(e) => {
            set_last_error(&format!("{:?}", e));
            std::ptr::null_mut()
        }
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

// ============================================================================
// Keyboard Input
// ============================================================================

/// Check if a key is currently held down
///
/// # Safety
/// - `window` must be a valid pointer returned by `minifb_window_new`
#[no_mangle]
pub unsafe extern "C" fn minifb_window_is_key_down(
    window: *const MiniFBWindow,
    key: MiniFBKey,
) -> bool {
    if window.is_null() {
        return false;
    }
    (*window).window.is_key_down(key.to_minifb())
}

/// Check if a key was pressed this frame
///
/// # Safety
/// - `window` must be a valid pointer returned by `minifb_window_new`
#[no_mangle]
pub unsafe extern "C" fn minifb_window_is_key_pressed(
    window: *const MiniFBWindow,
    key: MiniFBKey,
    repeat: bool,
) -> bool {
    if window.is_null() {
        return false;
    }
    let repeat_mode = if repeat {
        KeyRepeat::Yes
    } else {
        KeyRepeat::No
    };
    (*window).window.is_key_pressed(key.to_minifb(), repeat_mode)
}

/// Check if a key was released this frame
///
/// # Safety
/// - `window` must be a valid pointer returned by `minifb_window_new`
#[no_mangle]
pub unsafe extern "C" fn minifb_window_is_key_released(
    window: *const MiniFBWindow,
    key: MiniFBKey,
) -> bool {
    if window.is_null() {
        return false;
    }
    (*window).window.is_key_released(key.to_minifb())
}

/// Get all currently pressed keys
///
/// # Safety
/// - `window` must be a valid pointer returned by `minifb_window_new`
/// - `out_keys` must point to an array of at least `max_keys` MiniFBKey values
/// - `out_count` must be a valid pointer
///
/// Returns the number of keys written to `out_keys` (as integer key codes)
#[no_mangle]
pub unsafe extern "C" fn minifb_window_get_keys(
    window: *const MiniFBWindow,
    out_keys: *mut i32,
    out_count: *mut usize,
    max_keys: usize,
) {
    if window.is_null() || out_keys.is_null() || out_count.is_null() {
        if !out_count.is_null() {
            *out_count = 0;
        }
        return;
    }

    let keys = (*window).window.get_keys();
    let count = keys.len().min(max_keys);

    for (i, key) in keys.into_iter().take(max_keys).enumerate() {
        *out_keys.add(i) = MiniFBKey::from_minifb(key) as i32;
    }
    *out_count = count;
}

// ============================================================================
// Mouse Input
// ============================================================================

/// Get mouse position
///
/// # Safety
/// - `window` must be a valid pointer returned by `minifb_window_new`
/// - `out_x` and `out_y` must be valid pointers
///
/// Returns true if position is available, false otherwise
#[no_mangle]
pub unsafe extern "C" fn minifb_window_get_mouse_pos(
    window: *const MiniFBWindow,
    mode: MiniFBMouseMode,
    out_x: *mut f32,
    out_y: *mut f32,
) -> bool {
    if window.is_null() || out_x.is_null() || out_y.is_null() {
        return false;
    }

    match (*window).window.get_mouse_pos(mode.to_minifb()) {
        Some((x, y)) => {
            *out_x = x;
            *out_y = y;
            true
        }
        None => false,
    }
}

/// Check if a mouse button is currently held down
///
/// # Safety
/// - `window` must be a valid pointer returned by `minifb_window_new`
#[no_mangle]
pub unsafe extern "C" fn minifb_window_get_mouse_down(
    window: *const MiniFBWindow,
    button: MiniFBMouseButton,
) -> bool {
    if window.is_null() {
        return false;
    }
    (*window).window.get_mouse_down(button.to_minifb())
}

/// Get scroll wheel movement
///
/// # Safety
/// - `window` must be a valid pointer returned by `minifb_window_new`
/// - `out_x` and `out_y` must be valid pointers
///
/// Returns true if scroll data is available, false otherwise
#[no_mangle]
pub unsafe extern "C" fn minifb_window_get_scroll_wheel(
    window: *const MiniFBWindow,
    out_x: *mut f32,
    out_y: *mut f32,
) -> bool {
    if window.is_null() || out_x.is_null() || out_y.is_null() {
        return false;
    }

    match (*window).window.get_scroll_wheel() {
        Some((x, y)) => {
            *out_x = x;
            *out_y = y;
            true
        }
        None => false,
    }
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

    #[test]
    fn test_key_conversion() {
        // Test a few key conversions
        assert_eq!(MiniFBKey::from_minifb(Key::Escape), MiniFBKey::Escape);
        assert_eq!(MiniFBKey::Escape.to_minifb(), Key::Escape);
        assert_eq!(MiniFBKey::from_minifb(Key::Space), MiniFBKey::Space);
        assert_eq!(MiniFBKey::A.to_minifb(), Key::A);
    }
}
