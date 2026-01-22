(* Type definitions shared between bindings generator and implementation *)
open Ctypes

(* Window options struct layout *)
module WindowOptions = struct
  type t

  let t : t structure typ = structure "MiniFBWindowOptions"
  let borderless = field t "borderless" bool
  let title = field t "title" bool
  let resize = field t "resize" bool
  let topmost = field t "topmost" bool
  let transparency = field t "transparency" bool
  let () = seal t
end

(* Opaque window pointer *)
module Window = struct
  type t

  let t : t structure typ = structure "MiniFBWindow"
end

(* Keyboard key enum - represented as int in C FFI *)
module Key = struct
  type t =
    | Key0
    | Key1
    | Key2
    | Key3
    | Key4
    | Key5
    | Key6
    | Key7
    | Key8
    | Key9
    | A
    | B
    | C
    | D
    | E
    | F
    | G
    | H
    | I
    | J
    | K
    | L
    | M
    | N
    | O
    | P
    | Q
    | R
    | S
    | T
    | U
    | V
    | W
    | X
    | Y
    | Z
    | F1
    | F2
    | F3
    | F4
    | F5
    | F6
    | F7
    | F8
    | F9
    | F10
    | F11
    | F12
    | F13
    | F14
    | F15
    | Down
    | Left
    | Right
    | Up
    | Apostrophe
    | Backquote
    | Backslash
    | Comma
    | Equal
    | LeftBracket
    | Minus
    | Period
    | RightBracket
    | Semicolon
    | Slash
    | Backspace
    | Delete
    | End
    | Enter
    | Escape
    | Home
    | Insert
    | Menu
    | PageDown
    | PageUp
    | Pause
    | Space
    | Tab
    | NumLock
    | CapsLock
    | ScrollLock
    | LeftShift
    | RightShift
    | LeftCtrl
    | RightCtrl
    | NumPad0
    | NumPad1
    | NumPad2
    | NumPad3
    | NumPad4
    | NumPad5
    | NumPad6
    | NumPad7
    | NumPad8
    | NumPad9
    | NumPadDot
    | NumPadSlash
    | NumPadAsterisk
    | NumPadMinus
    | NumPadPlus
    | NumPadEnter
    | LeftAlt
    | RightAlt
    | LeftSuper
    | RightSuper
    | Unknown

  let to_int = function
    | Key0 -> 0
    | Key1 -> 1
    | Key2 -> 2
    | Key3 -> 3
    | Key4 -> 4
    | Key5 -> 5
    | Key6 -> 6
    | Key7 -> 7
    | Key8 -> 8
    | Key9 -> 9
    | A -> 10
    | B -> 11
    | C -> 12
    | D -> 13
    | E -> 14
    | F -> 15
    | G -> 16
    | H -> 17
    | I -> 18
    | J -> 19
    | K -> 20
    | L -> 21
    | M -> 22
    | N -> 23
    | O -> 24
    | P -> 25
    | Q -> 26
    | R -> 27
    | S -> 28
    | T -> 29
    | U -> 30
    | V -> 31
    | W -> 32
    | X -> 33
    | Y -> 34
    | Z -> 35
    | F1 -> 36
    | F2 -> 37
    | F3 -> 38
    | F4 -> 39
    | F5 -> 40
    | F6 -> 41
    | F7 -> 42
    | F8 -> 43
    | F9 -> 44
    | F10 -> 45
    | F11 -> 46
    | F12 -> 47
    | F13 -> 48
    | F14 -> 49
    | F15 -> 50
    | Down -> 51
    | Left -> 52
    | Right -> 53
    | Up -> 54
    | Apostrophe -> 55
    | Backquote -> 56
    | Backslash -> 57
    | Comma -> 58
    | Equal -> 59
    | LeftBracket -> 60
    | Minus -> 61
    | Period -> 62
    | RightBracket -> 63
    | Semicolon -> 64
    | Slash -> 65
    | Backspace -> 66
    | Delete -> 67
    | End -> 68
    | Enter -> 69
    | Escape -> 70
    | Home -> 71
    | Insert -> 72
    | Menu -> 73
    | PageDown -> 74
    | PageUp -> 75
    | Pause -> 76
    | Space -> 77
    | Tab -> 78
    | NumLock -> 79
    | CapsLock -> 80
    | ScrollLock -> 81
    | LeftShift -> 82
    | RightShift -> 83
    | LeftCtrl -> 84
    | RightCtrl -> 85
    | NumPad0 -> 86
    | NumPad1 -> 87
    | NumPad2 -> 88
    | NumPad3 -> 89
    | NumPad4 -> 90
    | NumPad5 -> 91
    | NumPad6 -> 92
    | NumPad7 -> 93
    | NumPad8 -> 94
    | NumPad9 -> 95
    | NumPadDot -> 96
    | NumPadSlash -> 97
    | NumPadAsterisk -> 98
    | NumPadMinus -> 99
    | NumPadPlus -> 100
    | NumPadEnter -> 101
    | LeftAlt -> 102
    | RightAlt -> 103
    | LeftSuper -> 104
    | RightSuper -> 105
    | Unknown -> 106
  ;;

  let of_int = function
    | 0 -> Key0
    | 1 -> Key1
    | 2 -> Key2
    | 3 -> Key3
    | 4 -> Key4
    | 5 -> Key5
    | 6 -> Key6
    | 7 -> Key7
    | 8 -> Key8
    | 9 -> Key9
    | 10 -> A
    | 11 -> B
    | 12 -> C
    | 13 -> D
    | 14 -> E
    | 15 -> F
    | 16 -> G
    | 17 -> H
    | 18 -> I
    | 19 -> J
    | 20 -> K
    | 21 -> L
    | 22 -> M
    | 23 -> N
    | 24 -> O
    | 25 -> P
    | 26 -> Q
    | 27 -> R
    | 28 -> S
    | 29 -> T
    | 30 -> U
    | 31 -> V
    | 32 -> W
    | 33 -> X
    | 34 -> Y
    | 35 -> Z
    | 36 -> F1
    | 37 -> F2
    | 38 -> F3
    | 39 -> F4
    | 40 -> F5
    | 41 -> F6
    | 42 -> F7
    | 43 -> F8
    | 44 -> F9
    | 45 -> F10
    | 46 -> F11
    | 47 -> F12
    | 48 -> F13
    | 49 -> F14
    | 50 -> F15
    | 51 -> Down
    | 52 -> Left
    | 53 -> Right
    | 54 -> Up
    | 55 -> Apostrophe
    | 56 -> Backquote
    | 57 -> Backslash
    | 58 -> Comma
    | 59 -> Equal
    | 60 -> LeftBracket
    | 61 -> Minus
    | 62 -> Period
    | 63 -> RightBracket
    | 64 -> Semicolon
    | 65 -> Slash
    | 66 -> Backspace
    | 67 -> Delete
    | 68 -> End
    | 69 -> Enter
    | 70 -> Escape
    | 71 -> Home
    | 72 -> Insert
    | 73 -> Menu
    | 74 -> PageDown
    | 75 -> PageUp
    | 76 -> Pause
    | 77 -> Space
    | 78 -> Tab
    | 79 -> NumLock
    | 80 -> CapsLock
    | 81 -> ScrollLock
    | 82 -> LeftShift
    | 83 -> RightShift
    | 84 -> LeftCtrl
    | 85 -> RightCtrl
    | 86 -> NumPad0
    | 87 -> NumPad1
    | 88 -> NumPad2
    | 89 -> NumPad3
    | 90 -> NumPad4
    | 91 -> NumPad5
    | 92 -> NumPad6
    | 93 -> NumPad7
    | 94 -> NumPad8
    | 95 -> NumPad9
    | 96 -> NumPadDot
    | 97 -> NumPadSlash
    | 98 -> NumPadAsterisk
    | 99 -> NumPadMinus
    | 100 -> NumPadPlus
    | 101 -> NumPadEnter
    | 102 -> LeftAlt
    | 103 -> RightAlt
    | 104 -> LeftSuper
    | 105 -> RightSuper
    | _ -> Unknown
  ;;

  (* Ctypes representation as int *)
  let t = int
