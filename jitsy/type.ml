type 'a t =
  { ctype : 'a Ctypes.typ
  ; string_repr : string
  }

let to_string { string_repr; _ } = string_repr
let int = { ctype = Ctypes.int; string_repr = "int" }
let int32 = { ctype = Ctypes.int32_t; string_repr = "int32_t" }
let uint32 = { ctype = Ctypes.uint32_t; string_repr = "uint32_t" }
let float = { ctype = Ctypes.float; string_repr = "float" }
let bool = { ctype = Ctypes.bool; string_repr = "_Bool" }
let unit = { ctype = Ctypes.void; string_repr = "void" }
let float_array = { ctype = Ctypes.ptr Ctypes.float; string_repr = "float*" }
let int32_array = { ctype = Ctypes.ptr Ctypes.int32_t; string_repr = "int32_t*" }
