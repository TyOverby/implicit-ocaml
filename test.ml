open Core_kernel
open Async

module Exploration = struct
  let%expect_test "" =
    let open Ctypes in
    print_endline (string_of_typ int);
    [%expect "int"]
  ;;
end

let test f g =
  let source, _name = Compile.compile f in
  print_endline "===== source ===";
  print_endline source;
  let%bind f = Compile.jit f in
  print_endline "===== out ======";
  List.iter (g f) ~f:print_s;
  return ()
;;

let%expect_test "b ? x : y" =
  let f =
    let open Function.Let_syntax in
    let%bind b = Ctypes.bool in
    let%bind x = Ctypes.int in
    let%bind y = Ctypes.int in
    return (Expr.cond b x y)
  in
  let%bind () =
    test f (fun f ->
        [ [%message (f true 3 5 : int)]
        ; [%message (f false 3 5 : int)]
        ; [%message (f true 1 2 : int)]
        ])
  in
  [%expect
    {|
    ===== source ===
    extern int var_0(_Bool var_1, int var_2, int var_3) {
    _Bool var_5 = var_1;
    int var_6 = var_2;
    int var_7 = var_3;
    int var_4 = var_5 ? var_6 : var_7;
    return var_4;
    }
    ===== out ======
    ("f true 3 5" 3)
    ("f false 3 5" 5)
    ("f true 1 2" 1) |}]
;;

let%expect_test "x == y" =
  let f =
    let open Function.Let_syntax in
    let%bind x = Ctypes.int in
    let%bind y = Ctypes.int in
    return (Expr.eq_int x y)
  in
  let%bind () =
    test f (fun f ->
        [ [%message (f 3 5 : bool)]
        ; [%message (f 3 3 : bool)]
        ; [%message (f 5 5 : bool)]
        ])
  in
  [%expect
    {|
   ===== source ===
   extern _Bool var_0(int var_1, int var_2) {
   int var_4 = var_1;
   int var_5 = var_2;
   _Bool var_3 = var_4 == var_5;
   return var_3;
   }
   ===== out ======
   ("f 3 5" false)
   ("f 3 3" true)
   ("f 5 5" true) |}]
;;

let%expect_test "int literal" =
  let f =
    let open Function.Let_syntax in
    let%bind _x = Ctypes.int in
    return (Expr.int_lit 5)
  in
  let%bind () = test f (fun f -> [ [%message (f 0 : int)] ]) in
  [%expect
    {|
    ===== source ===
    extern int var_0(int var_1) {
    int var_2 = 5;
    return var_2;
    }
    ===== out ======
    ("f 0" 5) |}]
;;

let%expect_test "int param" =
  let f =
    let open Function.Let_syntax in
    let%bind x = Ctypes.int in
    return x
  in
  let%bind () =
    test f (fun f ->
        [ [%message (f 0 : int)]
        ; [%message (f 1 : int)]
        ; [%message (f (-2) : int)]
        ; [%message (f 4 : int)]
        ])
  in
  [%expect
    {|
    ===== source ===
    extern int var_0(int var_1) {
    int var_2 = var_1;
    return var_2;
    }
    ===== out ======
    ("f 0" 0)
    ("f 1" 1)
    ("f (-2)" -2)
    ("f 4" 4) |}]
;;

let%expect_test "float param" =
  let f =
    let open Function.Let_syntax in
    let%bind x = Ctypes.float in
    return x
  in
  let%bind () =
    test f (fun f ->
        [ [%message (f 0.9 : float)]
        ; [%message (f 1.0 : float)]
        ; [%message (f (-2.55) : float)]
        ; [%message (f 999.00 : float)]
        ])
  in
  [%expect
    {|
    ===== source ===
    extern float var_0(float var_1) {
    float var_2 = var_1;
    return var_2;
    }
    ===== out ======
    ("f 0.9" 0.89999997615814209)
    ("f 1.0" 1)
    ("f (-2.55)" -2.5499999523162842)
    ("f 999.00" 999) |}]
;;

