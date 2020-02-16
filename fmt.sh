#!/bin/bash

dune build \
 @@eval/fmt \
 @@jitsy/fmt \
 @@jitsy_native/fmt \
 @@bounding_box/fmt \
 @@march/fmt \
 @@line_join/fmt \
 @@types/fmt \
 @@tests/shape_native/fmt \
 @@pipeline/fmt \
 @@examples/fmt \
 @@utilities/fmt \
 --auto-promote
