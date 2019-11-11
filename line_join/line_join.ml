open! Core_kernel
open! Shared_types
module Id = Int

module Connected = struct
  type t =
    | Joined of Point.t list
    | Disjoint of Point.t list
  [@@deriving sexp]
end

module Bi_map = struct
  type t =
    { dict : Line.t Id.Table.t
    ; starts : Id.t Point.Table.t
    ; ends : Id.t Point.Table.t
    }
  [@@deriving sexp]

  let parse (linebuf : Line_buffer.t) =
    let dict = Id.Table.create () in
    let starts = Point.Table.create () in
    let ends = Point.Table.create () in
    Line_buffer.iteri linebuf ~f:(fun i ({ p1; p2 } as point) ->
        Hashtbl.add_exn dict ~key:i ~data:point;
        Hashtbl.add_exn starts ~key:p1 ~data:i;
        Hashtbl.add_exn ends ~key:p2 ~data:i);
    { dict; starts; ends }
  ;;
end

let process_single bi_map =
  let { Bi_map.dict; starts; ends } = bi_map in
  let rec run_with ~end_pt ~current ~acc =
    if Point.equal end_pt current
    then Connected.Joined acc
    else (
      let next_id =
        match Hashtbl.find ends current with
        | Some p -> p
        | None ->
          raise_s
            [%message
              "couldn't find"
                (current : Point.t)
                "in"
                (ends : int Point.Table.t)
                "with"
                (acc : Point.t list)]
      in
      Hashtbl.remove ends current;
      let { Line.p1 = current; _ } = Hashtbl.find_exn dict next_id in
      Hashtbl.remove dict next_id;
      let acc = current :: acc in
      run_with ~end_pt ~current ~acc)
  in
  let start_pt, end_pt =
    let first =
      Core_kernel.Hashtbl.keys dict
      |> List.sort ~compare:compare_int
      |> List.hd_exn
    in
    let { Line.p1 = start_pt; p2 = end_pt } =
      Hashtbl.find_exn dict first
    in
    Hashtbl.remove dict first;
    Hashtbl.remove starts start_pt;
    Hashtbl.remove ends end_pt;
    start_pt, end_pt
  in
  run_with ~end_pt ~current:start_pt ~acc:[]
;;

let f linebuf =
  let bi_map = Bi_map.parse linebuf in
  let rec parse_all acc =
    if Hashtbl.is_empty bi_map.Bi_map.dict
    then acc
    else parse_all (process_single bi_map :: acc)
  in
  parse_all []
;;
