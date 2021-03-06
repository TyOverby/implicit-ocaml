open! Core
open! Async
open Shared_types
open Svg

let main () =
  let profile = Profile.create () in
  Profile.start profile "all";
  let scene =
    In_channel.stdin
    |> In_channel.input_all
    |> Sexp.of_string
    |> Scene.t_of_sexp
  in
  let target_width = Scene.target_width scene in
  let target_height = Scene.target_height scene in
  let padding = Scene.padding scene in
  let bb_of_all_shapes =
    scene
    |> Scene.layers
    |> List.map ~f:Layer.shape
    |> Shape.union
    |> Bounding_box.compute_bounding_box
  in
  let layers =
    scene
    |> Scene.layers
    |> List.mapi ~f:(fun i layer ->
           let shape =
             layer
             |> Layer.shape
             |> Pipeline.reshape
                  (Profile.split profile (sprintf "layer-%d" i))
                  bb_of_all_shapes
                  ~target_width
                  ~target_height
                  ~padding
           in
           { layer with shape })
  in
  let viewbox =
    Viewbox.create
      ~min_x:0.0
      ~min_y:0.0
      ~width:(Float.of_int target_width)
      ~height:(Float.of_int target_height)
  in
  let%bind all_connected =
    layers
    |> List.mapi ~f:(fun i { shape; color } ->
           let%map connected =
             Pipeline.eval_connect
               (Profile.split profile (sprintf "layer-%d" i))
               (module Jitsy_native)
               shape
               ~width:target_width
               ~height:target_height
           in
           connected, color)
    |> Deferred.all
  in
  let elements =
    List.map all_connected ~f:(fun (connecteds, color) ->
        let joineds =
          List.map connecteds ~f:(function
              | Connected.Joined points -> points
              | Connected.Disjoint _ ->
                failwith "disjoint not implemented")
        in
        let style =
          Style.[ Fill (Some color); Stroke None; Stroke_width 0 ]
        in
        Element.path joineds ~style)
  in
  elements |> to_svg ~viewbox |> print_endline;
  Profile.stop profile "all";
  return ()
;;

let command =
  Command.async
    ~summary:"convert a scene file to an svg"
    (Command.Param.return main)
;;
