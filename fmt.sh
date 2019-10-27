#!/bin/bash

dune build \
 @@shape_eval/fmt \
 @@jitsy/fmt \
 @@march/fmt \
 @@types/fmt \
 @@pipeline/fmt \
 --auto-promote
