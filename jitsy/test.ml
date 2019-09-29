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
    #include "stdint.h"
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
   #include "stdint.h"
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
    #include "stdint.h"
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
    #include "stdint.h"
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
    #include "stdint.h"
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
    #include "stdint.h"
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
    #include "stdint.h"
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
    #include "stdint.h"
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
    #include "stdint.h"
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
    #include "stdint.h"
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
    #include "stdint.h"
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

let%expect_test "add int32" =
  let f =
    let open Function.Let_syntax in
    let%bind x = Type.int32 in
    let%bind y = Type.int32 in
    return (Expr.add_int32 x y)
  in
  let%bind () =
    test f (fun f ->
        let open Int32 in
        let sexp_of_t t = Sexp.Atom (to_string t) in
        [ [%message (f (of_int_exn 1) (of_int_exn 3) : t)]
        ; [%message (f (of_int_exn 3) (of_int_exn 4) : t)]
        ])
  in
  [%expect
    {|
    ===== source =====
    #include "stdint.h"
    extern int32_t var_0(int32_t var_1, int32_t var_2) {
    int32_t var_3 = var_1 + var_2;
    return var_3;
    }
    ====== asm =======
    lea    (%rdi,%rsi,1),%eax
    retq
    ====== out =======
    ("f (of_int_exn 1) (of_int_exn 3)" 4)
    ("f (of_int_exn 3) (of_int_exn 4)" 7) |}]
;;

let%expect_test "multiply int32" =
  let f =
    let open Function.Let_syntax in
    let%bind x = Type.int32 in
    let%bind y = Type.int32 in
    return (Expr.mul_int32 x y)
  in
  let%bind () =
    test f (fun f ->
        let open Int32 in
        let sexp_of_t t = Sexp.Atom (to_string t) in
        [ [%message (f (of_int_exn 1) (of_int_exn 3) : t)]
        ; [%message (f (of_int_exn 3) (of_int_exn 4) : t)]
        ])
  in
  [%expect
    {|
    ===== source =====
    #include "stdint.h"
    extern int32_t var_0(int32_t var_1, int32_t var_2) {
    int32_t var_3 = var_1 * var_2;
    return var_3;
    }
    ====== asm =======
    mov    %edi,%eax
    imul   %esi,%eax
    retq
    ====== out =======
    ("f (of_int_exn 1) (of_int_exn 3)" 3)
    ("f (of_int_exn 3) (of_int_exn 4)" 12) |}]
;;

let%expect_test "divide int32" =
  let f =
    let open Function.Let_syntax in
    let%bind x = Type.int32 in
    let%bind y = Type.int32 in
    return (Expr.div_int32 x y)
  in
  let%bind () =
    test f (fun f ->
        let open Int32 in
        let sexp_of_t t = Sexp.Atom (to_string t) in
        [ [%message (f (of_int_exn 6) (of_int_exn 3) : t)]
        ; [%message (f (of_int_exn 123) (of_int_exn 4) : t)]
        ; [%message (f (of_int_exn 3) (of_int_exn 3) : t)]
        ])
  in
  [%expect
    {|
    ===== source =====
    #include "stdint.h"
    extern int32_t var_0(int32_t var_1, int32_t var_2) {
    int32_t var_3 = var_1 / var_2;
    return var_3;
    }
    ====== asm =======
    mov    %edi,%eax
    cltd
    idiv   %esi
    retq
    ====== out =======
    ("f (of_int_exn 6) (of_int_exn 3)" 2)
    ("f (of_int_exn 123) (of_int_exn 4)" 30)
    ("f (of_int_exn 3) (of_int_exn 3)" 1) |}]
;;

