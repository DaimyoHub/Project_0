open Size

type level =
  | Top          (* point normal de la map *)
  | StartA       (* position de départ du joueur A *)
  | StartB       (* position de départ du joueur B *)
  | Up of level

let default_size = { x = 24; y = 24 }

let texture = Texture.red

