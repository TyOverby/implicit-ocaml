#!/bin/bash

dune build \
 @@shape_eval/fmt \
 @@jitsy/fmt \
 @@march/fmt \
 @@types/fmt \
 @@pipeline/fmt \
 @@utilities/shape_to_linebuf/fmt \
 @@utilities/linebuf_to_svg/fmt \
 --auto-promote