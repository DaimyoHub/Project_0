open System_defs

let key_table = Hashtbl.create 16
let has_key s = Hashtbl.mem key_table s
let set_key s= Hashtbl.replace key_table s ()
let unset_key s = Hashtbl.remove key_table s

let action_table = Hashtbl.create 16
let register key action = Hashtbl.replace action_table key action

let handle_input () =
  let () =
    match Gfx.poll_event () with
      KeyDown s -> set_key s
    | KeyUp s -> unset_key s
    | Quit -> exit 0
    | _ -> ()
  in
  Hashtbl.iter (fun key action ->
      if has_key key then action ()) action_table

let () =
  let open Player in
  let open Texture_kind in

  register "m" (fun () -> Global.set_game_state Game_state.Menu);
  register "p" (fun () -> Global.set_game_state Game_state.Game);

  register "z" (fun () ->
    let p = player1 () in
    set_texture p Player_1_top;
    move p Cst.j1_v_up);

  register "s" (fun () ->
    let p = player1 () in
    set_texture p Player_1_bottom;
    move p Cst.j1_v_down);

  register "d" (fun () ->
    let p = player1 () in
    set_texture p Player_1_right;
    move p Cst.j1_v_right);

  register "q" (fun () ->
    let p = player1 () in
    set_texture p Player_1_left;
    move p Cst.j1_v_left);

  register "w" (fun () ->
    let open Player in
    let glb = Global.get () in
    match get_focused_map_pixel (player1 ()) glb.map with
    | Some ((i, j), map_pixel) -> 
        Portal.create_or_move_portal1 (i, j) map_pixel
    | None -> ());

  register "t" (fun () -> Player.(jump (player1()) (Unix.gettimeofday ())));
  
  register "j" (fun () ->
    let p = player2 () in
    set_texture p Player_2_left;
    move p Cst.j1_v_left);

  register "l" (fun () ->
    let p = player2 () in
    set_texture p Player_2_right;
    move p Cst.j1_v_right);

  register "i" (fun () ->
    let p = player2 () in
    set_texture p Player_2_top;
    move p Cst.j1_v_up);

  register "k" (fun () ->
    let p = player2 () in
    set_texture p Player_2_bottom;
    move p Cst.j1_v_down);

  register "n" (fun () ->
    let open Player in
    let glb = Global.get () in
    match get_focused_map_pixel (player2 ()) glb.map with
    | Some ((i, j), map_pixel) -> 
        Portal.create_or_move_portal2 (i, j) map_pixel
    | None -> ());

  register "e" (fun () -> Gfx.debug "bullet throwing not implemented%!\n");

  register "a" (fun () -> Player.(jump (player2()) (Unix.gettimeofday ())));