let%expect_test "float param" =
  let f =
    let open Function.Let_syntax in
    let%bind x = Ctypes.float in
    return x
  in
  let%bind () =
    test f (fun f ->
        [ [%message (f 0.9 : float)]
        ; [%message (f 1.0 : float)]
        ; [%message (f (-2.55) : float)]
        ; [%message (f 999.00 : float)]
        ])
  in
  [%expect
    {|
    ===== source ===
    extern float var_0(float var_1) {
    float var_2 = var_1;
    return var_2;
    }
    ===== out ======
    ("f 0.9" 0.89999997615814209)
    ("f 1.0" 1)
    ("f (-2.55)" -2.5499999523162842)
    ("f 999.00" 999) |}]
;;

let%expect_test "float literal" =
  let f =
    let open Function.Let_syntax in
    let%bind _x = Ctypes.int in
    return (Expr.float_lit 5.0)
  in
  let%bind () = test f (fun f -> [ [%message (f 0 : float)] ]) in
  [%expect
    {|
    ===== source ===
    extern float var_0(int var_1) {
    float var_2 = 5.000000;
    return var_2;
    }
    ===== out ======
    ("f 0" 5) |}]
;;

let%expect_test "bool literal" =
  let f =
    let open Function.Let_syntax in
    let%bind _x = Ctypes.int in
    return (Expr.bool_lit true)
  in
  let%bind () = test f (fun f -> [ [%message (f 0 : bool)] ]) in
  [%expect{|
    ===== source ===
    extern _Bool var_0(int var_1) {
    _Bool var_2 = 1;
    return var_2;
    }
    ===== out ======
    ("f 0" true) |}]
;;

let%expect_test "bool literal" =
  let f =
    let open Function.Let_syntax in
    let%bind _x = Ctypes.int in
    return (Expr.bool_lit false)
  in
  let%bind () = test f (fun f -> [ [%message (f 0 : bool)] ]) in
  [%expect{|
    ===== source ===
    extern _Bool var_0(int var_1) {
    _Bool var_2 = 0;
    return var_2;
    }
    ===== out ======
    ("f 0" false) |}]
;;

let%expect_test "add int" =
  let f =
    let open Function.Let_syntax in
    let%bind x = Ctypes.int in
    let%bind y = Ctypes.int in
    return (Expr.add_int x y)
  in
  let%bind () = test f (fun f -> [ 
      [%message (f 1 3 : int)] ;
      [%message (f 3 4 : int)] ;
      [%message (f (-3) 3 : int)] ;
      ]) in
  [%expect{|
    ===== source ===
    extern int var_0(int var_1, int var_2) {
    int var_4 = var_1;
    int var_5 = var_2;
    int var_3 = var_4 + var_5;
    return var_3;
    }
    ===== out ======
    ("f 1 3" 4)
    ("f 3 4" 7)
    ("f (-3) 3" 0) |}]
;;

let%expect_test "add float" =
  let f =
    let open Function.Let_syntax in
    let%bind x = Ctypes.float in
    let%bind y = Ctypes.float in
    return (Expr.add_float x y)
  in
  let%bind () = test f (fun f -> [ 
      [%message (f 1.0 3.0 : float)] ;
      [%message (f 3.0 4.0 : float)] ;
      [%message (f (-3.0) 3.0 : float)] ;
      ]) in
  [%expect{|
    ===== source ===
    extern float var_0(float var_1, float var_2) {
    float var_4 = var_1;
    float var_5 = var_2;
    float var_3 = var_4 + var_5;
    return var_3;
    }
    ===== out ======
    ("f 1.0 3.0" 4)
    ("f 3.0 4.0" 7)
    ("f (-3.0) 3.0" 0) |}]
;;

let%expect_test "eq int" =
  let f =
    let open Function.Let_syntax in
    let%bind x = Ctypes.int in
    let%bind y = Ctypes.int in
    return (Expr.eq_int x y)
  in
  let%bind () = test f (fun f -> [ 
      [%message (f 1 1 : bool)] ;
      [%message (f 3 4 : bool)] ;
      [%message (f 0 0 : bool)] ;
      ]) in
  [%expect{|
    ===== source ===
    extern _Bool var_0(int var_1, int var_2) {
    int var_4 = var_1;
    int var_5 = var_2;
    _Bool var_3 = var_4 == var_5;
    return var_3;
    }
    ===== out ======
    ("f 1 1" true)
    ("f 3 4" false)
    ("f 0 0" true) |}]
;;