let%expect_test "sqrt sqrt int32" =
  let f =
    let open Function.Let_syntax in
    let%bind x = Type.int32 in
    return (Expr.sqrt_int32 (Expr.sqrt_int32 x))
  in
  let%bind () = test f (fun f -> [ [%message (f (Int32.of_int_exn 16) : int32)] ]) in
  [%expect
    {|
    ===== source =====
    #include "stdint.h"
    extern int32_t var_0(int32_t var_1) {

            int32_t var_4;
            {
                int32_t v = var_1;
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
                   var_4 = q;
                }
            }
          int32_t var_3 = var_4;

            int32_t var_5;
            {
                int32_t v = var_3;
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
                   var_5 = q;
                }
            }
          int32_t var_2 = var_5;
    return var_2;
    }
    ====== asm =======
    test   %edi,%edi
    jle    0x69d <var_0+285>
    cmp    $0x3fffffff,%edi
    jle    0x748 <var_0+456>
    sub    $0x40000000,%edi
    mov    $0x20000000,%edx
    lea    0x4000000(%rdx),%ecx
    shr    %edx
    cmp    %ecx,%edi
    jb     0x5b3 <var_0+51>
    sub    %ecx,%edi
    add    $0x4000000,%edx
    lea    0x1000000(%rdx),%ecx
    shr    %edx
    cmp    %ecx,%edi
    jb     0x5c7 <var_0+71>
    sub    %ecx,%edi
    add    $0x1000000,%edx
    lea    0x400000(%rdx),%ecx
    shr    %edx
    cmp    %ecx,%edi
    jb     0x5db <var_0+91>
    sub    %ecx,%edi
    add    $0x400000,%edx
    lea    0x100000(%rdx),%ecx
    shr    %edx
    cmp    %ecx,%edi
    jb     0x5ef <var_0+111>
    sub    %ecx,%edi
    add    $0x100000,%edx
    lea    0x40000(%rdx),%ecx
    shr    %edx
    cmp    %ecx,%edi
    jb     0x603 <var_0+131>
    sub    %ecx,%edi
    add    $0x40000,%edx
    lea    0x10000(%rdx),%ecx
    shr    %edx
    cmp    %ecx,%edi
    jb     0x617 <var_0+151>
    sub    %ecx,%edi
    add    $0x10000,%edx
    lea    0x4000(%rdx),%ecx
    shr    %edx
    cmp    %ecx,%edi
    jb     0x62b <var_0+171>
    sub    %ecx,%edi
    add    $0x4000,%edx
    lea    0x1000(%rdx),%ecx
    shr    %edx
    cmp    %ecx,%edi
    jb     0x63f <var_0+191>
    sub    %ecx,%edi
    add    $0x1000,%edx
    lea    0x400(%rdx),%ecx
    shr    %edx
    cmp    %ecx,%edi
    jb     0x653 <var_0+211>
    sub    %ecx,%edi
    add    $0x400,%edx
    lea    0x100(%rdx),%ecx
    shr    %edx
    cmp    %ecx,%edi
    jb     0x667 <var_0+231>
    sub    %ecx,%edi
    add    $0x100,%edx
    lea    0x40(%rdx),%ecx
    shr    %edx
    cmp    %ecx,%edi
    jb     0x675 <var_0+245>
    sub    %ecx,%edi
    add    $0x40,%edx
    lea    0x10(%rdx),%ecx
    shr    %edx
    cmp    %ecx,%edi
    jb     0x683 <var_0+259>
    sub    %ecx,%edi
    add    $0x10,%edx
    lea    0x4(%rdx),%ecx
    shr    %edx
    cmp    %ecx,%edi
    jb     0x691 <var_0+273>
    sub    %ecx,%edi
    add    $0x4,%edx
    mov    %edx,%ecx
    add    $0x1,%edx
    shr    %ecx
    cmp    %edx,%edi
    sbb    $0xffffffff,%ecx
    test   %ecx,%ecx
    jne    0x6a8 <var_0+296>
    repz retq
    nopl   0x0(%rax,%rax,1)
    xor    %edx,%edx
    cmp    $0x3fff,%ecx
    ja     0x728 <var_0+424>
    lea    0x1000(%rdx),%eax
    shr    %edx
    cmp    %eax,%ecx
    jb     0x6c6 <var_0+326>
    sub    %eax,%ecx
    add    $0x1000,%edx
    lea    0x400(%rdx),%eax
    shr    %edx
    cmp    %eax,%ecx
    jb     0x6da <var_0+346>
    sub    %eax,%ecx
    add    $0x400,%edx
    lea    0x100(%rdx),%eax
    shr    %edx
    cmp    %eax,%ecx
    jb     0x6ee <var_0+366>
    sub    %eax,%ecx
    add    $0x100,%edx
    lea    0x40(%rdx),%eax
    shr    %edx
    cmp    %eax,%ecx
    jb     0x6fc <var_0+380>
    sub    %eax,%ecx
    add    $0x40,%edx
    lea    0x10(%rdx),%eax
    shr    %edx
    cmp    %eax,%ecx
    jb     0x70a <var_0+394>
    sub    %eax,%ecx
    add    $0x10,%edx
    lea    0x4(%rdx),%eax
    shr    %edx
    cmp    %eax,%ecx
    jb     0x718 <var_0+408>
    sub    %eax,%ecx
    add    $0x4,%edx
    mov    %edx,%eax
    add    $0x1,%edx
    shr    %eax
    cmp    %edx,%ecx
    sbb    $0xffffffff,%eax
    retq
    nopl   (%rax)
    mov    $0x4000,%edx
    sub    $0x4000,%ecx
    lea    0x1000(%rdx),%eax
    shr    %edx
    cmp    %eax,%ecx
    jb     0x6c6 <var_0+326>
    jmpq   0x6be <var_0+318>
    nopl   0x0(%rax)
    cmp    $0xfffffff,%edi
    jbe    0x760 <var_0+480>
    sub    $0x10000000,%edi
    mov    $0x10000000,%edx
    jmpq   0x59f <var_0+31>
    xor    %edx,%edx
    jmpq   0x59f <var_0+31>
    ====== out =======
    ("f (Int32.of_int_exn 16)" 2) |}]
