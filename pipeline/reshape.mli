open! Core_kernel
open Shared_types

val reshape
  :  Box.bounding
  -> Shape.t
  -> target_width:int
  -> target_height:int
  -> padding:int
  -> Shape.t
