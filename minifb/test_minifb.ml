(* Test executable for minifb OCaml bindings *)

let () =
  let width = 640 in
  let height = 480 in

  (* Create window *)
  print_endline "Creating window...";
  let window = Minifb.create ~name:"MiniFB Test" ~width ~height () in
  print_endline "Window created!";

  (* Create pixel buffer *)
  let buffer = Minifb.create_buffer ~width ~height in

  (* Fill with a red/green gradient *)
  for y = 0 to height - 1 do
    for x = 0 to width - 1 do
      let r = x * 255 / width in
      let g = y * 255 / height in
      let b = 128 in
      (* Format: 0xAARRGGBB - but minifb uses 0x00RRGGBB *)
      let color = Int32.of_int ((r lsl 16) lor (g lsl 8) lor b) in
      Bigarray.Array1.set buffer ((y * width) + x) color
    done
  done;

  (* Set target FPS *)
  Minifb.set_target_fps window 60;

  (* Main loop - run for 100 frames or until window is closed *)
  let frame = ref 0 in
  while Minifb.is_open window && !frame < 100 do
    Minifb.update_with_buffer window buffer ~width ~height;
    Minifb.update window;
    incr frame
  done;

  (* Clean up *)
  Minifb.close window;
  print_endline (Printf.sprintf "Test completed after %d frames" !frame)
;;