;;

let%expect_test "sqrt int32" =
  let f =
    let open Function.Let_syntax in
    let%bind x = Type.int32 in
    return (Expr.sqrt_int32 x)
  in
  let%bind () =
    test f (fun f ->
        [ [%message (f (Int32.of_int_exn 4) : int32)]
        ; [%message (f (Int32.of_int_exn 3) : int32)]
        ; [%message (f (Int32.of_int_exn 153) : int32)]
        ])
  in
  [%expect
    {|
    ===== source =====
    #include "stdint.h"
    extern int32_t var_0(int32_t var_1) {

            int32_t var_3;
            {
                int32_t v = var_1;
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
                   var_3 = q;
                }
            }
          int32_t var_2 = var_3;
    return var_2;
    }
    ====== asm =======
    xor    %eax,%eax
    test   %edi,%edi
    jle    0x6ab <var_0+299>
    cmp    $0x3fffffff,%edi
    jg     0x6b0 <var_0+304>
    cmp    $0xfffffff,%edi
    jbe    0x6c0 <var_0+320>
    sub    $0x10000000,%edi
    mov    $0x10000000,%edx
    lea    0x4000000(%rdx),%eax
    shr    %edx
    cmp    %eax,%edi
    jb     0x5c1 <var_0+65>
    sub    %eax,%edi
    add    $0x4000000,%edx
    lea    0x1000000(%rdx),%eax
    shr    %edx
    cmp    %eax,%edi
    jb     0x5d5 <var_0+85>
    sub    %eax,%edi
    add    $0x1000000,%edx
    lea    0x400000(%rdx),%eax
    shr    %edx
    cmp    %eax,%edi
    jb     0x5e9 <var_0+105>
    sub    %eax,%edi
    add    $0x400000,%edx
    lea    0x100000(%rdx),%eax
    shr    %edx
    cmp    %eax,%edi
    jb     0x5fd <var_0+125>
    sub    %eax,%edi
    add    $0x100000,%edx
    lea    0x40000(%rdx),%eax
    shr    %edx
    cmp    %eax,%edi
    jb     0x611 <var_0+145>
    sub    %eax,%edi
    add    $0x40000,%edx
    lea    0x10000(%rdx),%eax
    shr    %edx
    cmp    %eax,%edi
    jb     0x625 <var_0+165>
    sub    %eax,%edi
    add    $0x10000,%edx
    lea    0x4000(%rdx),%eax
    shr    %edx
    cmp    %eax,%edi
    jb     0x639 <var_0+185>
    sub    %eax,%edi
    add    $0x4000,%edx
    lea    0x1000(%rdx),%eax
    shr    %edx
    cmp    %eax,%edi
    jb     0x64d <var_0+205>
    sub    %eax,%edi
    add    $0x1000,%edx
    lea    0x400(%rdx),%eax
    shr    %edx
    cmp    %eax,%edi
    jb     0x661 <var_0+225>
    sub    %eax,%edi
    add    $0x400,%edx
    lea    0x100(%rdx),%eax
    shr    %edx
    cmp    %eax,%edi
    jb     0x675 <var_0+245>
    sub    %eax,%edi
    add    $0x100,%edx
    lea    0x40(%rdx),%eax
    shr    %edx
    cmp    %eax,%edi
    jb     0x683 <var_0+259>
    sub    %eax,%edi
    add    $0x40,%edx
    lea    0x10(%rdx),%eax
    shr    %edx
    cmp    %eax,%edi
    jb     0x691 <var_0+273>
    sub    %eax,%edi
    add    $0x10,%edx
    lea    0x4(%rdx),%eax
    shr    %edx
    cmp    %eax,%edi
    jb     0x69f <var_0+287>
    sub    %eax,%edi
    add    $0x4,%edx
    mov    %edx,%eax
    add    $0x1,%edx
    shr    %eax
    cmp    %edx,%edi
    sbb    $0xffffffff,%eax
    repz retq
    nopl   (%rax)
    sub    $0x40000000,%edi
    mov    $0x20000000,%edx
    jmpq   0x5ad <var_0+45>
    xor    %edx,%edx
    jmpq   0x5ad <var_0+45>
    ====== out =======
    ("f (Int32.of_int_exn 4)" 2)
    ("f (Int32.of_int_exn 3)" 1)
    ("f (Int32.of_int_exn 153)" 12) |}]
