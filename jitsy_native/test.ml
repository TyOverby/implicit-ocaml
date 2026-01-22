open Core
open Async
open Jitsy

module Exploration = struct
  let%expect_test "" =
    let open Ctypes in
    print_endline (string_of_typ int);
    [%expect "int"];
    return ()
  ;;
end

let test f g =
  let%bind f, { Compile.Debug.c_source; asm_source } =
    Compile.jit (module Shared_types.Profile.Noop) f
  in
  print_endline "===== source =====";
  print_endline c_source;
  print_endline "====== asm =======";
  let%bind disas = asm_source () in
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
    #include <math.h>
    extern int var_0(_Bool var_1, int var_2, int var_3) {
    int var_4 = var_1 ? var_2 : var_3;
    return var_4;
    }
    ====== asm =======
    endbr64
    test   %dil,%dil
    mov    %esi,%eax
    cmove  %edx,%eax
    ret
    ====== out =======
    ("f true 3 5" 3)
    ("f false 3 5" 5)
    ("f true 1 2" 1)
    |}];
  return ()
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
    #include <math.h>
    extern _Bool var_0(int var_1, int var_2) {
    _Bool var_3 = var_1 == var_2;
    return var_3;
    }
    ====== asm =======
    endbr64
    cmp    %esi,%edi
    sete   %al
    ret
    ====== out =======
    ("f 3 5" false)
    ("f 3 3" true)
    ("f 5 5" true)
    |}];
  return ()
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
    #include <math.h>
    extern int var_0(int var_1) {
    int var_2 = 5;
    return var_2;
    }
    ====== asm =======
    endbr64
    mov    $0x5,%eax
    ret
    ====== out =======
    ("f 0" 5)
    |}];
  return ()
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
    #include <math.h>
    extern int var_0(int var_1) {
    return var_1;
    }
    ====== asm =======
    endbr64
    mov    %edi,%eax
    ret
    ====== out =======
    ("f 0" 0)
    ("f 1" 1)
    ("f (-2)" -2)
    ("f 4" 4)
    |}];
  return ()
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
    #include <math.h>
    extern float var_0(float var_1) {
    return var_1;
    }
    ====== asm =======
    endbr64
    ret
    ====== out =======
    ("f 0.9" 0.89999997615814209)
    ("f 1.0" 1)
    ("f (-2.55)" -2.5499999523162842)
    ("f 999.00" 999)
    |}];
  return ()
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
    #include <math.h>
    extern float var_0(float var_1) {
    return var_1;
    }
    ====== asm =======
    endbr64
    ret
    ====== out =======
    ("f 0.9" 0.89999997615814209)
    ("f 1.0" 1)
    ("f (-2.55)" -2.5499999523162842)
    ("f 999.00" 999)
    |}];
  return ()
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
    #include <math.h>
    extern float var_0(int var_1) {
    float var_2 = 5.000000;
    return var_2;
    }
    ====== asm =======
    endbr64
    movss  0xef4(%rip),%xmm0        # 0x2000
    ret
    ====== out =======
    ("f 0" 5)
    |}];
  return ()
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
    #include <math.h>
    extern _Bool var_0(int var_1) {
    _Bool var_2 = 1;
    return var_2;
    }
    ====== asm =======
    endbr64
    mov    $0x1,%eax
    ret
    ====== out =======
    ("f 0" true)
    |}];
  return ()
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
    #include <math.h>
    extern _Bool var_0(int var_1) {
    _Bool var_2 = 0;
    return var_2;
    }
    ====== asm =======
    endbr64
    xor    %eax,%eax
    ret
    ====== out =======
    ("f 0" false)
    |}];
  return ()
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
    #include <math.h>
    extern _Bool var_0(int var_1) {
    _Bool var_2 = 1;
    return var_2;
    }
    ====== asm =======
    endbr64
    mov    $0x1,%eax
    ret
    ====== out =======
    ("f 0" true)
    |}];
  return ()
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
    #include <math.h>
    extern int var_0(int var_1, int var_2) {
    int var_3 = var_1 + var_2;
    return var_3;
    }
    ====== asm =======
    endbr64
    lea    (%rdi,%rsi,1),%eax
    ret
    ====== out =======
    ("f 1 3" 4)
    ("f 3 4" 7)
    ("f (-3) 3" 0)
    |}];
  return ()
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
    #include <math.h>
    extern int32_t var_0(int32_t var_1, int32_t var_2) {
    int32_t var_3 = var_1 + var_2;
    return var_3;
    }
    ====== asm =======
    endbr64
    lea    (%rdi,%rsi,1),%eax
    ret
    ====== out =======
    ("f (of_int_exn 1) (of_int_exn 3)" 4)
    ("f (of_int_exn 3) (of_int_exn 4)" 7)
    |}];
  return ()
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
    #include <math.h>
    extern int32_t var_0(int32_t var_1, int32_t var_2) {
    int32_t var_3 = var_1 * var_2;
    return var_3;
    }
    ====== asm =======
    endbr64
    mov    %edi,%eax
    imul   %esi,%eax
    ret
    ====== out =======
    ("f (of_int_exn 1) (of_int_exn 3)" 3)
    ("f (of_int_exn 3) (of_int_exn 4)" 12)
    |}];
  return ()
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
    #include <math.h>
    extern int32_t var_0(int32_t var_1, int32_t var_2) {
    int32_t var_3 = var_1 / var_2;
    return var_3;
    }
    ====== asm =======
    endbr64
    mov    %edi,%eax
    cltd
    idiv   %esi
    ret
    ====== out =======
    ("f (of_int_exn 6) (of_int_exn 3)" 2)
    ("f (of_int_exn 123) (of_int_exn 4)" 30)
    ("f (of_int_exn 3) (of_int_exn 3)" 1)
    |}];
  return ()
