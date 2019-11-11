open! Core_kernel
open! Async
open Shared_types

type debug =
  { c_source : unit -> string
  ; asm_source : unit -> string Deferred.t
  }

let eval shape chunk =
  let compiled = Compile.compile shape in
  let f =
    let open Jitsy in
    let open Function.Let_syntax in
    let%bind x_offset = Type.int in
    let%bind y_offset = Type.int in
    let%bind array = Type.float_array in
    let%bind a = Type.int in
    let open Expr in
    let iwidth = int_lit (Chunk.width chunk) in
    let iheight = int_lit (Chunk.height chunk) in
    return
      (Expr.progn
         [ Expr.range2
             ~width:iwidth
             ~height:iheight
             ~f:(fun ~x ~y ~pos ->
               let x, y = int_to_float x, int_to_float y in
               let x =
                 x_offset
                 |> mul_int iwidth
                 |> int_to_float
                 |> add_float x
               in
               let y =
                 y_offset
                 |> mul_int iheight
                 |> int_to_float
                 |> add_float y
               in
               array_set array pos (compiled ~x ~y))
         ]
         a)
  in
  let%map fn, asm_source = Jitsy.Compile.jit f in
  let fn ~x ~y = fn x y in
  let debug =
    { c_source =
        (fun () ->
          let source, _name = Jitsy.Compile.compile f in
          source)
    ; asm_source
    }
  in
  let _ = Chunk.apply chunk ~f:fn in
  debug
;;

let test ?(print_source = false) ?(pos = 0, 0) shape =
  let x, y = pos in
  let chunk = Chunk.create ~width:88 ~height:88 ~x ~y in
  let%bind debug = eval shape chunk in
  let debug_c = debug.c_source () in
  let%bind _debug_asm = debug.asm_source () in
  if print_source
  then (
    print_endline "===== source =====";
    print_endline debug_c);
  print_endline "===== shape ======";
  return (Chunk.Debug.borders chunk)
;;

