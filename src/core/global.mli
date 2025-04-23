open Component_defs

type t = {
  window : Gfx.window;
  ctx : Gfx.context;

  mutable map : Map_handler.map;

  player1 : player;
  player2 : player;

  texture_handler : (Texture.kind, Texture.t) Hashtbl.t;

  mutable portal1: ((int * int) * portal) option;
  mutable portal2: ((int * int) * portal) option;

  mutable waiting : int;
  mutable state : State.t;

  particles: particle list;
}

val set_game_state : State.t -> unit
val get_game_state : unit -> State.t

val get : unit -> t
val set : t -> unit
