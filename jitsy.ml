open Core_kernel
open Async

module Id = struct
  include Core_kernel.Unique_id.Int ()

  let to_string t = "var_" ^ to_string t
end

module Expr = struct
  type 'a t =
    | Var : 'a Ctypes.typ * Id.t -> 'a t
    | Int_lit : int -> int t
    | Bool_lit : bool -> bool t
    | Add_int : int t * int t -> int t
    | Eq_int : int t * int t -> bool t
    | Cond : 'a Ctypes.typ * bool t * 'a t * 'a t -> 'a t

  let rec typeof (type a) : a t -> a Ctypes.typ = function
    | Var (typ, _) -> typ
    | Int_lit _ -> Ctypes.int
    | Bool_lit _ -> Ctypes.bool
    | Add_int _ -> Ctypes.int
    | Eq_int (_, _) -> Ctypes.bool
    | Cond (c, _, _, _) -> c

  and int_lit i = Int_lit i
  and bool_lit i = Bool_lit i
  and add_int a b = Add_int (a, b)
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
  let rec compile_expression : type a. Buffer.t -> a Expr.t -> string =
   fun buffer expr ->
    let open Expr in
    let temp = Id.to_string (Id.create ()) in
    let typ = Type.to_string (Expr.typeof expr) in
    let rprint s =
      bprintf buffer "%s %s = " typ temp;
      bprintf buffer (s ^^ ";\n")
    in
    (match expr with
    | Int_lit i -> rprint "%d" i
    | Bool_lit b -> rprint "%b" b
    | Add_int (a, b) ->
      let temp_a = compile_expression buffer a in
      let temp_b = compile_expression buffer b in
      rprint "%s + %s" temp_a temp_b
    | Eq_int (a, b) ->
      let temp_a = compile_expression buffer a in
      let temp_b = compile_expression buffer b in
      rprint "%s == %s" temp_a temp_b
    | Cond (_, c, a, b) ->
      let temp_c = compile_expression buffer c in
      let temp_a = compile_expression buffer a in
      let temp_b = compile_expression buffer b in
      rprint "%s ? %s : %s" temp_c temp_a temp_b
    | Var (_, id) -> rprint "%s" (Id.to_string id));
    temp
 ;;

  let compile ~name { Function.expression; typ = _; param_map } =
    let buffer = Buffer.create 32 in
    bprintf buffer "extern %s %s(" (Type.to_string (Expr.typeof expression)) name;
    param_map
    |> List.map ~f:(fun (id, typ) -> sprintf "%s %s" typ (Id.to_string id))
    |> List.intersperse ~sep:", "
    |> List.iter ~f:(Buffer.add_string buffer);
    bprintf buffer ") {\n";
    let return_temp = compile_expression buffer expression in
    bprintf buffer "return %s;\n" return_temp;
    bprintf buffer "}";
    Buffer.contents buffer
  ;;

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
  let name = Id.create () |> Id.to_string in 
  let c_source = compile ~name f in
  let%bind compiled_filename = compile_c c_source |> Deferred.Or_error.ok_exn  in 
  let library =  load compiled_filename in 
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
  print_endline (Compile.compile ~name:"my_function" f);
  [%expect
    {|
    extern int my_function(_Bool var_0, int var_1, int var_2) {
    _Bool var_4 = var_0;
    int var_5 = var_1;
    int var_6 = var_2;
    int var_3 = var_4 ? var_5 : var_6;
    return var_3;
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
