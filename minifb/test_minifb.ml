(* Comprehensive demo of all minifb bindings features *)
module M = Minifb.Minifb_impl

let () =
  let initial_width = 640 in
  let initial_height = 480 in
  print_endline "=== MiniFB OCaml Bindings Demo ===";
  print_endline "";
  print_endline "Controls:";
  print_endline "  Escape     - Exit";
  print_endline "  Arrow keys - Move window";
  print_endline "  Space      - Toggle cursor visibility";
  print_endline "  1-8        - Change cursor style";
  print_endline "  T          - Toggle topmost";
  print_endline "  R/G/B      - Tint red/green/blue";
  print_endline "  C          - Clear canvas";
  print_endline "  Mouse      - Draw on canvas";
  print_endline "  Scroll     - Change brush size";
  print_endline "";
  (* Create window with resizable option (works with i3 tiling) *)
  let options = { M.default_options with resize = true } in
  let window =
    M.create
      ~name:"MiniFB Demo"
      ~width:initial_width
      ~height:initial_height
      ~options
      ()
  in
  (* Set initial window position *)
  M.set_position window ~x:100 ~y:100;
  M.set_target_fps window 60;
  (* Mutable buffer that tracks window size *)
  let buf_width = ref initial_width in
  let buf_height = ref initial_height in
  let buffer =
    ref (M.create_buffer ~width:initial_width ~height:initial_height)
  in
  (* State variables *)
  let frame = ref 0 in
  let cursor_visible = ref true in
  let topmost = ref false in
  let brush_size = ref 10.0 in
  let red_tint = ref 0 in
  let green_tint = ref 0 in
  let blue_tint = ref 0 in
  let last_mouse = ref None in
  (* Helper to draw a filled circle *)
  let draw_circle ~cx ~cy ~radius ~color =
    let r = int_of_float radius in
    let w = !buf_width in
    let h = !buf_height in
    let buf = !buffer in
    for dy = -r to r do
      for dx = -r to r do
        if (dx * dx) + (dy * dy) <= r * r
        then (
          let px = cx + dx in
          let py = cy + dy in
          if px >= 0 && px < w && py >= 0 && py < h
          then Bigarray.Array1.set buf ((py * w) + px) color)
      done
    done
  in
  (* Helper to draw a line between two points *)
  let draw_line ~x0 ~y0 ~x1 ~y1 ~radius ~color =
    let dx = abs (x1 - x0) in
    let dy = abs (y1 - y0) in
    let steps = max dx dy in
    if steps > 0
    then
      for i = 0 to steps do
        let t = float_of_int i /. float_of_int steps in
        let cx = x0 + int_of_float (t *. float_of_int (x1 - x0)) in
        let cy = y0 + int_of_float (t *. float_of_int (y1 - y0)) in
        draw_circle ~cx ~cy ~radius ~color
      done
  in
  (* Main loop *)
  while M.is_open window do
    incr frame;
    (* Check if window was resized - if so, recreate buffer *)
    let win_w, win_h = M.get_size window in
    if win_w <> !buf_width || win_h <> !buf_height
    then (
      Printf.printf
        "Window resized: %dx%d -> %dx%d\n%!"
        !buf_width
        !buf_height
        win_w
        win_h;
      buf_width := win_w;
      buf_height := win_h;
      buffer := M.create_buffer ~width:win_w ~height:win_h;
      last_mouse := None (* Reset to avoid drawing across resize *));
    (* === Keyboard Input === *)

    (* Escape to exit *)
    if M.is_key_down window M.Key.Escape
    then (
      print_endline "Escape pressed, exiting...";
      M.close window);
    (* Arrow keys to move window *)
    let wx, wy = M.get_position window in
    if M.is_key_down window M.Key.Left
    then M.set_position window ~x:(wx - 5) ~y:wy;
    if M.is_key_down window M.Key.Right
    then M.set_position window ~x:(wx + 5) ~y:wy;
    if M.is_key_down window M.Key.Up
    then M.set_position window ~x:wx ~y:(wy - 5);
    if M.is_key_down window M.Key.Down
    then M.set_position window ~x:wx ~y:(wy + 5);
    (* Space to toggle cursor visibility *)
    if M.is_key_pressed window M.Key.Space ~repeat:false
    then (
      cursor_visible := not !cursor_visible;
      M.set_cursor_visibility window !cursor_visible;
      Printf.printf "Cursor visibility: %b\n%!" !cursor_visible);
    (* T to toggle topmost *)
    if M.is_key_pressed window M.Key.T ~repeat:false
    then (
      topmost := not !topmost;
      M.set_topmost window !topmost;
      Printf.printf "Topmost: %b\n%!" !topmost);
    (* Number keys 1-8 to change cursor style *)
    let cursor_styles =
      [| M.Key.Key1, M.CursorStyle.Arrow, "Arrow"
       ; M.Key.Key2, M.CursorStyle.Ibeam, "Ibeam"
       ; M.Key.Key3, M.CursorStyle.Crosshair, "Crosshair"
       ; M.Key.Key4, M.CursorStyle.ClosedHand, "ClosedHand"
       ; M.Key.Key5, M.CursorStyle.OpenHand, "OpenHand"
       ; M.Key.Key6, M.CursorStyle.ResizeLeftRight, "ResizeLeftRight"
       ; M.Key.Key7, M.CursorStyle.ResizeUpDown, "ResizeUpDown"
       ; M.Key.Key8, M.CursorStyle.ResizeAll, "ResizeAll"
      |]
    in
    Array.iter
      (fun (key, style, name) ->
        if M.is_key_pressed window key ~repeat:false
        then (
          M.set_cursor_style window style;
          Printf.printf "Cursor style: %s\n%!" name))
      cursor_styles;
    (* R/G/B keys to toggle color tints *)
    if M.is_key_pressed window M.Key.R ~repeat:false
    then red_tint := if !red_tint > 0 then 0 else 100;
    if M.is_key_pressed window M.Key.G ~repeat:false
    then green_tint := if !green_tint > 0 then 0 else 100;
    if M.is_key_pressed window M.Key.B ~repeat:false
    then blue_tint := if !blue_tint > 0 then 0 else 100;
    (* C to clear canvas *)
    if M.is_key_pressed window M.Key.C ~repeat:false
    then (
      for i = 0 to (!buf_width * !buf_height) - 1 do
        Bigarray.Array1.set !buffer i 0x00000000l
      done;
      print_endline "Canvas cleared");
    (* === Mouse Input === *)

    (* Get mouse position *)
    let mouse_pos = M.get_mouse_pos window () in
    (* Scroll wheel to change brush size *)
    (match M.get_scroll_wheel window with
     | Some (_, dy) ->
       brush_size := max 1.0 (min 50.0 (!brush_size +. dy));
       Printf.printf "Brush size: %.0f\n%!" !brush_size
     | None -> ());
    (* Draw with mouse buttons *)
    (match mouse_pos with
     | Some (mx, my) ->
       let ix = int_of_float mx in
       let iy = int_of_float my in
       (* Left mouse = white, Right mouse = black, Middle = color *)
       let drawing_color =
         if M.is_mouse_down window M.MouseButton.Left
         then Some 0x00FFFFFFl
         else if M.is_mouse_down window M.MouseButton.Right
         then Some 0x00000000l
         else if M.is_mouse_down window M.MouseButton.Middle
         then (
           let r = (!red_tint + 155) land 0xFF in
           let g = (!green_tint + 155) land 0xFF in
           let b = (!blue_tint + 155) land 0xFF in
           Some (Int32.of_int ((r lsl 16) lor (g lsl 8) lor b)))
         else None
       in
       (match drawing_color with
        | Some color ->
          (* Draw line from last position for smooth strokes *)
          (match !last_mouse with
           | Some (lx, ly) ->
             draw_line
               ~x0:lx
               ~y0:ly
               ~x1:ix
               ~y1:iy
               ~radius:!brush_size
               ~color
           | None ->
             draw_circle ~cx:ix ~cy:iy ~radius:!brush_size ~color);
          last_mouse := Some (ix, iy)
        | None -> last_mouse := None)
     | None -> last_mouse := None);
    (* Apply color tint to the whole buffer *)
    if !red_tint > 0 || !green_tint > 0 || !blue_tint > 0
    then (
      let size = !buf_width * !buf_height in
      for i = 0 to size - 1 do
        let pixel = Int32.to_int (Bigarray.Array1.get !buffer i) in
        let r = min 255 (((pixel lsr 16) land 0xFF) + !red_tint) in
        let g = min 255 (((pixel lsr 8) land 0xFF) + !green_tint) in
        let b = min 255 ((pixel land 0xFF) + !blue_tint) in
        Bigarray.Array1.set
          !buffer
          i
          (Int32.of_int ((r lsl 16) lor (g lsl 8) lor b))
      done);
    (* Update window title with stats every 60 frames *)
    if !frame mod 60 = 0
    then (
      let title =
        Printf.sprintf
          "MiniFB Demo | %dx%d | Frame %d | Brush: %.0f"
          !buf_width
          !buf_height
          !frame
          !brush_size
      in
      M.set_title window title);
    (* Render *)
    M.update_with_buffer
      window
      !buffer
      ~width:!buf_width
      ~height:!buf_height;
    M.update window
  done;
  M.close window;
  Printf.printf "Demo completed after %d frames\n" !frame
;;