let%expect_test "circle" =
  let%bind () = test (Shape.circle ~x:0.0 ~y:0.0 ~r:44.0) in
  [%expect
    {|
      ===== shape ======
      ______________________-#####################
      ______________________######################
      ______________________######################
      ______________________######################
      ______________________######################
      ______________________######################
      ______________________######################
      _____________________#######################
      _____________________#######################
      _____________________#######################
      ____________________########################
      ____________________########################
      ___________________#########################
      __________________##########################
      _________________###########################
      _________________###########################
      ________________############################
      ______________##############################
      _____________###############################
      ____________################################
      __________##################################
      _______#####################################
      -###########################################
      ############################################
      ############################################
      ############################################
      ############################################
      ############################################
      ############################################
      ############################################
      ############################################
      ############################################
      ############################################
      ############################################
      ############################################
      ############################################
      ############################################
      ############################################
      ############################################
      ############################################
      ############################################
      ############################################
      ############################################
      ############################################ |}]
;;

let%expect_test "bigger circle" =
  let%bind () = test (Shape.circle ~x:0.0 ~y:0.0 ~r:88.0) in
  [%expect
    {|
      ===== shape ======
      ____________________________________________
      ____________________________________________
      ____________________________________________
      ____________________________________________
      ____________________________________________
      ____________________________________________
      ____________________________________________
      ____________________________________________
      ____________________________________________
      ____________________________________________
      ___________________________________________#
      ___________________________________________#
      ___________________________________________#
      ___________________________________________#
      __________________________________________##
      __________________________________________##
      _________________________________________###
      _________________________________________###
      _________________________________________###
      ________________________________________####
      ________________________________________####
      _______________________________________#####
      _______________________________________#####
      ______________________________________######
      _____________________________________#######
      _____________________________________#######
      ____________________________________########
      ___________________________________#########
      __________________________________##########
      __________________________________##########
      _________________________________###########
      ________________________________############
      _______________________________#############
      ______________________________##############
      ____________________________################
      ___________________________#################
      __________________________##################
      ________________________####################
      _______________________#####################
      _____________________#######################
      ___________________#########################
      ________________############################
      ______________##############################
      __________################################## |}]
;;

let%expect_test "union circle" =
  let%bind () =
    test
      (Shape.union
         [ Shape.circle ~x:0.0 ~y:0.0 ~r:44.0
         ; Shape.circle ~x:88.0 ~y:88.0 ~r:44.0
         ])
  in
  [%expect
    {|
    ===== shape ======
    ______________________-#####################
    ______________________######################
    ______________________######################
    ______________________######################
    ______________________######################
    ______________________######################
    ______________________######################
    _____________________#######################
    _____________________#######################
    _____________________#######################
    ____________________########################
    ____________________########################
    ___________________#########################
    __________________##########################
    _________________###########################
    _________________###########################
    ________________############################
    ______________##############################
    _____________###############################
    ____________################################
    __________##################################
    _______#####################################
    -###########################################
    ######################################______
    ###################################_________
    #################################___________
    ################################____________
    ###############################_____________
    #############################_______________
    ############################________________
    ############################________________
    ###########################_________________
    ##########################__________________
    #########################___________________
    #########################___________________
    ########################____________________
    ########################____________________
    ########################____________________
    #######################_____________________
    #######################_____________________
    #######################_____________________
    #######################_____________________
    #######################_____________________
    #######################_____________________ |}]
;;

let%expect_test "subtraction circle" =
  let%bind () =
    test
      (Shape.subtract
         (Shape.circle ~x:0.0 ~y:0.0 ~r:88.0)
         (Shape.circle ~x:0.0 ~y:0.0 ~r:44.0))
  in
  [%expect
    {|
    ===== shape ======
    ######################-_____________________
    ######################______________________
    ######################______________________
    ######################______________________
    ######################______________________
    ######################______________________
    ######################______________________
    #####################_______________________
    #####################_______________________
    #####################_______________________
    ####################_______________________#
    ####################_______________________#
    ###################________________________#
    ##################_________________________#
    #################_________________________##
    #################_________________________##
    ################_________________________###
    ##############___________________________###
    #############____________________________###
    ############____________________________####
    ##########______________________________####
    #######________________________________#####
    -______________________________________#####
    ______________________________________######
    _____________________________________#######
    _____________________________________#######
    ____________________________________########
    ___________________________________#########
    __________________________________##########
    __________________________________##########
    _________________________________###########
    ________________________________############
    _______________________________#############
    ______________________________##############
    ____________________________################
    ___________________________#################
    __________________________##################
    ________________________####################
    _______________________#####################
    _____________________#######################
    ___________________#########################
    ________________############################
    ______________##############################
    __________################################## |}]
;;

let%expect_test "subtraction circle (different position)" =
  let%bind () =
    test
      ~pos:(-1, -1)
      (Shape.subtract
         (Shape.circle ~x:0.0 ~y:0.0 ~r:88.0)
         (Shape.circle ~x:0.0 ~y:0.0 ~r:44.0))
  in
  [%expect
    {|
    ===== shape ======
    ############################################
    ###################################_________
    ###############################_____________
    #############################_______________
    ##########################__________________
    ########################____________________
    ######################______________________
    #####################_______________________
    ###################_________________________
    ##################__________________________
    #################___________________________
    ###############_____________________________
    ##############______________________________
    #############_______________________________
    ############________________________________
    ###########_________________________________
    ###########_________________________________
    ##########__________________________________
    #########___________________________________
    ########____________________________________
    ########____________________________________
    #######_____________________________________
    ######______________________________________
    ######________________________________######
    #####______________________________#########
    #####____________________________###########
    ####____________________________############
    ####___________________________#############
    ####_________________________###############
    ###_________________________################
    ###_________________________################
    ##_________________________#################
    ##________________________##################
    ##_______________________###################
    ##_______________________###################
    #_______________________####################
    #_______________________####################
    #_______________________####################
    #______________________#####################
    #______________________#####################
    #______________________#####################
    #______________________#####################
    #______________________#####################
    #______________________##################### |}]
;;

let%expect_test "subtraction circle (different position)" =
  let%bind () =
    test
      ~print_source:true
      ~pos:(0, -1)
      (Shape.subtract
         (Shape.circle ~x:0.0 ~y:0.0 ~r:88.0)
         (Shape.circle ~x:0.0 ~y:0.0 ~r:44.0))
  in
  [%expect
    {|
      ===== source =====
      #include "stdint.h"
      extern int var_0(int var_1, int var_2, float* var_3, int var_4) {
      int var_8 = 88;
      int var_9 = 88;

            int var_7 = 0;
            for (int var_5 = 0; var_5 < var_9; var_5++) {
                for (int var_6 = 0; var_6 < var_8; var_6++) {
          float var_16 = 0.000000;
      float var_18 = (float) var_6;
      int var_21 = 88;
      int var_20 = var_21 * var_1;
      float var_19 = (float) var_20;
      float var_17 = var_18 + var_19;
      float var_15 = var_16 - var_17;
      float var_14 = var_15 * var_15;
      float var_24 = 0.000000;
      float var_26 = (float) var_5;
      int var_29 = 88;
      int var_28 = var_29 * var_2;
      float var_27 = (float) var_28;
      float var_25 = var_26 + var_27;
      float var_23 = var_24 - var_25;
      float var_22 = var_23 * var_23;
      float var_13 = var_14 + var_22;
      float var_12 = sqrt(var_13);
      float var_30 = 88.000000;
      float var_11 = var_12 - var_30;
      float var_37 = 0.000000;
      float var_39 = (float) var_6;
      int var_42 = 88;
      int var_41 = var_42 * var_1;
      float var_40 = (float) var_41;
      float var_38 = var_39 + var_40;
      float var_36 = var_37 - var_38;
      float var_35 = var_36 * var_36;
      float var_45 = 0.000000;
      float var_47 = (float) var_5;
      int var_50 = 88;
      int var_49 = var_50 * var_2;
      float var_48 = (float) var_49;
      float var_46 = var_47 + var_48;
      float var_44 = var_45 - var_46;
      float var_43 = var_44 * var_44;
      float var_34 = var_35 + var_43;
      float var_33 = sqrt(var_34);
      float var_51 = 44.000000;
      float var_32 = var_33 - var_51;
      float var_31 = -var_32 ;
      float var_10 = (var_11 > var_31 ? var_11 : var_31);
      var_3[var_7] = var_10;

                    var_7++;
                }
            }
          return var_4;
      }
      ===== shape ======
      -###########################################
      __________##################################
      ______________##############################
      ________________############################
      ___________________#########################
      _____________________#######################
      _______________________#####################
      ________________________####################
      __________________________##################
      ___________________________#################
      ____________________________################
      ______________________________##############
      _______________________________#############
      ________________________________############
      _________________________________###########
      __________________________________##########
      __________________________________##########
      ___________________________________#########
      ____________________________________########
      _____________________________________#######
      _____________________________________#######
      ______________________________________######
      -______________________________________#####
      #######________________________________#####
      ##########______________________________####
      ############____________________________####
      #############____________________________###
      ##############___________________________###
      ################_________________________###
      #################_________________________##
      #################_________________________##
      ##################_________________________#
      ###################________________________#
      ####################_______________________#
      ####################_______________________#
      #####################_______________________
      #####################_______________________
      #####################_______________________
      ######################______________________
      ######################______________________
      ######################______________________
      ######################______________________
      ######################______________________
      ######################______________________ |}]
;;
