open Component_defs

type augment_type = 
| HP
| REGEN
| SHIELD
| BULLETSPEED
| ATKSPEED
| MS
| DMG 
| ARMOR
| BULLETSIZE
| REZ1
| REZ2

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

val kill_counter : int ref

val players_are_dead : bool ref

val chosen_option : bool option ref

val current_augments : (augment_type * augment_type) option ref

val new_augment_to_select : bool ref

val game_time_start : float ref

val start_pause_time : float ref

val start_menu_pause_time : float option ref