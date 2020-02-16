open! Core_kernel
open! Async

let command =
  Command.group
    ~summary:""
    [ "linebuf-to-connected", Linebuf_to_connected.command
    ; "linebuf-to-svg", Linebuf_to_svg.command
    ; "shape-to-linebuf", Shape_to_linebuf.command
    ; "connected-to-svg", Connected_to_svg.command
    ; "linebuf-validate", Linebuf_validate.command
    ]
;;

let () = Command.run command
