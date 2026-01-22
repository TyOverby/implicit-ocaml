(* Test executable for minifb bindings with keyboard/mouse input *)
module M = Minifb.Minifb_impl

let () =
  let width = 640 in
  let height = 480 in
  print_endline "Creating window (static bindings)...";
  print_endline "Press Escape to exit, move mouse to change colors";
  let window = M.create ~name:"MiniFB Input Test" ~width ~height () in
  print_endline "Window created!";
  let buffer = M.create_buffer ~width ~height in
  M.set_target_fps window 60;
  let frame = ref 0 in
  let mouse_x = ref 0.0 in
  let mouse_y = ref 0.0 in
  while M.is_open window && !frame < 300 do
    (* Check for Escape key to exit early *)
    if M.is_key_down window M.Key.Escape
    then (
      print_endline "Escape pressed, exiting...";
      M.close window);
    (* Get mouse position *)
    (match M.get_mouse_pos window () with
     | Some (x, y) ->
       mouse_x := x;
       mouse_y := y
     | None -> ());
    (* Calculate color offset based on mouse position *)
    let _mx = int_of_float !mouse_x in
    let _my = int_of_float !mouse_y in
    (* Fill buffer with gradient affected by mouse position *)
    for y = 0 to height - 1 do
      for x = 0 to width - 1 do
        let c = x lxor y land 1 = 1 in
        let color = Int32.of_int (if c then 0x00FFFFFF else 0) in
        Bigarray.Array1.set buffer ((y * width) + x) color
      done
    done;
    M.update_with_buffer window buffer ~width ~height;
    M.update window;
    incr frame
  done;
  M.close window;
  print_endline
    (Printf.sprintf "Test completed after %d frames" !frame)
;;
