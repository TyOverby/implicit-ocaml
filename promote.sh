#!/bin/bash
dune build \
 @@jitsy/runtest \
 @@jitsy_native/runtest \
 @@bounding_box/runtest \
 @@line_join/runtest \
 @@tests/shape_native/runtest \
 @@shape/runtest \
 @@pipeline/runtest \
 @@types/runtest \
 @@examples/runtest \
 --auto-promote
