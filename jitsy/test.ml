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
  print_endline "===== source =====";
  print_endline source;
  let%bind f, disas = Compile.jit f in
  print_endline "====== asm =======";
  let%bind disas = disas () in
  print_string disas;
  print_endline "====== out =======";
  List.iter (g f) ~f:print_s;
  return ()
;;

let%expect_test "b ? x : y" =
  let f =
    let open Function.Let_syntax in
    let%bind b = Type.bool in
    let%bind x = Type.int in
    let%bind y = Type.int in
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
    ===== source =====
    extern int var_0(_Bool var_1, int var_2, int var_3) {
    int var_4 = var_1 ? var_2 : var_3;
    return var_4;
    }
    ====== asm =======
    test   %dil,%dil
    mov    %edx,%eax
    cmovne %esi,%eax
    retq
    ====== out =======
    ("f true 3 5" 3)
    ("f false 3 5" 5)
    ("f true 1 2" 1) |}]
;;

let%expect_test "x == y" =
  let f =
    let open Function.Let_syntax in
    let%bind x = Type.int in
    let%bind y = Type.int in
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
   ===== source =====
   extern _Bool var_0(int var_1, int var_2) {
   _Bool var_3 = var_1 == var_2;
   return var_3;
   }
   ====== asm =======
   cmp    %esi,%edi
   sete   %al
   retq
   ====== out =======
   ("f 3 5" false)
   ("f 3 3" true)
   ("f 5 5" true) |}]
;;

let%expect_test "int literal" =
  let f =
    let open Function.Let_syntax in
    let%bind _x = Type.int in
    return (Expr.int_lit 5)
  in
  let%bind () = test f (fun f -> [ [%message (f 0 : int)] ]) in
  [%expect
    {|
    ===== source =====
    extern int var_0(int var_1) {
    int var_2 = 5;
    return var_2;
    }
    ====== asm =======
    mov    $0x5,%eax
    retq
    ====== out =======
    ("f 0" 5) |}]
;;

let%expect_test "int param" =
  let f =
    let open Function.Let_syntax in
    let%bind x = Type.int in
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
    ===== source =====
    extern int var_0(int var_1) {
    return var_1;
    }
    ====== asm =======
    mov    %edi,%eax
    retq
    ====== out =======
    ("f 0" 0)
    ("f 1" 1)
    ("f (-2)" -2)
    ("f 4" 4) |}]
;;

let%expect_test "float param" =
  let f =
    let open Function.Let_syntax in
    let%bind x = Type.float in
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
    ===== source =====
    extern float var_0(float var_1) {
    return var_1;
    }
    ====== asm =======
    repz retq
    ====== out =======
    ("f 0.9" 0.89999997615814209)
    ("f 1.0" 1)
    ("f (-2.55)" -2.5499999523162842)
    ("f 999.00" 999) |}]
;;

let%expect_test "float param" =
  let f =
    let open Function.Let_syntax in
    let%bind x = Type.float in
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
    ===== source =====
    extern float var_0(float var_1) {
    return var_1;
    }
    ====== asm =======
    repz retq
    ====== out =======
    ("f 0.9" 0.89999997615814209)
    ("f 1.0" 1)
    ("f (-2.55)" -2.5499999523162842)
    ("f 999.00" 999) |}]
;;

let%expect_test "float literal" =
  let f =
    let open Function.Let_syntax in
    let%bind _x = Type.int in
    return (Expr.float_lit 5.0)
  in
  let%bind () = test f (fun f -> [ [%message (f 0 : float)] ]) in
  [%expect
    {|
    ===== source =====
    extern float var_0(int var_1) {
    float var_2 = 5.000000;
    return var_2;
    }
    ====== asm =======
    movss  0x10(%rip),%xmm0        # 0x598
    retq
    ====== out =======
    ("f 0" 5) |}]
;;

