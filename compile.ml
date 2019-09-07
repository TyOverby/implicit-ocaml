open Core_kernel
open Async

let rec compile_expression
    : type a. Buffer.t -> idgen:(Id.t -> string) -> a Expr.t -> string
  =
 fun buffer ~idgen expr ->
  let open Expr in
  let temp = idgen (Id.create ()) in
  let typ = Type.to_string (Expr.typeof expr) in
  let rprint s =
    bprintf buffer "%s %s = " typ temp;
    bprintf buffer (s ^^ ";\n")
  in
  (match expr with
  | Int_lit i -> rprint "%d" i
  | Bool_lit true -> rprint "1"
  | Bool_lit false -> rprint "0"
  | Float_lit f -> rprint "%f" f
  | Add_float (a, b) ->
    let temp_a = compile_expression buffer ~idgen a in
    let temp_b = compile_expression buffer ~idgen b in
    rprint "%s + %s" temp_a temp_b
  | Add_int (a, b) ->
    let temp_a = compile_expression buffer ~idgen a in
    let temp_b = compile_expression buffer ~idgen b in
    rprint "%s + %s" temp_a temp_b
  | Eq_int (a, b) ->
    let temp_a = compile_expression buffer ~idgen a in
    let temp_b = compile_expression buffer ~idgen b in
    rprint "%s == %s" temp_a temp_b
  | Cond (_, c, a, b) ->
    let temp_c = compile_expression buffer ~idgen c in
    let temp_a = compile_expression buffer ~idgen a in
    let temp_b = compile_expression buffer ~idgen b in
    rprint "%s ? %s : %s" temp_c temp_a temp_b
  | Var (_, id) -> rprint "%s" (idgen id));
  temp
;;

let compile ~name ~idgen { Function.expression; typ = _; param_map } =
  let buffer = Buffer.create 32 in
  bprintf buffer "extern %s %s(" (Type.to_string (Expr.typeof expression)) name;
  param_map
  |> List.map ~f:(fun (id, typ) -> sprintf "%s %s" typ (idgen id))
  |> List.intersperse ~sep:", "
  |> List.iter ~f:(Buffer.add_string buffer);
  bprintf buffer ") {\n";
  let return_temp = compile_expression buffer ~idgen expression in
  bprintf buffer "return %s;\n" return_temp;
  bprintf buffer "}";
  Buffer.contents buffer
;;

let compile f =
  let module Id_gen = Unique_id.Int () in
  let mapping = Id.Table.create () in
  let idgen id =
    let new_id = Hashtbl.find_or_add mapping id ~default:Id_gen.create in
    sprintf "var_%s" (Id_gen.to_string new_id)
  in
  let name = idgen (Id.create ()) in
  compile ~name ~idgen f, name
;;

let compile_c source =
  let open Async.Deferred.Or_error.Let_syntax in
  let name, writer = Core.Filename.open_temp_file "prefix" ".c" in
  Out_channel.output_string writer source;
  Out_channel.flush writer;
  Out_channel.close writer;
  let basepath, _ = Core.Filename.split_extension name in
  let out = basepath ^ ".so" in
  let log = basepath ^ ".sh" in
  let args = [ "-shared"; name; "-lm"; "-o"; out ] in
  Out_channel.write_all log ~data:(String.concat ("gcc" :: args) ~sep:" ");
  let%bind (_ : string) = Async.Process.run () ~prog:"gcc" ~args in
  return out
;;

let load source = Dl.dlopen ~filename:source ~flags:[ Dl.RTLD_NOW ]

let jit f =
  let open Async.Deferred.Let_syntax in
  let c_source, name = compile f in
  let%bind compiled_filename = compile_c c_source |> Deferred.Or_error.ok_exn in
  let library = load compiled_filename in
  return (Foreign.foreign ~from:library name f.typ)
;;
