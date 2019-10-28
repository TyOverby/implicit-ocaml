
; circle
(rule
  (deps circle.shape.sexp)
  (targets circle.linebuf.sexp)
  (action (bash "cat %{deps} | %{exe:../utilities/shape_to_linebuf/shape_to_linebuf.exe} > %{targets}")))
(rule
  (deps circle.linebuf.sexp)
  (targets circle_actual.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/linebuf_to_svg/linebuf_to_svg.exe} > %{targets}")))
(alias
 (name runtest)
 (deps circle.linebuf.sexp)
 (action (bash "cat circle.linebuf.sexp | %{exe:../utilities/linebuf_validate/linebuf_validate.exe}")))
(alias
 (name runtest)
 (action (diff circle.svg circle_actual.svg)))

; intersection
(rule
  (deps intersection.shape.sexp)
  (targets intersection.linebuf.sexp)
  (action (bash "cat %{deps} | %{exe:../utilities/shape_to_linebuf/shape_to_linebuf.exe} > %{targets}")))
(rule
  (deps intersection.linebuf.sexp)
  (targets intersection_actual.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/linebuf_to_svg/linebuf_to_svg.exe} > %{targets}")))
(alias
 (name runtest)
 (deps intersection.linebuf.sexp)
 (action (bash "cat intersection.linebuf.sexp | %{exe:../utilities/linebuf_validate/linebuf_validate.exe}")))
(alias
 (name runtest)
 (action (diff intersection.svg intersection_actual.svg)))

; union
(rule
  (deps union.shape.sexp)
  (targets union.linebuf.sexp)
  (action (bash "cat %{deps} | %{exe:../utilities/shape_to_linebuf/shape_to_linebuf.exe} > %{targets}")))
(rule
  (deps union.linebuf.sexp)
  (targets union_actual.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/linebuf_to_svg/linebuf_to_svg.exe} > %{targets}")))
(alias
 (name runtest)
 (deps union.linebuf.sexp)
 (action (bash "cat union.linebuf.sexp | %{exe:../utilities/linebuf_validate/linebuf_validate.exe}")))
(alias
 (name runtest)
 (action (diff union.svg union_actual.svg)))
