open Core_kernel
open Async
open Jitsy

module Debug = struct
  type t =
    { c_source : string
    ; asm_source : unit -> string Deferred.t
    }
end

let rec compile_expression
    : type a. Buffer.t -> idgen:(Id.t -> string) -> a Expr.t -> string
  =
 fun buffer ~idgen expr ->
  let open Expr_type in
  match expr with
  | Var (_, id) -> idgen id
  | Array_set (a, b, c) ->
    let temp_a = compile_expression buffer ~idgen a in
    let temp_b = compile_expression buffer ~idgen b in
    let temp_c = compile_expression buffer ~idgen c in
    bprintf buffer "%s[%s] = %s;\n" temp_a temp_b temp_c;
    ""
  | Range2 { width; height; f } ->
    let x, y = Id.create (), Id.create () in
    let xs, ys = idgen x, idgen y in
    let pos = Id.create () in
    let pos_s = idgen pos in
    let width = compile_expression buffer ~idgen width in
    let height = compile_expression buffer ~idgen height in
    bprintf
      buffer
      {|
      int %s = 0;
      for (int %s = 0; %s < %s; %s++) {
          for (int %s = 0; %s < %s; %s++) {
    |}
      pos_s
      ys
      ys
      height
      ys
      xs
      xs
      width
      xs;
    let x, y, pos =
      Var (Type.int, x), Var (Type.int, y), Var (Type.int, pos)
    in
    let (_ : string) =
      compile_expression buffer ~idgen (f ~x ~y ~pos)
    in
    bprintf
      buffer
      {|
              %s++;
          }
      }
    |}
      pos_s;
    ""
  | Progn (_t, l, a) ->
    List.iter l ~f:(fun expr ->
        let (_ : string) = compile_expression buffer ~idgen expr in
        ());
    compile_expression buffer ~idgen a
  | _other ->
    let temp = idgen (Id.create ()) in
    let typ = Type.to_string (Expr.typeof expr) in
    let rprint s =
      bprintf buffer "%s %s = " typ temp;
      bprintf buffer (s ^^ ";\n")
    in
    (match expr with
    | Int_lit i -> rprint "%d" i
    | Int32_lit i -> rprint "%s" (Int32.to_string i)
    | Float_lit f -> rprint "%f" f
    | Bool_lit true -> rprint "1"
    | Bool_lit false -> rprint "0"
    | Sqrt_float a ->
      let temp_a = compile_expression buffer ~idgen a in
      rprint "sqrt(%s)" temp_a
    | Square_int32 a ->
      let temp_a = compile_expression buffer ~idgen a in
      rprint "%s * %s" temp_a temp_a
    | Square_float a ->
      let temp_a = compile_expression buffer ~idgen a in
      rprint "%s * %s" temp_a temp_a
    | Sqrt_int32 a ->
      let temp_a = compile_expression buffer ~idgen a in
      let temp_b = idgen (Id.create ()) in
      bprintf
        buffer
        {|
        int32_t %s = 0;
        {
            int32_t v = %s;
            if (v > 0) {
               uint32_t t, q, b, r;
               r = v;
               b = 0x40000000;
               q = 0;
               while (b > 0) {
                   t = q + b;
                   q >>= 1;
                   if (r >= t) {
                       r -= t;
                       q += b;
                   }
                   b >>= 2;
               }
               %s = q;
            }
        }
      |}
        temp_b
        temp_a
        temp_b;
      rprint "%s" temp_b
    | Add_float (a, b) ->
      let temp_a = compile_expression buffer ~idgen a in
      let temp_b = compile_expression buffer ~idgen b in
      rprint "%s + %s" temp_a temp_b
    | Sub_float (a, b) ->
      let temp_a = compile_expression buffer ~idgen a in
      let temp_b = compile_expression buffer ~idgen b in
      rprint "%s - %s" temp_a temp_b
    | Mul_float (a, b) ->
      let temp_a = compile_expression buffer ~idgen a in
      let temp_b = compile_expression buffer ~idgen b in
      rprint "%s * %s" temp_a temp_b
    | Div_float (a, b) ->
      let temp_a = compile_expression buffer ~idgen a in
      let temp_b = compile_expression buffer ~idgen b in
      rprint "%s / %s" temp_a temp_b
    | Neg_float a ->
      let temp_a = compile_expression buffer ~idgen a in
      rprint "-%s " temp_a
    | Neg_int32 a ->
      let temp_a = compile_expression buffer ~idgen a in
      rprint "-%s " temp_a
    | Add_int32 (a, b) ->
      let temp_a = compile_expression buffer ~idgen a in
      let temp_b = compile_expression buffer ~idgen b in
      rprint "%s + %s" temp_a temp_b
    | Sub_int32 (a, b) ->
      let temp_a = compile_expression buffer ~idgen a in
      let temp_b = compile_expression buffer ~idgen b in
      rprint "%s - %s" temp_a temp_b
    | Div_int32 (a, b) ->
      let temp_a = compile_expression buffer ~idgen a in
      let temp_b = compile_expression buffer ~idgen b in
      rprint "%s / %s" temp_a temp_b
    | Mul_int32 (a, b) ->
      let temp_a = compile_expression buffer ~idgen a in
      let temp_b = compile_expression buffer ~idgen b in
      rprint "%s * %s" temp_a temp_b
    | Min_float (a, b) ->
      let temp_a = compile_expression buffer ~idgen a in
      let temp_b = compile_expression buffer ~idgen b in
      rprint "(%s < %s ? %s : %s)" temp_a temp_b temp_a temp_b
    | Min_int32 (a, b) ->
      let temp_a = compile_expression buffer ~idgen a in
      let temp_b = compile_expression buffer ~idgen b in
      rprint "(%s < %s ? %s : %s)" temp_a temp_b temp_a temp_b
    | Max_float (a, b) ->
      let temp_a = compile_expression buffer ~idgen a in
      let temp_b = compile_expression buffer ~idgen b in
      rprint "(%s > %s ? %s : %s)" temp_a temp_b temp_a temp_b
    | Max_int32 (a, b) ->
      let temp_a = compile_expression buffer ~idgen a in
      let temp_b = compile_expression buffer ~idgen b in
      rprint "(%s > %s ? %s : %s)" temp_a temp_b temp_a temp_b
    | Add_int (a, b) ->
      let temp_a = compile_expression buffer ~idgen a in
      let temp_b = compile_expression buffer ~idgen b in
      rprint "%s + %s" temp_a temp_b
    | Sub_int (a, b) ->
      let temp_a = compile_expression buffer ~idgen a in
      let temp_b = compile_expression buffer ~idgen b in
      rprint "%s - %s" temp_a temp_b
    | Div_int (a, b) ->
      let temp_a = compile_expression buffer ~idgen a in
      let temp_b = compile_expression buffer ~idgen b in
      rprint "%s / %s" temp_a temp_b
    | Mul_int (a, b) ->
      let temp_a = compile_expression buffer ~idgen a in
      let temp_b = compile_expression buffer ~idgen b in
      rprint "%s * %s" temp_a temp_b
    | Int_to_float a ->
      let temp_a = compile_expression buffer ~idgen a in
      rprint "(float) %s" temp_a
    | Int_to_int32 a ->
      let temp_a = compile_expression buffer ~idgen a in
      rprint "(int32_t) %s" temp_a
    | Int32_to_float a ->
      let temp_a = compile_expression buffer ~idgen a in
      rprint "(float) %s" temp_a
    | Float_to_int a ->
      let temp_a = compile_expression buffer ~idgen a in
      rprint "(int) %s" temp_a
    | Float_to_int32 a ->
      let temp_a = compile_expression buffer ~idgen a in
      rprint "(int32_t) %s" temp_a
    | Eq_int (a, b) ->
      let temp_a = compile_expression buffer ~idgen a in
      let temp_b = compile_expression buffer ~idgen b in
      rprint "%s == %s" temp_a temp_b
    | Range2 _ | Array_set _ | Var _ | Progn _ ->
      failwith "unreachable"
    | Cond (_, c, a, b) ->
      let temp_c = compile_expression buffer ~idgen c in
      let temp_a = compile_expression buffer ~idgen a in
      let temp_b = compile_expression buffer ~idgen b in
      rprint "%s ? %s : %s" temp_c temp_a temp_b);
    temp
