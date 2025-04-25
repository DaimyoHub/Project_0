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