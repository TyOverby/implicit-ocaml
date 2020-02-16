open! Core_kernel
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

type t = Element.t list

let to_svg t =
  [ [ {|<svg xmlns="http://www.w3.org/2000/svg" viewbox="0 0 88 88">|}
    ]
  ; List.map t ~f:Element.to_svg
  ; [ "</svg>" ]
  ]
  |> List.concat
  |> String.concat ~sep:"\n"
;;
