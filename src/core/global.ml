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
let state = ref None

let get () : t =
  match !state with
    None -> failwith "Uninitialized global state"
  | Some s -> s

let get_game_state () =
  let context = get () in context.state

let set_game_state game_state =
  let context = get () in context.state <- game_state

let set s = state := Some s

let kill_counter = ref 0

let players_are_dead = ref false

let chosen_option = ref None

let current_augments = ref None

let new_augment_to_select = ref false

let game_time_start = ref (Unix.gettimeofday ())

let start_pause_time = ref 0.

let start_menu_pause_time = ref None