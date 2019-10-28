open! Core_kernel

let tests = [ "circle"; "intersection"; "union" ]

let linebuf_rule name =
  printf
{|(rule
  (deps %s.shape.sexp)
  (targets %s.linebuf.sexp)
  (action (bash "cat %%{deps} | %%{exe:../utilities/shape_to_linebuf/shape_to_linebuf.exe} > %%{targets}")))
|}
    name
    name
;;

let svg_rule name = 
  printf
{|(rule
  (deps %s.linebuf.sexp)
  (targets %s.svg)
  (action (bash "cat %%{deps} | %%{exe:../utilities/linebuf_to_svg/linebuf_to_svg.exe} > %%{targets}")))
|} name name

;;

let validate_test name = 
 printf 
{|(alias
 (name runtest)
 (action (run ../utilities/linebuf_validate/linebuf_validate.exe %s.linebuf.sexp)))|}
 name

let diff_against_actual name = 
 printf 
 {|(alias
 (name runtest)
 (action (diff %s.svg actual_%s.svg)))|} name name


;;
List.iter tests ~f:(fun name -> linebuf_rule name; 
print_endline "";
svg_rule name;
print_endline "";
validate_test name;
print_endline "";
diff_against_actual name;
)
;;
print_endline ""