end

(* Mouse button enum *)
module MouseButton = struct
  type t =
    | Left
    | Middle
    | Right

  let to_int = function
    | Left -> 0
    | Middle -> 1
    | Right -> 2
  ;;

  let of_int = function
    | 0 -> Left
    | 1 -> Middle
    | _ -> Right
  ;;

  let t = int
end

(* Mouse coordinate mode *)
module MouseMode = struct
  type t =
    | Pass
    | Clamp
    | Discard

  let to_int = function
    | Pass -> 0
    | Clamp -> 1
    | Discard -> 2
  ;;

  let of_int = function
    | 0 -> Pass
    | 1 -> Clamp
    | _ -> Discard
  ;;

  let t = int
end

(* Cursor style *)
module CursorStyle = struct
  type t =
    | Arrow
    | Ibeam
    | Crosshair
    | ClosedHand
    | OpenHand
    | ResizeLeftRight
    | ResizeUpDown
    | ResizeAll

  let to_int = function
    | Arrow -> 0
    | Ibeam -> 1
    | Crosshair -> 2
    | ClosedHand -> 3
    | OpenHand -> 4
    | ResizeLeftRight -> 5
    | ResizeUpDown -> 6
    | ResizeAll -> 7
  ;;

  let of_int = function
    | 0 -> Arrow
    | 1 -> Ibeam
    | 2 -> Crosshair
    | 3 -> ClosedHand
    | 4 -> OpenHand
    | 5 -> ResizeLeftRight
    | 6 -> ResizeUpDown
    | _ -> ResizeAll
  ;;

  let t = int
end
