open! Core
open Shared_types

module Style = struct
  type t =
    | Fill of string option
    | Stroke of string option
    | Stroke_width of int

  let to_attribute = function
    | Fill None -> "fill:none"
    | Fill (Some s) -> sprintf "fill:%s" s
    | Stroke None -> "stroke:none"
    | Stroke (Some s) -> sprintf "stroke:%s" s
    | Stroke_width i -> sprintf "stroke-width:%d" i
  ;;

  let to_attributes ts =
    ts |> List.map ~f:to_attribute |> String.concat ~sep:"; "
  ;;
end

module Element = struct
  type t =
    | Line of
        { line : Line.t
        ; style : Style.t list
        }
    | Path of
        { points : Point.t list list
        ; style : Style.t list
        }

  let line ~style line = Line { line; style }
  let path ~style points = Path { points; style }

  let to_svg = function
    | Line
        { line = { p1 = { x = x1; y = y1 }; p2 = { x = x2; y = y2 } }
        ; style
        } ->
      sprintf
        {|<line x1="%f" y1="%f" x2="%f" y2="%f" style="%s" />|}
        x1
        y1
        x2
        y2
        (Style.to_attributes style)
    | Path { points; style } ->
      let buffer = Buffer.create 10 in
      bprintf buffer {|<path fill-rule="evenodd" d="|};
      bprintf buffer "\n ";
      points
      |> List.iter ~f:(fun points ->
        points
        |> List.hd_exn
        |> fun { Point.x; y } ->
        bprintf buffer "M%f %f\n " x y;
        List.iter points ~f:(fun { Point.x; y } ->
          bprintf buffer "L%f %f\n " x y);
        bprintf buffer "Z\n ");
      bprintf
        buffer
        {|" style="%s"></path>|}
        (Style.to_attributes style);
      Buffer.contents buffer
  ;;
end

module Viewbox = struct
  type t =
    { min_x : float
    ; min_y : float
    ; width : float
    ; height : float
    }
  [@@deriving fields] [@@fields.no_zero_alloc]

  let create = Fields.create

  let default =
    { min_x = 0.0; min_y = 0.0; width = 88.0; height = 88.0 }
  ;;

  let to_string { min_x; min_y; width; height } =
    sprintf "%f %f %f %f" min_x min_y width height
  ;;
end

type t = Element.t list

let to_svg ?(viewbox = Viewbox.default) t =
  [ [ sprintf
        {|<svg xmlns="http://www.w3.org/2000/svg" viewBox="%s">|}
        (Viewbox.to_string viewbox)
    ]
  ; List.map t ~f:Element.to_svg
  ; [ "</svg>" ]
  ]
  |> List.concat
  |> String.concat ~sep:"\n"
;;
