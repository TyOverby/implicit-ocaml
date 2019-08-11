open Core_kernel
open Async

module Id = struct
  module M = Core_kernel.Unique_id.Int ()
  type t = M.t
  let create = M.create 
  module Table = M.Table
end

module Expr = struct
  type 'a t =
    | Var : 'a Ctypes.typ * Id.t -> 'a t
    | Int_lit : int -> int t
    | Bool_lit : bool -> bool t
    | Float_lit : float -> float t
    | Add_float: float t * float t -> float t
    | Add_int : int t * int t -> int t
    | Eq_int : int t * int t -> bool t
    | Cond : 'a Ctypes.typ * bool t * 'a t * 'a t -> 'a t

  let rec typeof (type a) : a t -> a Ctypes.typ = function
    | Var (typ, _) -> typ
    | Int_lit _ -> Ctypes.int
    | Float_lit _ -> Ctypes.float
    | Bool_lit _ -> Ctypes.bool
    | Add_int _ -> Ctypes.int
    | Add_float _ -> Ctypes.float
    | Eq_int (_, _) -> Ctypes.bool
    | Cond (c, _, _, _) -> c

  and int_lit i = Int_lit i
  and float_lit i = Float_lit i
  and bool_lit i = Bool_lit i
  and add_int a b = Add_int (a, b)
  and add_float a b = Add_float (a, b)
  and eq_int a b = Eq_int (a, b)

  and cond c t f =
    let typ = typeof t in
    Cond (typ, c, t, f)
  ;;
end

module Type = struct
  type 'a t = 'a Ctypes.typ

  let to_string a = Ctypes.string_of_typ a
end

module Function = struct
  type ('a, 'r) t =
    { expression : 'a Expr.t
    ; typ : 'r Ctypes.fn
    ; param_map : (Id.t * string) list
    }

  type 'a param =
    { typ : 'a Type.t
    ; id : Id.t
    }

  let with_parameter { typ; id } ~f =
    let ( @-> ) = Ctypes.( @-> ) in
    let { expression; typ = expr_typ; param_map } = f (Expr.Var (typ, id)) in
    let param_map = (id, Type.to_string typ) :: param_map in
    { expression; typ = typ @-> expr_typ; param_map }
  ;;

  module Let_syntax = struct
    let return constant =
      { expression = constant
      ; typ = Ctypes.returning (Expr.typeof constant)
      ; param_map = []
      }
    ;;

    module Let_syntax = struct
      let bind param ~f =
        let arg = { typ = param; id = Id.create () } in
        with_parameter arg ~f
      ;;
    end
  end
end

module Compile = struct
  let rec compile_expression : type a. Buffer.t -> idgen:(Id.t -> string) -> a Expr.t -> string =
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
    | Bool_lit b -> rprint "%b" b
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
        let new_id = Hashtbl.find_or_add mapping id ~default:(Id_gen.create) in
        sprintf "var_%s" (Id_gen.to_string new_id)
    in 
    let name = idgen (Id.create ()) in 
    (compile ~name ~idgen f), name


  let compile_c source = 
   let open Async.Deferred.Or_error.Let_syntax in 
   let name, writer = Core.Filename.open_temp_file "prefix" ".c" in
   Out_channel.output_string writer source;
   Out_channel.flush writer ;
   Out_channel.close writer;
   let basepath, _  = Core.Filename.split_extension name in
   let out = basepath ^ ".so" in 
   let log = basepath ^ ".sh" in 
   let args = ["-shared"; name; "-lm"; "-o"; out] in
   Out_channel.write_all log ~data:(String.concat ("gcc"::args) ~sep:" ");
   let%bind _: string  = Async.Process.run () ~prog:"gcc" ~args in 
   return out

 let load source = 
  Dl.dlopen ~filename:source ~flags:[Dl.RTLD_NOW] 

 let jit f = 
  let open Async.Deferred.Let_syntax in 
  let c_source, name = compile f in
  let%bind compiled_filename = compile_c c_source |> Deferred.Or_error.ok_exn  in 
  let library = load compiled_filename in 
  return (Foreign.foreign ~from:library name  f.typ)
end

let f =
  let open Function.Let_syntax in
  let%bind b = Ctypes.bool in
  let%bind x = Ctypes.int in
  let%bind y = Ctypes.int in
  return (Expr.cond b x y)
;;

let%expect_test "" =
  let source, _name =  (Compile.compile f) in
  print_endline source;
  [%expect
    {|
    extern int var_0(_Bool var_1, int var_2, int var_3) {
    _Bool var_5 = var_1;
    int var_6 = var_2;
    int var_7 = var_3;
    int var_4 = var_5 ? var_6 : var_7;
    return var_4;
    } |}]
;;

let%expect_test "jitsy" = let f =
   let open Function.Let_syntax in
   let%bind b = Ctypes.bool in
   let%bind x = Ctypes.int in
   let%bind y = Ctypes.int in
   return (Expr.cond b x y)
 in
 let%bind f = Compile.jit f in
 print_s [%message (f true 3 5: int)];
 print_s [%message (f false 3 5: int)];
 [%expect {|
   ("f true 3 5" 3)
   ("f false 3 5" 5) |}]
;;

let%expect_test "jitsy" = let f =
   let open Function.Let_syntax in
   let%bind x = Ctypes.int in
   let%bind y = Ctypes.int in
   return (Expr.eq_int x y)
 in
 let%bind f = Compile.jit f in
 print_s [%message (f 3 5: bool)];
 print_s [%message (f 3 3: bool)];
 [%expect {|
   ("f 3 5" false)
   ("f 3 3" true) |}]
;;

let%expect_test "" =
  let open Ctypes in
  print_endline (string_of_typ int);
  [%expect "int"]
;;