;;

let%expect_test "sqrt float" =
  let f =
    let open Function.Let_syntax in
    let%bind x = Type.float in
    return (Expr.sqrt_float x)
  in
  let%bind () =
    test f (fun f ->
        [ [%message (f 4.0 : float)]
        ; [%message (f 3.0 : float)]
        ; [%message (f 153.0 : float)]
        ])
  in
  [%expect
    {|
    ===== source =====
    #include "stdint.h"
    extern float var_0(float var_1) {
    float var_2 = sqrt(var_1);
    return var_2;
    }
    ====== asm =======
    pxor   %xmm2,%xmm2
    sqrtss %xmm0,%xmm1
    ucomiss %xmm0,%xmm2
    ja     0x621 <var_0+17>
    movaps %xmm1,%xmm0
    retq
    sub    $0x18,%rsp
    movss  %xmm1,0xc(%rsp)
    callq  0x510 <sqrtf@plt>
    movss  0xc(%rsp),%xmm1
    add    $0x18,%rsp
    movaps %xmm1,%xmm0
    retq
    ====== out =======
    ("f 4.0" 2)
    ("f 3.0" 1.7320507764816284)
    ("f 153.0" 12.369317054748535) |}]
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
    #include "stdint.h"
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
    #include "stdint.h"
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
    #include "stdint.h"
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
    #include "stdint.h"
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
    #include "stdint.h"
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

let%expect_test "int32 to float" =
  let f =
    let open Function.Let_syntax in
    let%bind x = Type.int32 in
    return (Expr.int32_to_float x)
  in
  let%bind () =
    test f (fun f ->
        [ [%message (f (Int32.of_int_exn 1) : float)]
        ; [%message (f (Int32.of_int_exn 3) : float)]
        ; [%message (f (Int32.of_int_exn (-3)) : float)]
        ; [%message (f (Int32.of_int_exn 0) : float)]
        ])
  in
  [%expect
    {|
    ===== source =====
    #include "stdint.h"
    extern float var_0(int32_t var_1) {
    float var_2 = (float) var_1;
    return var_2;
    }
    ====== asm =======
    pxor   %xmm0,%xmm0
    cvtsi2ss %edi,%xmm0
    retq
    ====== out =======
    ("f (Int32.of_int_exn 1)" 1)
    ("f (Int32.of_int_exn 3)" 3)
    ("f (Int32.of_int_exn (-3))" -3)
    ("f (Int32.of_int_exn 0)" 0) |}]
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
    #include "stdint.h"
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

