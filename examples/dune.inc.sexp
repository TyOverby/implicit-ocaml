
; circle
(executable
   (name circle)
   (modules circle)
   (preprocess (pps ppx_jane))
   (libraries core_kernel eval example_runner))
(rule
     (with-stdout-to circle_actual.shape.sexp
      (run ./circle.exe)))
(rule
  (deps circle_actual.shape.sexp)
  (targets circle.linebuf.sexp)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} shape-to-linebuf > %{targets}")))
(rule
  (deps circle.linebuf.sexp)
  (targets circle_actual.parts.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} linebuf-to-svg > %{targets}")))
(rule
  (deps circle.connected.sexp)
  (targets circle_actual.connected.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} connected-to-svg > %{targets}")))
(rule
  (deps circle.linebuf.sexp)
  (targets circle_actual.connected.sexp)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} linebuf-to-connected > %{targets}")))
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

; circle_sub
(executable
   (name circle_sub)
   (modules circle_sub)
   (preprocess (pps ppx_jane))
   (libraries core_kernel eval example_runner))
(rule
     (with-stdout-to circle_sub_actual.shape.sexp
      (run ./circle_sub.exe)))
(rule
  (deps circle_sub_actual.shape.sexp)
  (targets circle_sub.linebuf.sexp)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} shape-to-linebuf > %{targets}")))
(rule
  (deps circle_sub.linebuf.sexp)
  (targets circle_sub_actual.parts.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} linebuf-to-svg > %{targets}")))
(rule
  (deps circle_sub.connected.sexp)
  (targets circle_sub_actual.connected.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} connected-to-svg > %{targets}")))
(rule
  (deps circle_sub.linebuf.sexp)
  (targets circle_sub_actual.connected.sexp)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} linebuf-to-connected > %{targets}")))
(alias
 (name runtest)
 (action (diff circle_sub.shape.sexp circle_sub_actual.shape.sexp)))
(alias
 (name runtest)
 (action (diff circle_sub.connected.sexp circle_sub_actual.connected.sexp)))
(alias
 (name runtest)
 (action (diff circle_sub.parts.svg circle_sub_actual.parts.svg)))
(alias
 (name runtest)
 (action (diff circle_sub.connected.svg circle_sub_actual.connected.svg)))

; circle_dup
(executable
   (name circle_dup)
   (modules circle_dup)
   (preprocess (pps ppx_jane))
   (libraries core_kernel eval example_runner))
(rule
     (with-stdout-to circle_dup_actual.shape.sexp
      (run ./circle_dup.exe)))
(rule
  (deps circle_dup_actual.shape.sexp)
  (targets circle_dup.linebuf.sexp)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} shape-to-linebuf > %{targets}")))
(rule
  (deps circle_dup.linebuf.sexp)
  (targets circle_dup_actual.parts.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} linebuf-to-svg > %{targets}")))
(rule
  (deps circle_dup.connected.sexp)
  (targets circle_dup_actual.connected.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} connected-to-svg > %{targets}")))
(rule
  (deps circle_dup.linebuf.sexp)
  (targets circle_dup_actual.connected.sexp)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} linebuf-to-connected > %{targets}")))
(alias
 (name runtest)
 (action (diff circle_dup.shape.sexp circle_dup_actual.shape.sexp)))
(alias
 (name runtest)
 (action (diff circle_dup.connected.sexp circle_dup_actual.connected.sexp)))
(alias
 (name runtest)
 (action (diff circle_dup.parts.svg circle_dup_actual.parts.svg)))
(alias
 (name runtest)
 (action (diff circle_dup.connected.svg circle_dup_actual.connected.svg)))

; intersection
(executable
   (name intersection)
   (modules intersection)
   (preprocess (pps ppx_jane))
   (libraries core_kernel eval example_runner))
(rule
     (with-stdout-to intersection_actual.shape.sexp
      (run ./intersection.exe)))
(rule
  (deps intersection_actual.shape.sexp)
  (targets intersection.linebuf.sexp)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} shape-to-linebuf > %{targets}")))
(rule
  (deps intersection.linebuf.sexp)
  (targets intersection_actual.parts.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} linebuf-to-svg > %{targets}")))
(rule
  (deps intersection.connected.sexp)
  (targets intersection_actual.connected.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} connected-to-svg > %{targets}")))
(rule
  (deps intersection.linebuf.sexp)
  (targets intersection_actual.connected.sexp)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} linebuf-to-connected > %{targets}")))
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
   (libraries core_kernel eval example_runner))
(rule
     (with-stdout-to union_actual.shape.sexp
      (run ./union.exe)))
(rule
  (deps union_actual.shape.sexp)
  (targets union.linebuf.sexp)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} shape-to-linebuf > %{targets}")))
(rule
  (deps union.linebuf.sexp)
  (targets union_actual.parts.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} linebuf-to-svg > %{targets}")))
(rule
  (deps union.connected.sexp)
  (targets union_actual.connected.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} connected-to-svg > %{targets}")))
(rule
  (deps union.linebuf.sexp)
  (targets union_actual.connected.sexp)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} linebuf-to-connected > %{targets}")))
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
   (libraries core_kernel eval example_runner))
(rule
     (with-stdout-to kissing_circles_actual.shape.sexp
      (run ./kissing_circles.exe)))
(rule
  (deps kissing_circles_actual.shape.sexp)
  (targets kissing_circles.linebuf.sexp)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} shape-to-linebuf > %{targets}")))
(rule
  (deps kissing_circles.linebuf.sexp)
  (targets kissing_circles_actual.parts.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} linebuf-to-svg > %{targets}")))
(rule
  (deps kissing_circles.connected.sexp)
  (targets kissing_circles_actual.connected.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} connected-to-svg > %{targets}")))
(rule
  (deps kissing_circles.linebuf.sexp)
  (targets kissing_circles_actual.connected.sexp)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} linebuf-to-connected > %{targets}")))
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
   (libraries core_kernel eval example_runner))
(rule
     (with-stdout-to scale_actual.shape.sexp
      (run ./scale.exe)))
(rule
  (deps scale_actual.shape.sexp)
  (targets scale.linebuf.sexp)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} shape-to-linebuf > %{targets}")))
(rule
  (deps scale.linebuf.sexp)
  (targets scale_actual.parts.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} linebuf-to-svg > %{targets}")))
(rule
  (deps scale.connected.sexp)
  (targets scale_actual.connected.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} connected-to-svg > %{targets}")))
(rule
  (deps scale.linebuf.sexp)
  (targets scale_actual.connected.sexp)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} linebuf-to-connected > %{targets}")))
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

; mix
(executable
   (name mix)
   (modules mix)
   (preprocess (pps ppx_jane))
   (libraries core_kernel eval example_runner))
(rule
     (with-stdout-to mix_actual.shape.sexp
      (run ./mix.exe)))
(rule
  (deps mix_actual.shape.sexp)
  (targets mix.linebuf.sexp)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} shape-to-linebuf > %{targets}")))
(rule
  (deps mix.linebuf.sexp)
  (targets mix_actual.parts.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} linebuf-to-svg > %{targets}")))
(rule
  (deps mix.connected.sexp)
  (targets mix_actual.connected.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} connected-to-svg > %{targets}")))
(rule
  (deps mix.linebuf.sexp)
  (targets mix_actual.connected.sexp)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} linebuf-to-connected > %{targets}")))
(alias
 (name runtest)
 (action (diff mix.shape.sexp mix_actual.shape.sexp)))
(alias
 (name runtest)
 (action (diff mix.connected.sexp mix_actual.connected.sexp)))
(alias
 (name runtest)
 (action (diff mix.parts.svg mix_actual.parts.svg)))
(alias
 (name runtest)
 (action (diff mix.connected.svg mix_actual.connected.svg)))

; motion_blur_test
(executable
   (name motion_blur_test)
   (modules motion_blur_test)
   (preprocess (pps ppx_jane))
   (libraries core_kernel eval example_runner))
(rule
     (with-stdout-to motion_blur_test_actual.shape.sexp
      (run ./motion_blur_test.exe)))
(rule
  (deps motion_blur_test_actual.shape.sexp)
  (targets motion_blur_test.linebuf.sexp)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} shape-to-linebuf > %{targets}")))
(rule
  (deps motion_blur_test.linebuf.sexp)
  (targets motion_blur_test_actual.parts.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} linebuf-to-svg > %{targets}")))
(rule
  (deps motion_blur_test.connected.sexp)
  (targets motion_blur_test_actual.connected.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} connected-to-svg > %{targets}")))
(rule
  (deps motion_blur_test.linebuf.sexp)
  (targets motion_blur_test_actual.connected.sexp)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} linebuf-to-connected > %{targets}")))
(alias
 (name runtest)
 (action (diff motion_blur_test.shape.sexp motion_blur_test_actual.shape.sexp)))
(alias
 (name runtest)
 (action (diff motion_blur_test.connected.sexp motion_blur_test_actual.connected.sexp)))
(alias
 (name runtest)
 (action (diff motion_blur_test.parts.svg motion_blur_test_actual.parts.svg)))
(alias
 (name runtest)
 (action (diff motion_blur_test.connected.svg motion_blur_test_actual.connected.svg)))

; bulls_eye name
(executable
   (name bulls_eye)
   (modules bulls_eye)
   (preprocess (pps ppx_jane))
   (libraries core_kernel eval example_runner))
(rule
     (with-stdout-to bulls_eye_actual.scene.sexp
      (run ./bulls_eye.exe)))
(rule
  (deps bulls_eye_actual.scene.sexp)
  (targets bulls_eye_actual.scene.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} scene-to-svg > %{targets}")))
(alias
 (name runtest)
 (action (diff bulls_eye.svg bulls_eye_actual.scene.svg)))

; motion_blur name
(executable
   (name motion_blur)
   (modules motion_blur)
   (preprocess (pps ppx_jane))
   (libraries core_kernel eval example_runner))
(rule
     (with-stdout-to motion_blur_actual.scene.sexp
      (run ./motion_blur.exe)))
(rule
  (deps motion_blur_actual.scene.sexp)
  (targets motion_blur_actual.scene.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} scene-to-svg > %{targets}")))
(alias
 (name runtest)
 (action (diff motion_blur.svg motion_blur_actual.scene.svg)))

; nested_circles name
(executable
   (name nested_circles)
   (modules nested_circles)
   (preprocess (pps ppx_jane))
   (libraries core_kernel eval example_runner))
(rule
     (with-stdout-to nested_circles_actual.scene.sexp
      (run ./nested_circles.exe)))
(rule
  (deps nested_circles_actual.scene.sexp)
  (targets nested_circles_actual.scene.svg)
  (action (bash "cat %{deps} | %{exe:../utilities/utilities.exe} scene-to-svg > %{targets}")))
(alias
 (name runtest)
 (action (diff nested_circles.svg nested_circles_actual.scene.svg)))
(rule
  (targets display.html)
  (action (bash "echo \"\n<html>\n<head>\n</head>\n<body>\n<h1> Scenes </h1> \n\n    <h2>bulls_eye</h2>\n    <img src=\"./bulls_eye.svg\"></img>\n\n    <h2>motion_blur</h2>\n    <img src=\"./motion_blur.svg\"></img>\n\n    <h2>nested_circles</h2>\n    <img src=\"./nested_circles.svg\"></img>\n<h1> Tests </h1> \n\n    <h2>circle</h2>\n    <img src=\"./circle.connected.svg\"></img>\n\n    <h2>circle_sub</h2>\n    <img src=\"./circle_sub.connected.svg\"></img>\n\n    <h2>circle_dup</h2>\n    <img src=\"./circle_dup.connected.svg\"></img>\n\n    <h2>intersection</h2>\n    <img src=\"./intersection.connected.svg\"></img>\n\n    <h2>union</h2>\n    <img src=\"./union.connected.svg\"></img>\n\n    <h2>kissing_circles</h2>\n    <img src=\"./kissing_circles.connected.svg\"></img>\n\n    <h2>scale</h2>\n    <img src=\"./scale.connected.svg\"></img>\n\n    <h2>mix</h2>\n    <img src=\"./mix.connected.svg\"></img>\n\n    <h2>motion_blur_test</h2>\n    <img src=\"./motion_blur_test.connected.svg\"></img>\n</body>\n</html>\n\" > display.html")))
(alias
 (name runtest) (deps display.html))
 