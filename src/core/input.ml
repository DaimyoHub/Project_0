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

  register "y" (fun () ->
    let p1 = player1 () in
    set_texture p1 Player_1_top;
    move p1 Cst.j1_v_up);

  register "h" (fun () ->
    let p1 = player1 () in
    set_texture p1 Player_1_bottom;
    move p1 Cst.j1_v_down);

  register "j" (fun () ->
    let p1 = player1 () in
    set_texture p1 Player_1_right;
    move p1 Cst.j1_v_right);

  register "t" (fun () -> Player.(jump (player1()) (Unix.gettimeofday ())));
  
  register "q" (fun () ->
    let p1 = player2 () in
    set_texture p1 Player_2_left;
    move p1 Cst.j1_v_left);

  register "d" (fun () ->
    let p1 = player2 () in
    set_texture p1 Player_2_right;
    move p1 Cst.j1_v_right);

  register "z" (fun () ->
    let p1 = player2 () in
    set_texture p1 Player_2_top;
    move p1 Cst.j1_v_up);

  register "s" (fun () ->
    let p1 = player2 () in
    set_texture p1 Player_2_bottom;
    move p1 Cst.j1_v_down);

  register "a" (fun () -> Player.(jump (player2()) (Unix.gettimeofday ())));
