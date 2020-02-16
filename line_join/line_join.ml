open! Core_kernel
open! Shared_types

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
