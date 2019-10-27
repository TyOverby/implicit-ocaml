open! Core_kernel
open Shared_types

val marching_squares
  :  chunk:Chunk.t
  -> width:int
  -> height:int
  -> Line_buffer.t
