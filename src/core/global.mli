open Component_defs
open Game_state

type t = {
  window : Gfx.window;
  ctx : Gfx.context;

  mutable map : Map_handler.map;

  player1 : player;
  player2 : player;

  texture_handler : (Texture_kind.t, Texture.t) Hashtbl.t;

  mutable portal1: ((int * int) * portal) option;
  mutable portal2: ((int * int) * portal) option;

  mutable waiting : int;
  mutable state : Game_state.t
}

val set_game_state : Game_state.t -> unit
val get_game_state : unit -> Game_state.t

val get : unit -> t
val set : t -> unit
