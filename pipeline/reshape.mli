open! Core_kernel
open Shared_types

val reshape
  :  Shape.t
  -> target_width:int
  -> target_height:int
  -> padding:int
  -> Shape.t
