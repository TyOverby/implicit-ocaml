#!/bin/bash
dune build \
 @@jitsy/runtest \
 @@jitsy_native/runtest \
 @@line_join/runtest \
 @@bounding_box/runtest \
 @@march/default \
 @@line_join/default \
 @@eval/runtest \
 @@pipeline/runtest \
 @@tests/shape_native/runtest \
 @@types/runtest \
 @@examples/default \
 @@examples/runtest \
 utilities/utilities.exe