let%expect_test "bool literal" =
  let f =
    let open Function.Let_syntax in
    let%bind _x = Type.int in
    return (Expr.bool_lit true)
  in
  let%bind () = test f (fun f -> [ [%message (f 0 : bool)] ]) in
  [%expect
    {|
    ===== source =====
    extern _Bool var_0(int var_1) {
    _Bool var_2 = 1;
    return var_2;
    }
    ====== asm =======
    mov    $0x1,%eax
    retq
    ====== out =======
    ("f 0" true) |}]
;;

let%expect_test "bool literal (false)" =
  let f =
    let open Function.Let_syntax in
    let%bind _x = Type.int in
    return (Expr.bool_lit false)
  in
  let%bind () = test f (fun f -> [ [%message (f 0 : bool)] ]) in
  [%expect
    {|
    ===== source =====
    extern _Bool var_0(int var_1) {
    _Bool var_2 = 0;
    return var_2;
    }
    ====== asm =======
    xor    %eax,%eax
    retq
    ====== out =======
    ("f 0" false) |}]
;;

let%expect_test "bool literal (true)" =
  let f =
    let open Function.Let_syntax in
    let%bind _x = Type.int in
    return (Expr.bool_lit true)
  in
  let%bind () = test f (fun f -> [ [%message (f 0 : bool)] ]) in
  [%expect
    {|
    ===== source =====
    extern _Bool var_0(int var_1) {
    _Bool var_2 = 1;
    return var_2;
    }
    ====== asm =======
    mov    $0x1,%eax
    retq
    ====== out =======
    ("f 0" true) |}]
;;

let%expect_test "add int" =
  let f =
    let open Function.Let_syntax in
    let%bind x = Type.int in
    let%bind y = Type.int in
    return (Expr.add_int x y)
  in
  let%bind () =
    test f (fun f ->
        [ [%message (f 1 3 : int)]
        ; [%message (f 3 4 : int)]
        ; [%message (f (-3) 3 : int)]
        ])
  in
  [%expect
    {|
    ===== source =====
    extern int var_0(int var_1, int var_2) {
    int var_3 = var_1 + var_2;
    return var_3;
    }
    ====== asm =======
    lea    (%rdi,%rsi,1),%eax
    retq
    ====== out =======
    ("f 1 3" 4)
    ("f 3 4" 7)
    ("f (-3) 3" 0) |}]
;;

let%expect_test "add float" =
  let f =
    let open Function.Let_syntax in
    let%bind x = Type.float in
    let%bind y = Type.float in
    return (Expr.add_float x y)
  in
  let%bind () =
    test f (fun f ->
        [ [%message (f 1.0 3.0 : float)]
        ; [%message (f 3.0 4.0 : float)]
        ; [%message (f (-3.0) 3.0 : float)]
        ])
  in
  [%expect
    {|
    ===== source =====
    extern float var_0(float var_1, float var_2) {
    float var_3 = var_1 + var_2;
    return var_3;
    }
    ====== asm =======
    addss  %xmm1,%xmm0
    retq
    ====== out =======
    ("f 1.0 3.0" 4)
    ("f 3.0 4.0" 7)
    ("f (-3.0) 3.0" 0) |}]
;;

let%expect_test "sub float" =
  let f =
    let open Function.Let_syntax in
    let%bind x = Type.float in
    let%bind y = Type.float in
    return (Expr.sub_float x y)
  in
  let%bind () =
    test f (fun f ->
        [ [%message (f 1.0 3.0 : float)]
        ; [%message (f 3.0 4.0 : float)]
        ; [%message (f (-3.0) 3.0 : float)]
        ])
  in
  [%expect
    {|
    ===== source =====
    extern float var_0(float var_1, float var_2) {
    float var_3 = var_1 - var_2;
    return var_3;
    }
    ====== asm =======
    subss  %xmm1,%xmm0
    retq
    ====== out =======
    ("f 1.0 3.0" -2)
    ("f 3.0 4.0" -1)
    ("f (-3.0) 3.0" -6) |}]
;;