let%expect_test "float to int32" =
  let f =
    let open Function.Let_syntax in
    let%bind x = Type.float in
    return (Expr.float_to_int32 x)
  in
  let%bind () =
    test f (fun f ->
        [ [%message (f 1.5 : int32)]
        ; [%message (f 3.0 : int32)]
        ; [%message (f (-1.3) : int32)]
        ; [%message (f 0.25 : int32)]
        ])
  in
  [%expect
    {|
    ===== source =====
    #include "stdint.h"
    extern int32_t var_0(float var_1) {
    int32_t var_2 = (int32_t) var_1;
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
    #include "stdint.h"
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
    #include "stdint.h"
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
    #include "stdint.h"
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
    #include "stdint.h"
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

let bigarray_to_list bigarray =
  let len = Bigarray.Array1.dim bigarray in
  let rec loop i = if i >= len then [] else bigarray.{i} :: loop (i + 1) in
  loop 0
;;

let%expect_test "range2" =
  let f =
    let open Function.Let_syntax in
    let%bind a = Type.float_array in
    let%bind y = Type.int in
    let open Expr in
    return
      (progn
         [ range2 ~width:(int_lit 5) ~height:(int_lit 5) ~f:(fun ~x ~y ~pos ->
               array_set a pos (Expr.int_to_float (Expr.add_int x y)))
         ]
         y)
  in
  let%bind () =
    test f (fun f ->
        let bigarray = Bigarray.Array1.create Bigarray.float32 Bigarray.C_layout 25 in
        Bigarray.Array1.fill bigarray 0.0;
        let _ = f (Ctypes.bigarray_start Ctypes.array1 bigarray) 0 in
        let list = bigarray_to_list bigarray in
        [ [%message (list : float list)] ])
  in
  [%expect
    {|
    ===== source =====
    #include "stdint.h"
    extern int var_0(float* var_1, int var_2) {
    int var_6 = 5;
    int var_7 = 5;

          int var_5 = 0;
          for (int var_3 = 0; var_3 < var_7; var_3++) {
              for (int var_4 = 0; var_4 < var_6; var_4++) {
        int var_9 = var_4 + var_3;
    float var_8 = (float) var_9;
    var_1[var_5] = var_8;

                  var_5++;
              }
          }
        return var_2;
    }
    ====== asm =======
    movaps 0x49(%rip),%xmm0        # 0x5d0
    mov    %esi,%eax
    movl   $0x41000000,0x60(%rdi)
    movups %xmm0,(%rdi)
    movaps 0x46(%rip),%xmm0        # 0x5e0
    movups %xmm0,0x10(%rdi)
    movaps 0x4b(%rip),%xmm0        # 0x5f0
    movups %xmm0,0x20(%rdi)
    movaps 0x50(%rip),%xmm0        # 0x600
    movups %xmm0,0x30(%rdi)
    movaps 0x55(%rip),%xmm0        # 0x610
    movups %xmm0,0x40(%rdi)
    movups %xmm0,0x50(%rdi)
    retq
    ====== out =======
    (list (0 1 2 3 4 1 2 3 4 5 2 3 4 5 6 3 4 5 6 7 4 5 6 7 8)) |}]
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
        Bigarray.Array1.fill bigarray 0.0;
        let _ = f (Ctypes.bigarray_start Ctypes.array1 bigarray) 1 in
        let _ = f (Ctypes.bigarray_start Ctypes.array1 bigarray) 2 in
        let _ = f (Ctypes.bigarray_start Ctypes.array1 bigarray) 3 in
        let _ = f (Ctypes.bigarray_start Ctypes.array1 bigarray) 4 in
        let _ = f (Ctypes.bigarray_start Ctypes.array1 bigarray) 5 in
        let list = bigarray_to_list bigarray |> Fn.flip List.take 6 in
        [ [%message (list : float list)] ])
  in
  [%expect
    {|
    ===== source =====
    #include "stdint.h"
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
