type t = { x : float; y : float }

let add a b = { x = a.x +. b.x; y = a.y +. b.y }
let sub a b = { x = a.x -. b.x; y = a.y -. b.y }

let mult k a = { x = k*. a.x; y = k*. a.y }

let dot a b =  failwith "TODO 5.1"
let norm a = failwith "TODO 5.1"
let normalize a = failwith "TODO 5.1"
let pp fmt a = Format.fprintf fmt "(%f, %f)" a.x a.y

let zero = { x = 0.0; y = 0.0 }
let is_zero v = v.x = 0.0 && v.y = 0.0