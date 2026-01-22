open! Core

module type S = sig
  val start : string -> unit
  val stop : string -> unit
end

type t = (module S)

let start (module A : S) = A.start
let stop (module A : S) = A.stop

let split (module A : S) prefix : (module S) =
  (module struct
    let start s = A.start (prefix ^ ":" ^ s)
    let stop s = A.stop (prefix ^ ":" ^ s)
  end)
;;

module Noop : S = struct
  let start = ignore
  let stop = ignore
end

let create () : (module S) =
  let table = Hashtbl.create (module String) in
  let module A = struct
    let start s =
      if Hashtbl.mem table s
      then raise_s [%message "profile already has" (s : string)];
      let now = Time_ns.now () in
      Hashtbl.set table ~key:s ~data:now
    ;;

    let stop s =
      let past = Hashtbl.find_exn table s in
      Hashtbl.remove table s;
      let count = Hashtbl.length table in
      let now = Time_ns.now () in
      let diff = Time_ns.Span.to_string_hum (Time_ns.diff now past) in
      let spaces = String.make (count * 2) ' ' in
      Printf.eprintf "%s%s: %s\n" spaces s diff
    ;;
  end
  in
  (module A)
;;
