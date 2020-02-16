open! Core_kernel

let tests =
  [ "circle"
  ; "intersection"
  ; "union"
  ; "kissing_circles"
  ; "scale"
  ; "mix"
  ]
;;

let executable_rule name =
  sprintf
    {|
 (executable
   (name %s)
   (modules %s)
   (preprocess (pps ppx_jane))
   (libraries core_kernel shape example_runner))
 |}
    name
    name
;;

let shape_sexp_rule name =
  sprintf
    {|
   (rule
     (with-stdout-to %s_actual.shape.sexp
      (run ./%s.exe)))
 |}
    name
    name
;;

let linebuf_rule name =
  sprintf
    {|(rule
  (deps %s_actual.shape.sexp)
  (targets %s.linebuf.sexp)
  (action (bash "cat %%{deps} | %%{exe:../utilities/shape_to_linebuf/shape_to_linebuf.exe} > %%{targets}")))
|}
    name
    name
;;

let connected_rule name =
  sprintf
    {|(rule
  (deps %s.linebuf.sexp)
  (targets %s_actual.connected.sexp)
  (action (bash "cat %%{deps} | %%{exe:../utilities/linebuf_to_connected/linebuf_to_connected.exe} > %%{targets}")))
|}
    name
    name
;;

let parts_svg_rule name =
  sprintf
    {|(rule
  (deps %s.linebuf.sexp)
  (targets %s_actual.parts.svg)
  (action (bash "cat %%{deps} | %%{exe:../utilities/linebuf_to_svg/linebuf_to_svg.exe} > %%{targets}")))
|}
    name
    name
;;

let connected_svg_rule name =
  sprintf
    {|(rule
  (deps %s.connected.sexp)
  (targets %s_actual.connected.svg)
  (action (bash "cat %%{deps} | %%{exe:../utilities/connected_to_svg/connected_to_svg.exe} > %%{targets}")))
|}
    name
    name
;;

let validate_test name =
  sprintf
    {|(alias
 (name runtest)
 (deps %s.linebuf.sexp)
 (action (bash "cat %s.linebuf.sexp | %%{exe:../utilities/linebuf_validate/linebuf_validate.exe}")))|}
    name
    name
;;

let diff_against_actual_shape name =
  sprintf
    {|(alias
 (name runtest)
 (action (diff %s.shape.sexp %s_actual.shape.sexp)))|}
    name
    name
;;

let diff_against_actual_connected name =
  sprintf
    {|(alias
 (name runtest)
 (action (diff %s.connected.sexp %s_actual.connected.sexp)))|}
    name
    name
;;

let diff_against_actual_connected_svg name =
  sprintf
    {|(alias
 (name runtest)
 (action (diff %s.connected.svg %s_actual.connected.svg)))|}
    name
    name
;;

let diff_against_actual_parts_svg name =
  sprintf
    {|(alias
 (name runtest)
 (action (diff %s.parts.svg %s_actual.parts.svg)))|}
    name
    name
;;

let () =
  tests
  |> List.bind ~f:(fun name ->
         [ sprintf "; %s" name
         ; executable_rule name
         ; shape_sexp_rule name
         ; linebuf_rule name
         ; parts_svg_rule name
         ; connected_svg_rule name
         ; connected_rule name (* ; validate_test name*)
         ; diff_against_actual_shape name
         ; diff_against_actual_connected name
         ; diff_against_actual_parts_svg name
         ; diff_against_actual_connected_svg name
         ])
  |> List.map ~f:String.strip
  |> List.bind ~f:(fun s ->
         if String.is_prefix s ~prefix:";" then [ ""; s ] else [ s ])
  |> List.iter ~f:print_endline
;;
