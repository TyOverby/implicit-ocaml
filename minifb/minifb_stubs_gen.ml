(* Stub generator - run at build time to generate C stubs *)
let () =
  let prefix = "minifb_stub" in
  let generate_ml, generate_c =
    match Sys.argv with
    | [| _; "ml" |] -> true, false
    | [| _; "c" |] -> false, true
    | _ -> failwith "Usage: minifb_stubs_gen [ml|c]"
  in
  if generate_ml
  then
    Cstubs.write_ml
      Format.std_formatter
      ~prefix
      (module Minifb_bindings.Bindings);
  if generate_c
  then (
    print_endline "#include \"minifb_ffi.h\"";
    Cstubs.write_c
      Format.std_formatter
      ~prefix
      (module Minifb_bindings.Bindings))
;;
