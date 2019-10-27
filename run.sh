#!/bin/bash
dune build \
 @@jitsy/runtest \
 @@march/default \
 @@shape_eval/runtest \
 @@pipeline/runtest \
 @@types/runtest \
 -w
