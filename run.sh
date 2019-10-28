#!/bin/bash
dune build \
 @@jitsy/runtest \
 @@march/default \
 @@shape_eval/runtest \
 @@pipeline/runtest \
 @@types/runtest \
 @@examples/default \
 @@examples/runtest \
 utilities/shape_to_linebuf/shape_to_linebuf.exe \
 utilities/linebuf_to_svg/linebuf_to_svg.exe \
 utilities/linebuf_validate/linebuf_validate.exe \
 -w