;;

let%expect_test "sqrt sqrt int32" =
  let f =
    let open Function.Let_syntax in
    let%bind x = Type.int32 in
    return (Expr.sqrt_int32 (Expr.sqrt_int32 x))
  in
  let%bind () =
    test f (fun f -> [ [%message (f (Int32.of_int_exn 16) : int32)] ])
  in
  [%expect
    {|
    ===== source =====
    #include "stdint.h"
    #include <math.h>
    extern int32_t var_0(int32_t var_1) {

            int32_t var_4 = 0;
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

            int32_t var_5 = 0;
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
    endbr64
    xor    %eax,%eax
    test   %edi,%edi
    jle    0x12be <var_0+446>
    mov    %edi,%eax
    cmp    $0x3fffffff,%edi
    ja     0x12c0 <var_0+448>
    cmp    $0xfffffff,%edi
    jbe    0x12e6 <var_0+486>
    sub    $0x10000000,%eax
    mov    $0x10000000,%edx
    lea    0x4000000(%rdx),%ecx
    shr    $1,%edx
    cmp    %ecx,%eax
    jb     0x1146 <var_0+70>
    sub    %ecx,%eax
    add    $0x4000000,%edx
    lea    0x1000000(%rdx),%ecx
    shr    $1,%edx
    cmp    %ecx,%eax
    jb     0x115a <var_0+90>
    sub    %ecx,%eax
    add    $0x1000000,%edx
    lea    0x400000(%rdx),%ecx
    shr    $1,%edx
    cmp    %ecx,%eax
    jb     0x116e <var_0+110>
    sub    %ecx,%eax
    add    $0x400000,%edx
    lea    0x100000(%rdx),%ecx
    shr    $1,%edx
    cmp    %ecx,%eax
    jb     0x1182 <var_0+130>
    sub    %ecx,%eax
    add    $0x100000,%edx
    lea    0x40000(%rdx),%ecx
    shr    $1,%edx
    cmp    %ecx,%eax
    jb     0x1196 <var_0+150>
    sub    %ecx,%eax
    add    $0x40000,%edx
    lea    0x10000(%rdx),%ecx
    shr    $1,%edx
    cmp    %ecx,%eax
    jb     0x11aa <var_0+170>
    sub    %ecx,%eax
    add    $0x10000,%edx
    lea    0x4000(%rdx),%ecx
    shr    $1,%edx
    cmp    %ecx,%eax
    jb     0x11be <var_0+190>
    sub    %ecx,%eax
    add    $0x4000,%edx
    lea    0x1000(%rdx),%ecx
    shr    $1,%edx
    cmp    %ecx,%eax
    jb     0x11d2 <var_0+210>
    sub    %ecx,%eax
    add    $0x1000,%edx
    lea    0x400(%rdx),%ecx
    shr    $1,%edx
    cmp    %ecx,%eax
    jb     0x11e6 <var_0+230>
    sub    %ecx,%eax
    add    $0x400,%edx
    lea    0x100(%rdx),%ecx
    shr    $1,%edx
    cmp    %ecx,%eax
    jb     0x11fa <var_0+250>
    sub    %ecx,%eax
    add    $0x100,%edx
    lea    0x40(%rdx),%ecx
    shr    $1,%edx
    cmp    %ecx,%eax
    jb     0x1208 <var_0+264>
    sub    %ecx,%eax
    add    $0x40,%edx
    lea    0x10(%rdx),%ecx
    shr    $1,%edx
    cmp    %ecx,%eax
    jb     0x1216 <var_0+278>
    sub    %ecx,%eax
    add    $0x10,%edx
    mov    %edx,%ecx
    lea    0x4(%rdx),%esi
    shr    $0x2,%edx
    shr    $1,%ecx
    cmp    %esi,%eax
    jb     0x12d0 <var_0+464>
    add    $0x5,%ecx
    sub    %esi,%eax
    add    $0x2,%edx
    cmp    %ecx,%eax
    jb     0x1237 <var_0+311>
    add    $0x1,%edx
    xor    %ecx,%ecx
    cmp    $0x3fff,%edx
    jbe    0x124c <var_0+332>
    sub    $0x4000,%edx
    mov    $0x4000,%ecx
    lea    0x1000(%rcx),%eax
    shr    $1,%ecx
    cmp    %eax,%edx
    jb     0x1260 <var_0+352>
    sub    %eax,%edx
    add    $0x1000,%ecx
    lea    0x400(%rcx),%eax
    shr    $1,%ecx
    cmp    %eax,%edx
    jb     0x1274 <var_0+372>
    sub    %eax,%edx
    add    $0x400,%ecx
    lea    0x100(%rcx),%eax
    shr    $1,%ecx
    cmp    %eax,%edx
    jb     0x1288 <var_0+392>
    sub    %eax,%edx
    add    $0x100,%ecx
    lea    0x40(%rcx),%eax
    shr    $1,%ecx
    cmp    %eax,%edx
    jb     0x1296 <var_0+406>
    sub    %eax,%edx
    add    $0x40,%ecx
    lea    0x10(%rcx),%eax
    shr    $1,%ecx
    cmp    %eax,%edx
    jb     0x12a4 <var_0+420>
    sub    %eax,%edx
    add    $0x10,%ecx
    lea    0x4(%rcx),%eax
    shr    $1,%ecx
    cmp    %eax,%edx
    jb     0x12b2 <var_0+434>
    sub    %eax,%edx
    add    $0x4,%ecx
    mov    %ecx,%eax
    add    $0x1,%ecx
    shr    $1,%eax
    cmp    %ecx,%edx
    sbb    $0xffffffff,%eax
    ret
    nop
    sub    $0x40000000,%eax
    mov    $0x20000000,%edx
    jmp    0x1132 <var_0+50>
    nop
    add    $0x1,%ecx
    cmp    %ecx,%eax
    jae    0x1234 <var_0+308>
    xor    %eax,%eax
    test   %edx,%edx
    jne    0x1237 <var_0+311>
    ret
    xor    %edx,%edx
    jmp    0x1132 <var_0+50>
    End of assembler dump.
    ====== out =======
    ("f (Int32.of_int_exn 16)" 2)
    |}];
  return ()
;;

let%expect_test "sqrt int32" =
  let f =
    let open Function.Let_syntax in
    let%bind x = Type.int32 in
    return (Expr.sqrt_int32 x)
  in
  let%bind () =
    test f (fun f ->
      [ [%message (f (Int32.of_int_exn 0) : int32)]
      ; [%message (f (Int32.of_int_exn 4) : int32)]
      ; [%message (f (Int32.of_int_exn 3) : int32)]
      ; [%message (f (Int32.of_int_exn 153) : int32)]
      ])
  in
  [%expect
    {|
    ===== source =====
    #include "stdint.h"
    #include <math.h>
    extern int32_t var_0(int32_t var_1) {

            int32_t var_3 = 0;
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
    endbr64
    xor    %eax,%eax
    test   %edi,%edi
    jle    0x1231 <var_0+305>
    mov    %edi,%ecx
    cmp    $0x3fffffff,%edi
    ja     0x1238 <var_0+312>
    cmp    $0xfffffff,%edi
    jbe    0x1248 <var_0+328>
    sub    $0x10000000,%ecx
    mov    $0x10000000,%edx
    lea    0x4000000(%rdx),%eax
    shr    $1,%edx
    cmp    %eax,%ecx
    jb     0x1147 <var_0+71>
    sub    %eax,%ecx
    add    $0x4000000,%edx
    lea    0x1000000(%rdx),%eax
    shr    $1,%edx
    cmp    %eax,%ecx
    jb     0x115b <var_0+91>
    sub    %eax,%ecx
    add    $0x1000000,%edx
    lea    0x400000(%rdx),%eax
    shr    $1,%edx
    cmp    %eax,%ecx
    jb     0x116f <var_0+111>
    sub    %eax,%ecx
    add    $0x400000,%edx
    lea    0x100000(%rdx),%eax
    shr    $1,%edx
    cmp    %eax,%ecx
    jb     0x1183 <var_0+131>
    sub    %eax,%ecx
    add    $0x100000,%edx
    lea    0x40000(%rdx),%eax
    shr    $1,%edx
    cmp    %eax,%ecx
    jb     0x1197 <var_0+151>
    sub    %eax,%ecx
    add    $0x40000,%edx
    lea    0x10000(%rdx),%eax
    shr    $1,%edx
    cmp    %eax,%ecx
    jb     0x11ab <var_0+171>
    sub    %eax,%ecx
    add    $0x10000,%edx
    lea    0x4000(%rdx),%eax
    shr    $1,%edx
    cmp    %eax,%ecx
    jb     0x11bf <var_0+191>
    sub    %eax,%ecx
    add    $0x4000,%edx
    lea    0x1000(%rdx),%eax
    shr    $1,%edx
    cmp    %eax,%ecx
    jb     0x11d3 <var_0+211>
    sub    %eax,%ecx
    add    $0x1000,%edx
    lea    0x400(%rdx),%eax
    shr    $1,%edx
    cmp    %eax,%ecx
    jb     0x11e7 <var_0+231>
    sub    %eax,%ecx
    add    $0x400,%edx
    lea    0x100(%rdx),%eax
    shr    $1,%edx
    cmp    %eax,%ecx
    jb     0x11fb <var_0+251>
    sub    %eax,%ecx
    add    $0x100,%edx
    lea    0x40(%rdx),%eax
    shr    $1,%edx
    cmp    %eax,%ecx
    jb     0x1209 <var_0+265>
    sub    %eax,%ecx
    add    $0x40,%edx
    lea    0x10(%rdx),%eax
    shr    $1,%edx
    cmp    %eax,%ecx
    jb     0x1217 <var_0+279>
    sub    %eax,%ecx
    add    $0x10,%edx
    lea    0x4(%rdx),%eax
    shr    $1,%edx
    cmp    %eax,%ecx
    jb     0x1225 <var_0+293>
    sub    %eax,%ecx
    add    $0x4,%edx
    mov    %edx,%eax
    add    $0x1,%edx
    shr    $1,%eax
    cmp    %edx,%ecx
    sbb    $0xffffffff,%eax
    ret
    nopw   0x0(%rax,%rax,1)
    sub    $0x40000000,%ecx
    mov    $0x20000000,%edx
    jmp    0x1133 <var_0+51>
    xor    %edx,%edx
    jmp    0x1133 <var_0+51>
    End of assembler dump.
    ====== out =======
    ("f (Int32.of_int_exn 0)" 0)
    ("f (Int32.of_int_exn 4)" 2)
    ("f (Int32.of_int_exn 3)" 1)
    ("f (Int32.of_int_exn 153)" 12)
    |}];
  return ()
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
    #include <math.h>
    extern float var_0(float var_1) {
    float var_2 = sqrt(var_1);
    return var_2;
    }
    ====== asm =======
    endbr64
    pxor   %xmm1,%xmm1
    ucomiss %xmm0,%xmm1
    ja     0x1132 <var_0+18>
    sqrtss %xmm0,%xmm0
    ret
    jmp    0x1050 <sqrtf@plt>
    ====== out =======
    ("f 4.0" 2)
    ("f 3.0" 1.7320507764816284)
    ("f 153.0" 12.369317054748535)
    |}];
  return ()
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
    #include <math.h>
    extern float var_0(float var_1, float var_2) {
    float var_3 = var_1 + var_2;
    return var_3;
    }
    ====== asm =======
    endbr64
    addss  %xmm1,%xmm0
    ret
    ====== out =======
    ("f 1.0 3.0" 4)
    ("f 3.0 4.0" 7)
    ("f (-3.0) 3.0" 0)
    |}];
  return ()
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
    #include <math.h>
    extern float var_0(float var_1, float var_2) {
    float var_3 = var_1 - var_2;
    return var_3;
    }
    ====== asm =======
    endbr64
    subss  %xmm1,%xmm0
    ret
    ====== out =======
    ("f 1.0 3.0" -2)
    ("f 3.0 4.0" -1)
    ("f (-3.0) 3.0" -6)
    |}];
  return ()
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
    #include <math.h>
    extern float var_0(float var_1, float var_2) {
    float var_3 = var_1 * var_2;
    return var_3;
    }
    ====== asm =======
    endbr64
    mulss  %xmm1,%xmm0
    ret
    ====== out =======
    ("f 1.0 3.0" 3)
    ("f 3.0 4.0" 12)
    ("f (-3.0) 3.0" -9)
    |}];
  return ()
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
    #include <math.h>
    extern float var_0(float var_1, float var_2) {
    float var_3 = var_1 / var_2;
    return var_3;
    }
    ====== asm =======
    endbr64
    divss  %xmm1,%xmm0
    ret
    ====== out =======
    ("f 1.0 3.0" 0.3333333432674408)
    ("f 3.0 4.0" 0.75)
    ("f (-3.0) 3.0" -1)
    |}];
  return ()
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
    #include <math.h>
    extern _Bool var_0(int var_1, int var_2) {
    _Bool var_3 = var_1 == var_2;
    return var_3;
    }
    ====== asm =======
    endbr64
    cmp    %esi,%edi
    sete   %al
    ret
    ====== out =======
    ("f 1 1" true)
    ("f 3 4" false)
    ("f 0 0" true)
    |}];
  return ()
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
    #include <math.h>
    extern float var_0(int32_t var_1) {
    float var_2 = (float) var_1;
    return var_2;
    }
    ====== asm =======
    endbr64
    pxor   %xmm0,%xmm0
    cvtsi2ss %edi,%xmm0
    ret
    ====== out =======
    ("f (Int32.of_int_exn 1)" 1)
    ("f (Int32.of_int_exn 3)" 3)
    ("f (Int32.of_int_exn (-3))" -3)
    ("f (Int32.of_int_exn 0)" 0)
    |}];
  return ()
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
    #include <math.h>
    extern float var_0(int var_1) {
    float var_2 = (float) var_1;
    return var_2;
    }
    ====== asm =======
    endbr64
    pxor   %xmm0,%xmm0
    cvtsi2ss %edi,%xmm0
    ret
    ====== out =======
    ("f 1" 1)
    ("f 3" 3)
    ("f (-3)" -3)
    ("f 0" 0)
    |}];
  return ()
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
    #include <math.h>
    extern int32_t var_0(float var_1) {
    int32_t var_2 = (int32_t) var_1;
    return var_2;
    }
    ====== asm =======
    endbr64
    cvttss2si %xmm0,%eax
    ret
    ====== out =======
    ("f 1.5" 1)
    ("f 3.0" 3)
    ("f (-1.3)" -1)
    ("f 0.25" 0)
    |}];
  return ()
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
    #include <math.h>
    extern int var_0(float var_1) {
    int var_2 = (int) var_1;
    return var_2;
    }
    ====== asm =======
    endbr64
    cvttss2si %xmm0,%eax
    ret
    ====== out =======
    ("f 1.5" 1)
    ("f 3.0" 3)
    ("f (-1.3)" -1)
    ("f 0.25" 0)
    |}];
  return ()
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
    #include <math.h>
    extern int var_0(int var_1, int var_2) {
    int var_3 = var_1 - var_2;
    return var_3;
    }
    ====== asm =======
    endbr64
    mov    %edi,%eax
    sub    %esi,%eax
    ret
    ====== out =======
    ("f 1 3" -2)
    ("f 3 4" -1)
    ("f (-3) 3" -6)
    |}];
  return ()
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
    #include <math.h>
    extern int var_0(int var_1, int var_2) {
    int var_3 = var_1 * var_2;
    return var_3;
    }
    ====== asm =======
    endbr64
    mov    %edi,%eax
    imul   %esi,%eax
    ret
    ====== out =======
    ("f 1 3" 3)
    ("f 3 4" 12)
    ("f (-3) 3" -9)
    |}];
  return ()
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
    #include <math.h>
    extern int var_0(int var_1, int var_2) {
    int var_3 = var_1 / var_2;
    return var_3;
    }
    ====== asm =======
    endbr64
    mov    %edi,%eax
    cltd
    idiv   %esi
    ret
    ====== out =======
    ("f 6 3" 2)
    ("f (-123) 4" -30)
    ("f (-3) 3" -1)
    |}];
  return ()
