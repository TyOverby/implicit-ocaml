
; circle
(rule
  (deps circle.shape.sexp)
  (targets circle.linebuf.sexp)
  (action (bash "cat %{deps} | %{exe:../utilities/shape_to_linebuf/shape_to_linebuf.exe} > %{targets}")))
(rule
  (deps circle.linebuf.sexp)
  (targets circle_actual.parts.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/linebuf_to_svg/linebuf_to_svg.exe} > %{targets}")))
(rule
  (deps circle.connected.sexp)
  (targets circle_actual.connected.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/connected_to_svg/connected_to_svg.exe} > %{targets}")))
(rule
  (deps circle.linebuf.sexp)
  (targets circle_actual.connected.sexp)
  (action (bash "cat %{deps} | %{exe:../utilities/linebuf_to_connected/linebuf_to_connected.exe} > %{targets}")))
(alias
 (name runtest)
 (deps circle.linebuf.sexp)
 (action (bash "cat circle.linebuf.sexp | %{exe:../utilities/linebuf_validate/linebuf_validate.exe}")))
(alias
 (name runtest)
 (action (diff circle.connected.sexp circle_actual.connected.sexp)))
(alias
 (name runtest)
 (action (diff circle.parts.svg circle_actual.parts.svg)))
(alias
 (name runtest)
 (action (diff circle.connected.svg circle_actual.connected.svg)))

; intersection
(rule
  (deps intersection.shape.sexp)
  (targets intersection.linebuf.sexp)
  (action (bash "cat %{deps} | %{exe:../utilities/shape_to_linebuf/shape_to_linebuf.exe} > %{targets}")))
(rule
  (deps intersection.linebuf.sexp)
  (targets intersection_actual.parts.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/linebuf_to_svg/linebuf_to_svg.exe} > %{targets}")))
(rule
  (deps intersection.connected.sexp)
  (targets intersection_actual.connected.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/connected_to_svg/connected_to_svg.exe} > %{targets}")))
(rule
  (deps intersection.linebuf.sexp)
  (targets intersection_actual.connected.sexp)
  (action (bash "cat %{deps} | %{exe:../utilities/linebuf_to_connected/linebuf_to_connected.exe} > %{targets}")))
(alias
 (name runtest)
 (deps intersection.linebuf.sexp)
 (action (bash "cat intersection.linebuf.sexp | %{exe:../utilities/linebuf_validate/linebuf_validate.exe}")))
(alias
 (name runtest)
 (action (diff intersection.connected.sexp intersection_actual.connected.sexp)))
(alias
 (name runtest)
 (action (diff intersection.parts.svg intersection_actual.parts.svg)))
(alias
 (name runtest)
 (action (diff intersection.connected.svg intersection_actual.connected.svg)))

; union
(rule
  (deps union.shape.sexp)
  (targets union.linebuf.sexp)
  (action (bash "cat %{deps} | %{exe:../utilities/shape_to_linebuf/shape_to_linebuf.exe} > %{targets}")))
(rule
  (deps union.linebuf.sexp)
  (targets union_actual.parts.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/linebuf_to_svg/linebuf_to_svg.exe} > %{targets}")))
(rule
  (deps union.connected.sexp)
  (targets union_actual.connected.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/connected_to_svg/connected_to_svg.exe} > %{targets}")))
(rule
  (deps union.linebuf.sexp)
  (targets union_actual.connected.sexp)
  (action (bash "cat %{deps} | %{exe:../utilities/linebuf_to_connected/linebuf_to_connected.exe} > %{targets}")))
(alias
 (name runtest)
 (deps union.linebuf.sexp)
 (action (bash "cat union.linebuf.sexp | %{exe:../utilities/linebuf_validate/linebuf_validate.exe}")))
(alias
 (name runtest)
 (action (diff union.connected.sexp union_actual.connected.sexp)))
(alias
 (name runtest)
 (action (diff union.parts.svg union_actual.parts.svg)))
(alias
 (name runtest)
 (action (diff union.connected.svg union_actual.connected.svg)))
