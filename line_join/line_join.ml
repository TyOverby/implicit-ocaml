open! Core_kernel
open! Shared_types
module Id = Unique_id.Int ()

module Bi_map : sig
  type t =
    { dict : Line.t Id.Table.t
    ; ends : Id.t list Point.Table.t
    }

  val parse : Line_buffer.t -> t
  val remove_id : t -> Id.t -> unit
  val lookup_line : t -> Id.t -> Line.t
  val first : t -> Id.t
end = struct
  type t =
    { dict : Line.t Id.Table.t
    ; ends : Id.t list Point.Table.t
    }
  [@@deriving sexp]

  let parse (linebuf : Line_buffer.t) =
    let dict = Id.Table.create () in
    let ends = Point.Table.create () in
    Line_buffer.iter linebuf ~f:(fun ({ p1 = _; p2 } as line) ->
        let i = Id.create () in
        Hashtbl.add_exn dict ~key:i ~data:line;
        Hashtbl.add_multi ends ~key:p2 ~data:i);
    { dict; ends }
  ;;

  let remove_id { dict; _ } id = Hashtbl.remove dict id
  let lookup_line { dict; _ } id = Hashtbl.find_exn dict id

  let first { dict; _ } =
    with_return (fun { return } ->
        Hashtbl.iter_keys dict ~f:return;
        raise_s [%message "empty map to iterate over?"])
  ;;
end

let process_single bi_map =
  let { Bi_map.ends; _ } = bi_map in
  let rec run_with ~end_pt ~current ~acc =
    if Point.equal end_pt current
    then Connected.Joined acc
    else (
      let next_id =
        match Hashtbl.find_multi ends current with
        | p :: _ -> p
        | [] ->
          raise_s
            [%message
              "couldn't find"
                (current : Point.t)
                "in"
                (ends : Id.t list Point.Table.t)
                "with"
                (acc : Point.t list)]
      in
      Hashtbl.remove_multi ends current;
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
    (*
    Hashtbl.remove starts start_pt;
    Hashtbl.remove ends end_pt;
    *)
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