;;

let bigarray_to_list bigarray =
  let len = Bigarray.Array1.dim bigarray in
  let rec loop i =
    if i >= len then [] else bigarray.{i} :: loop (i + 1)
  in
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
         [ range2
             ~width:(int_lit 5)
             ~height:(int_lit 5)
             ~f:(fun ~x ~y ~pos ->
               array_set a pos (Expr.int_to_float (Expr.add_int x y)))
         ]
         y)
  in
  let%bind () =
    test f (fun f ->
      let bigarray =
        Bigarray.Array1.create Bigarray.float32 Bigarray.C_layout 25
      in
      Bigarray.Array1.fill bigarray 0.0;
      let ptr = Ctypes.bigarray_start Ctypes.array1 bigarray in
      let (_ : int) = f (Obj.magic ptr) 0 in
      let list = bigarray_to_list bigarray in
      [ [%message (list : float list)] ])
  in
  [%expect
    {|
    ===== source =====
    #include "stdint.h"
    #include <math.h>
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
    endbr64
    mov    0xef5(%rip),%rax        # 0x2000
    mov    0xef6(%rip),%rdx        # 0x2008
    movl   $0x41000000,0x60(%rdi)
    movaps 0xf00(%rip),%xmm0        # 0x2020
    mov    %rax,(%rdi)
    mov    0xee6(%rip),%rax        # 0x2010
    mov    %rdx,0x8(%rdi)
    mov    %rax,0x10(%rdi)
    mov    0xee7(%rip),%rax        # 0x2020
    mov    %rdx,0x18(%rdi)
    mov    %rax,0x20(%rdi)
    mov    %rdx,0x28(%rdi)
    mov    0xecc(%rip),%rdx        # 0x2018
    mov    %rax,0x30(%rdi)
    mov    %rax,0x40(%rdi)
    mov    0xecd(%rip),%rax        # 0x2028
    mov    %rdx,0x38(%rdi)
    mov    %rax,0x48(%rdi)
    mov    %esi,%eax
    movups %xmm0,0x50(%rdi)
    ret
    ====== out =======
    (list (0 1 2 3 4 1 2 3 4 5 2 3 4 5 6 3 4 5 6 7 4 5 6 7 8))
    |}];
  return ()
