open! Core_kernel
open! Shared_types

let process_single bi_map =
  let rec run_with ~end_id ~current ~acc =
    let next_id = Bi_map.find_and_remove_end bi_map current in
    if [%equal: Bi_map.Id.t] next_id end_id
    then Connected.Joined acc
    else (
      let { Line.p1 = current; _ } =
        Bi_map.lookup_line bi_map next_id
      in
      Bi_map.remove_id bi_map next_id;
      let acc = current :: acc in
      run_with ~end_id ~current ~acc)
  in
  let start_pt, end_id =
    let first = Bi_map.first bi_map in
    let { Line.p1 = start_pt; _ } = Bi_map.lookup_line bi_map first in
    Bi_map.remove_id bi_map first;
    start_pt, first
  in
  run_with ~end_id ~current:start_pt ~acc:[]
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
