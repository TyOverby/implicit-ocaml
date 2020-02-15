
; circle
(executable
   (name circle)
   (modules circle)
   (preprocess (pps ppx_jane))
   (libraries core_kernel shape_eval example_runner))
(rule
     (with-stdout-to circle_actual.shape.sexp
      (run ./circle.exe)))
(rule
  (deps circle_actual.shape.sexp)
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
 (action (diff circle.shape.sexp circle_actual.shape.sexp)))
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
(executable
   (name intersection)
   (modules intersection)
   (preprocess (pps ppx_jane))
   (libraries core_kernel shape_eval example_runner))
(rule
     (with-stdout-to intersection_actual.shape.sexp
      (run ./intersection.exe)))
(rule
  (deps intersection_actual.shape.sexp)
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
 (action (diff intersection.shape.sexp intersection_actual.shape.sexp)))
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
(executable
   (name union)
   (modules union)
   (preprocess (pps ppx_jane))
   (libraries core_kernel shape_eval example_runner))
(rule
     (with-stdout-to union_actual.shape.sexp
      (run ./union.exe)))
(rule
  (deps union_actual.shape.sexp)
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
 (action (diff union.shape.sexp union_actual.shape.sexp)))
(alias
 (name runtest)
 (action (diff union.connected.sexp union_actual.connected.sexp)))
(alias
 (name runtest)
 (action (diff union.parts.svg union_actual.parts.svg)))
(alias
 (name runtest)
 (action (diff union.connected.svg union_actual.connected.svg)))

; kissing_circles
(executable
   (name kissing_circles)
   (modules kissing_circles)
   (preprocess (pps ppx_jane))
   (libraries core_kernel shape_eval example_runner))
(rule
     (with-stdout-to kissing_circles_actual.shape.sexp
      (run ./kissing_circles.exe)))
(rule
  (deps kissing_circles_actual.shape.sexp)
  (targets kissing_circles.linebuf.sexp)
  (action (bash "cat %{deps} | %{exe:../utilities/shape_to_linebuf/shape_to_linebuf.exe} > %{targets}")))
(rule
  (deps kissing_circles.linebuf.sexp)
  (targets kissing_circles_actual.parts.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/linebuf_to_svg/linebuf_to_svg.exe} > %{targets}")))
(rule
  (deps kissing_circles.connected.sexp)
  (targets kissing_circles_actual.connected.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/connected_to_svg/connected_to_svg.exe} > %{targets}")))
(rule
  (deps kissing_circles.linebuf.sexp)
  (targets kissing_circles_actual.connected.sexp)
  (action (bash "cat %{deps} | %{exe:../utilities/linebuf_to_connected/linebuf_to_connected.exe} > %{targets}")))
(alias
 (name runtest)
 (action (diff kissing_circles.shape.sexp kissing_circles_actual.shape.sexp)))
(alias
 (name runtest)
 (action (diff kissing_circles.connected.sexp kissing_circles_actual.connected.sexp)))
(alias
 (name runtest)
 (action (diff kissing_circles.parts.svg kissing_circles_actual.parts.svg)))
(alias
 (name runtest)
 (action (diff kissing_circles.connected.svg kissing_circles_actual.connected.svg)))

; scale
(executable
   (name scale)
   (modules scale)
   (preprocess (pps ppx_jane))
   (libraries core_kernel shape_eval example_runner))
(rule
     (with-stdout-to scale_actual.shape.sexp
      (run ./scale.exe)))
(rule
  (deps scale_actual.shape.sexp)
  (targets scale.linebuf.sexp)
  (action (bash "cat %{deps} | %{exe:../utilities/shape_to_linebuf/shape_to_linebuf.exe} > %{targets}")))
(rule
  (deps scale.linebuf.sexp)
  (targets scale_actual.parts.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/linebuf_to_svg/linebuf_to_svg.exe} > %{targets}")))
(rule
  (deps scale.connected.sexp)
  (targets scale_actual.connected.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/connected_to_svg/connected_to_svg.exe} > %{targets}")))
(rule
  (deps scale.linebuf.sexp)
  (targets scale_actual.connected.sexp)
  (action (bash "cat %{deps} | %{exe:../utilities/linebuf_to_connected/linebuf_to_connected.exe} > %{targets}")))
(alias
 (name runtest)
 (action (diff scale.shape.sexp scale_actual.shape.sexp)))
(alias
 (name runtest)
 (action (diff scale.connected.sexp scale_actual.connected.sexp)))
(alias
 (name runtest)
 (action (diff scale.parts.svg scale_actual.parts.svg)))
(alias
 (name runtest)
 (action (diff scale.connected.svg scale_actual.connected.svg)))
