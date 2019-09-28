module M = Core_kernel.Unique_id.Int ()

type t = M.t

let create = M.create

module Table = M.Table
