module M = Core.Unique_id.Int ()

type t = M.t

let create = M.create

module Table = M.Table
