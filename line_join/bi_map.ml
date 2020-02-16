open! Core_kernel
open! Shared_types
module Id = Unique_id.Int ()

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

  let _dist { x = x1; y = y1; _ } { x = x2; y = y2; _ } =
    let dx = x1 -. x2 in
    let dy = y1 -. y2 in
    Float.sqrt ((dx *. dx) +. (dy *. dy))
  ;;

  let dist { x = x1; y = y1; _ } { x = x2; y = y2; _ } =
    let dx = x1 -. x2 in
    let dy = y1 -. y2 in
    Float.(abs dx + abs dy)
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

let rec find_and_remove_end bi_tree current =
  let _, dpoint =
    Tree.nearest_neighbor (Dpoint.query current) bi_tree.ends
  in
  if Dpoint.is_picked dpoint
  then (
    bi_tree.ends
      <- Tree.to_list bi_tree.ends
         |> List.filter ~f:(Fn.non Dpoint.is_picked)
         |> Tree.create (Tree.Good 25);
    find_and_remove_end bi_tree current)
  else (
    dpoint.picked <- true;
    dpoint.id)
;;
