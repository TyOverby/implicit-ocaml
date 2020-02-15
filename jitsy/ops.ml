open! Core_kernel

module Float = struct
  let ( + ) = Expr.add_float
  let ( - ) = Expr.sub_float
  let ( * ) = Expr.mul_float
  let ( / ) = Expr.div_float
  let min = Expr.min_float
  let max = Expr.max_float
  let sqrt = Expr.sqrt_float
  let square = Expr.square_float
  let const = Expr.float_lit
end

module Int = struct
  let ( + ) = Expr.add_int
  let ( - ) = Expr.sub_int
  let ( * ) = Expr.mul_int
  let ( / ) = Expr.div_int
end
