open! Core_kernel
open! Shared_types
module Id = Unique_id.Int ()

module Bi_map : sig
  type t

  val parse : Line_buffer.t -> t
  val remove_id : t -> Id.t -> unit
  val lookup_line : t -> Id.t -> Line.t
  val first : t -> Id.t
  val find_and_remove_end : t -> Point.t -> acc:Point.t list -> Id.t
  val is_empty : t -> bool
end = struct
  module Dpoint = struct
    type t =
      { id : Id.t
      ; x : float
      ; y : float
      ; mutable picked : bool
      }

    let create ~id { Point.x; y } = { id; x; y; picked = false }

    let query { Point.x; y } =
      { id = Id.create (); x; y; picked = true }
    ;;

    let dist { x = x1; y = y1; _ } { x = x2; y = y2; _ } =
      let dx = x1 -. x2 in
      let dy = y1 -. y2 in
      Float.sqrt ((dx *. dx) +. (dy *. dy))
    ;;

    let is_picked { picked; _ } = picked
  end

  module Tree = Vpt.Vp_tree.Make (Dpoint)

  type t =
    { dict : Line.t Id.Table.t
    ; mutable ends : Tree.t
    }

  let parse (linebuf : Line_buffer.t) =
    let dict = Id.Table.create () in
    let ends = ref [] in
    Line_buffer.iter linebuf ~f:(fun ({ p1 = _; p2 } as line) ->
        let id = Id.create () in
        Hashtbl.add_exn dict ~key:id ~data:line;
        ends := Dpoint.create ~id p2 :: !ends);
    let ends = Tree.create (Tree.Good 25) !ends in
    { dict; ends }
  ;;

  let is_empty { dict; _ } = Hashtbl.is_empty dict
  let remove_id { dict; _ } id = Hashtbl.remove dict id
  let lookup_line { dict; _ } id = Hashtbl.find_exn dict id

  let first { dict; _ } =
    (* PERF: you could keep a set of keys next to the 
     * dict and remove them when necessary *)
    let least = ref None in
    Hashtbl.iter_keys dict ~f:(fun id ->
        match !least with
        | None -> least := Some id
        | Some a when Id.( < ) id a -> least := Some id
        | _ -> ());
    Option.value_exn !least
  ;;

  let rec find_and_remove_end bi_tree current ~acc =
    let _, dpoint =
      Tree.nearest_neighbor (Dpoint.query current) bi_tree.ends
    in
    if Dpoint.is_picked dpoint
    then (
      bi_tree.ends
        <- Tree.to_list bi_tree.ends
           |> List.filter ~f:(Fn.non Dpoint.is_picked)
           |> Tree.create (Tree.Good 25);
      find_and_remove_end bi_tree current ~acc)
    else (
      dpoint.picked <- true;
      dpoint.id)
  ;;
end

let process_single bi_map =
  let rec run_with ~end_pt ~current ~acc =
    if Point.equal end_pt current
    then Connected.Joined acc
    else (
      let next_id = Bi_map.find_and_remove_end bi_map current ~acc in
      let { Line.p1 = current; _ } =
        Bi_map.lookup_line bi_map next_id
      in
      Bi_map.remove_id bi_map next_id;
      let acc = current :: acc in
      run_with ~end_pt ~current ~acc)
  in
  let start_pt, end_pt =
    let first = Bi_map.first bi_map in
    let { Line.p1 = start_pt; p2 = end_pt } =
      Bi_map.lookup_line bi_map first
    in
    Bi_map.remove_id bi_map first;
    start_pt, end_pt
  in
  run_with ~end_pt ~current:start_pt ~acc:[]
;;

let f linebuf =
  let bi_map = Bi_map.parse linebuf in
  let rec parse_all acc =
    if Bi_map.is_empty bi_map
    then acc
    else parse_all (process_single bi_map :: acc)
  in
  parse_all []
;;
