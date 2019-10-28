(rule
  (deps circle.shape.sexp)
  (targets circle.linebuf.sexp)
  (action (bash "cat %{deps} | %{exe:../utilities/shape_to_linebuf/shape_to_linebuf.exe} > %{targets}")))

(rule
  (deps circle.linebuf.sexp)
  (targets circle.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/linebuf_to_svg/linebuf_to_svg.exe} > %{targets}")))

(alias
 (name runtest)
 (action (run ../utilities/linebuf_validate/linebuf_validate.exe circle.linebuf.sexp)))
(alias
 (name runtest)
 (action (diff circle.svg actual_circle.svg)))(rule
  (deps intersection.shape.sexp)
  (targets intersection.linebuf.sexp)
  (action (bash "cat %{deps} | %{exe:../utilities/shape_to_linebuf/shape_to_linebuf.exe} > %{targets}")))

(rule
  (deps intersection.linebuf.sexp)
  (targets intersection.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/linebuf_to_svg/linebuf_to_svg.exe} > %{targets}")))

(alias
 (name runtest)
 (action (run ../utilities/linebuf_validate/linebuf_validate.exe intersection.linebuf.sexp)))
(alias
 (name runtest)
 (action (diff intersection.svg actual_intersection.svg)))(rule
  (deps union.shape.sexp)
  (targets union.linebuf.sexp)
  (action (bash "cat %{deps} | %{exe:../utilities/shape_to_linebuf/shape_to_linebuf.exe} > %{targets}")))

(rule
  (deps union.linebuf.sexp)
  (targets union.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/linebuf_to_svg/linebuf_to_svg.exe} > %{targets}")))

(alias
 (name runtest)
 (action (run ../utilities/linebuf_validate/linebuf_validate.exe union.linebuf.sexp)))
(alias
 (name runtest)
 (action (diff union.svg actual_union.svg)))