let%expect_test "mul float" =
  let f =
    let open Function.Let_syntax in
    let%bind x = Type.float in
    let%bind y = Type.float in
    return (Expr.mul_float x y)
  in
  let%bind () =
    test f (fun f ->
        [ [%message (f 1.0 3.0 : float)]
        ; [%message (f 3.0 4.0 : float)]
        ; [%message (f (-3.0) 3.0 : float)]
        ])
  in
  [%expect
    {|
    ===== source =====
    extern float var_0(float var_1, float var_2) {
    float var_3 = var_1 * var_2;
    return var_3;
    }
    ====== asm =======
    mulss  %xmm1,%xmm0
    retq
    ====== out =======
    ("f 1.0 3.0" 3)
    ("f 3.0 4.0" 12)
    ("f (-3.0) 3.0" -9) |}]
;;

let%expect_test "div float" =
  let f =
    let open Function.Let_syntax in
    let%bind x = Type.float in
    let%bind y = Type.float in
    return (Expr.div_float x y)
  in
  let%bind () =
    test f (fun f ->
        [ [%message (f 1.0 3.0 : float)]
        ; [%message (f 3.0 4.0 : float)]
        ; [%message (f (-3.0) 3.0 : float)]
        ])
  in
  [%expect
    {|
    ===== source =====
    extern float var_0(float var_1, float var_2) {
    float var_3 = var_1 / var_2;
    return var_3;
    }
    ====== asm =======
    divss  %xmm1,%xmm0
    retq
    ====== out =======
    ("f 1.0 3.0" 0.3333333432674408)
    ("f 3.0 4.0" 0.75)
    ("f (-3.0) 3.0" -1) |}]
;;

let%expect_test "eq int" =
  let f =
    let open Function.Let_syntax in
    let%bind x = Type.int in
    let%bind y = Type.int in
    return (Expr.eq_int x y)
  in
  let%bind () =
    test f (fun f ->
        [ [%message (f 1 1 : bool)]
        ; [%message (f 3 4 : bool)]
        ; [%message (f 0 0 : bool)]
        ])
  in
  [%expect
    {|
    ===== source =====
    extern _Bool var_0(int var_1, int var_2) {
    _Bool var_3 = var_1 == var_2;
    return var_3;
    }
    ====== asm =======
    cmp    %esi,%edi
    sete   %al
    retq
    ====== out =======
    ("f 1 1" true)
    ("f 3 4" false)
    ("f 0 0" true) |}]
;;

let%expect_test "int to float" =
  let f =
    let open Function.Let_syntax in
    let%bind x = Type.int in
    return (Expr.int_to_float x)
  in
  let%bind () =
    test f (fun f ->
        [ [%message (f 1 : float)]
        ; [%message (f 3 : float)]
        ; [%message (f (-3) : float)]
        ; [%message (f 0 : float)]
        ])
  in
  [%expect
    {|
    ===== source =====
    extern float var_0(int var_1) {
    float var_2 = (float) var_1;
    return var_2;
    }
    ====== asm =======
    pxor   %xmm0,%xmm0
    cvtsi2ss %edi,%xmm0
    retq
    ====== out =======
    ("f 1" 1)
    ("f 3" 3)
    ("f (-3)" -3)
    ("f 0" 0) |}]
;;

let%expect_test "float to int" =
  let f =
    let open Function.Let_syntax in
    let%bind x = Type.float in
    return (Expr.float_to_int x)
  in
  let%bind () =
    test f (fun f ->
        [ [%message (f 1.5 : int)]
        ; [%message (f 3.0 : int)]
        ; [%message (f (-1.3) : int)]
        ; [%message (f 0.25 : int)]
        ])
  in
  [%expect
    {|
    ===== source =====
    extern int var_0(float var_1) {
    int var_2 = (int) var_1;
    return var_2;
    }
    ====== asm =======
    cvttss2si %xmm0,%eax
    retq
    ====== out =======
    ("f 1.5" 1)
    ("f 3.0" 3)
    ("f (-1.3)" -1)
    ("f 0.25" 0) |}]
;;