;;

let%expect_test "big-array" =
  let f =
    let open Function.Let_syntax in
    let%bind a = Type.float_array in
    let%bind y = Type.int in
    return
      (Expr.progn
         [ Expr.array_set
             a
             y
             (Expr.div_float
                (Expr.int_to_float y)
                (Expr.float_lit 2.0))
         ]
         y)
  in
  let%bind () =
    test f (fun f ->
      let bigarray =
        Bigarray.Array1.create Bigarray.float32 Bigarray.C_layout 10
      in
      Bigarray.Array1.fill bigarray 0.0;
      let ptr = Ctypes.bigarray_start Ctypes.array1 bigarray in
      let ptr2 = Obj.magic ptr in
      let (_ : int) = f ptr2 1 in
      let (_ : int) = f ptr2 2 in
      let (_ : int) = f ptr2 3 in
      let (_ : int) = f ptr2 4 in
      let (_ : int) = f ptr2 5 in
      let list = bigarray_to_list bigarray |> Fn.flip List.take 6 in
      [ [%message (list : float list)] ])
  in
  [%expect
    {|
    ===== source =====
    #include "stdint.h"
    #include <math.h>
    extern int var_0(float* var_1, int var_2) {
    float var_4 = (float) var_2;
    float var_5 = 2.000000;
    float var_3 = var_4 / var_5;
    var_1[var_2] = var_3;
    return var_2;
    }
    ====== asm =======
    endbr64
    movslq %esi,%rdx
    pxor   %xmm0,%xmm0
    cvtsi2ss %edx,%xmm0
    mulss  0xee9(%rip),%xmm0        # 0x2000
    mov    %rdx,%rax
    movss  %xmm0,(%rdi,%rdx,4)
    ret
    ====== out =======
    (list (0 0.5 1 1.5 2 2.5))
    |}];
  return ()
;;
