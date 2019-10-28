open! Core_kernel

let tests = [ "circle"; "intersection"; "union" ]

let linebuf_rule name =
  sprintf
    {|(rule
  (deps %s.shape.sexp)
  (targets %s.linebuf.sexp)
  (action (bash "cat %%{deps} | %%{exe:../utilities/shape_to_linebuf/shape_to_linebuf.exe} > %%{targets}")))
|}
    name
    name
;;

let svg_rule name =
  sprintf
    {|(rule
  (deps %s.linebuf.sexp)
  (targets %s_actual.svg)
  (action (bash "cat %%{deps} | %%{exe:../utilities/linebuf_to_svg/linebuf_to_svg.exe} > %%{targets}")))
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

let diff_against_actual name =
  sprintf
    {|(alias
 (name runtest)
 (action (diff %s.svg %s_actual.svg)))|}
    name
    name
;;

;;
tests |> 
List.bind ~f:(fun name ->
 [ sprintf "; %s" name;
    linebuf_rule name;
    svg_rule name;
    validate_test name;
    diff_against_actual name])
|> List.map ~f:(String.strip)
|> List.bind ~f:(fun s -> 
  if String.is_prefix s ~prefix:";"
  then [""; s] 
  else [s])
|> List.iter ~f:(print_endline)

;;