;;

let compile ~name ~idgen { Function.expression; typ = _; param_map } =
  let buffer = Buffer.create 32 in
  bprintf buffer "#include \"stdint.h\"\n";
  bprintf
    buffer
    "extern %s %s("
    (Type.to_string (Expr.typeof expression))
    name;
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
    let new_id =
      Hashtbl.find_or_add mapping id ~default:Id_gen.create
    in
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
  let args = [ "-shared"; name; "-lm"; "-O3"; "-o"; out ] in
  Out_channel.write_all
    log
    ~data:(String.concat ("gcc" :: args) ~sep:" ");
  let%bind (_ : string) = Async.Process.run () ~prog:"gcc" ~args in
  return out
;;

let load source = Dl.dlopen ~filename:source ~flags:[ Dl.RTLD_NOW ]

let jit f =
  let open Async.Deferred.Let_syntax in
  let c_source, name = compile f in
  let%bind compiled_filename =
    compile_c c_source |> Deferred.Or_error.ok_exn
  in
  let asm_source () =
    let dump =
      {|
#!/bin/bash

gdb -batch "$1" -ex 'disassemble var_0' \
    | head --lines=-1 \
    | tail --lines=+2 \
    | cut --fields="2"
  |}
    in
    let name, writer =
      Core.Filename.open_temp_file "dump_asm" ".sh"
    in
    Out_channel.output_string writer dump;
    Out_channel.flush writer;
    Out_channel.close writer;
    Async.Process.run
      ()
      ~prog:"bash"
      ~args:[ name; compiled_filename ]
    |> Deferred.Or_error.ok_exn
  in
  let library = load compiled_filename in
  let debug = { Debug.c_source; asm_source } in
  return (Foreign.foreign ~from:library name f.typ, debug)
;;
