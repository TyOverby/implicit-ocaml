#!/bin/bash
dune build \
 @@jitsy/runtest \
 @@shape_eval/runtest \
 @@pipeline/runtest \
 @@types/runtest \
 @@examples/runtest \
 --auto-promote
