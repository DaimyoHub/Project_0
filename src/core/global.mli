open Component_defs
open Game_state

type t = {
  window : Gfx.window;
  ctx : Gfx.context;

  player1 : player;
  player2 : player;

  mutable waiting : int;
  mutable state : Game_state.t
}

val set_game_state : Game_state.t -> unit
val get_game_state : unit -> Game_state.t

val get : unit -> t
val set : t -> unit
