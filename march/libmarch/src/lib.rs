#[no_mangle]
pub extern "C" fn rust_march(field: *const f32, width: u32, height: u32) {
    println!("{:?}: {:?}x{:?}", field, width, height);
}
