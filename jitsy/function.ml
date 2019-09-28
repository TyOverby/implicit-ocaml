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
  { expression; typ = typ.ctype @-> expr_typ; param_map }
;;

module Let_syntax = struct
  let return constant =
    { expression = constant
    ; typ = Ctypes.returning (Expr.typeof constant).ctype
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