let%expect_test "sub int" =
  let f =
    let open Function.Let_syntax in
    let%bind x = Type.int in
    let%bind y = Type.int in
    return (Expr.sub_int x y)
  in
  let%bind () =
    test f (fun f ->
        [ [%message (f 1 3 : int)]
        ; [%message (f 3 4 : int)]
        ; [%message (f (-3) 3 : int)]
        ])
  in
  [%expect
    {|
    ===== source =====
    extern int var_0(int var_1, int var_2) {
    int var_3 = var_1 - var_2;
    return var_3;
    }
    ====== asm =======
    mov    %edi,%eax
    sub    %esi,%eax
    retq
    ====== out =======
    ("f 1 3" -2)
    ("f 3 4" -1)
    ("f (-3) 3" -6) |}]
;;

let%expect_test "mul int" =
  let f =
    let open Function.Let_syntax in
    let%bind x = Type.int in
    let%bind y = Type.int in
    return (Expr.mul_int x y)
  in
  let%bind () =
    test f (fun f ->
        [ [%message (f 1 3 : int)]
        ; [%message (f 3 4 : int)]
        ; [%message (f (-3) 3 : int)]
        ])
  in
  [%expect
    {|
    ===== source =====
    extern int var_0(int var_1, int var_2) {
    int var_3 = var_1 * var_2;
    return var_3;
    }
    ====== asm =======
    mov    %edi,%eax
    imul   %esi,%eax
    retq
    ====== out =======
    ("f 1 3" 3)
    ("f 3 4" 12)
    ("f (-3) 3" -9) |}]
;;

let%expect_test "div int" =
  let f =
    let open Function.Let_syntax in
    let%bind x = Type.int in
    let%bind y = Type.int in
    return (Expr.div_int x y)
  in
  let%bind () =
    test f (fun f ->
        [ [%message (f 6 3 : int)]
        ; [%message (f (-123) 4 : int)]
        ; [%message (f (-3) 3 : int)]
        ])
  in
  [%expect
    {|
    ===== source =====
    extern int var_0(int var_1, int var_2) {
    int var_3 = var_1 / var_2;
    return var_3;
    }
    ====== asm =======
    mov    %edi,%eax
    cltd
    idiv   %esi
    retq
    ====== out =======
    ("f 6 3" 2)
    ("f (-123) 4" -30)
    ("f (-3) 3" -1) |}]
;;

let%expect_test "big-array" =
  let f =
    let open Function.Let_syntax in
    let%bind a = Type.float_array in
    let%bind y = Type.int in
    return
      (Expr.progn
         [ Expr.array_set a y (Expr.div_float (Expr.int_to_float y) (Expr.float_lit 2.0))
         ]
         y)
  in
  let%bind () =
    test f (fun f ->
        let bigarray = Bigarray.Array1.create Bigarray.float32 Bigarray.C_layout 10 in
        List.range 0 10 |> List.iter ~f:(fun i -> bigarray.{i} <- 0.0);
        let _ = f (Ctypes.bigarray_start Ctypes.array1 bigarray) 1 in
        let _ = f (Ctypes.bigarray_start Ctypes.array1 bigarray) 2 in
        let _ = f (Ctypes.bigarray_start Ctypes.array1 bigarray) 3 in
        let _ = f (Ctypes.bigarray_start Ctypes.array1 bigarray) 4 in
        let _ = f (Ctypes.bigarray_start Ctypes.array1 bigarray) 5 in
        let list =
          [ bigarray.{0}
          ; bigarray.{1}
          ; bigarray.{2}
          ; bigarray.{3}
          ; bigarray.{4}
          ; bigarray.{5}
          ]
        in
        [ [%message (list : float list)] ])
  in
  [%expect
    {|
    ===== source =====
    extern int var_0(float* var_1, int var_2) {
    float var_4 = (float) var_2;
    float var_5 = 2.000000;
    float var_3 = var_4 / var_5;
    var_1[var_2] = var_3;
    return var_2;
    }
    ====== asm =======
    pxor   %xmm0,%xmm0
    movslq %esi,%rdx
    mov    %rdx,%rax
    cvtsi2ss %edx,%xmm0
    mulss  0x12(%rip),%xmm0        # 0x5a8
    movss  %xmm0,(%rdi,%rdx,4)
    retq
    ====== out =======
    (list (0 0.5 1 1.5 2 2.5)) |}]
;;
