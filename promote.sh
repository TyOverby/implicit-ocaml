#!/bin/bash
dune build \
 @@jitsy/runtest \
 @@bounding_box/runtest \
 @@line_join/runtest \
 @@shape_eval/runtest \
 @@pipeline/runtest \
 @@types/runtest \
 @@examples/runtest \
 --auto-promote
