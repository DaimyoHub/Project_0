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
  register "m" (fun () -> Global.set_game_state Game_state.Menu);
  register "p" (fun () -> Global.set_game_state Game_state.Game);

  register "y" (fun () -> Player.(move (player1()) Cst.j1_v_up));
  register "h" (fun () -> Player.(move (player1()) Cst.j1_v_down));
  register "g" (fun () -> Player.(move (player1()) Cst.j1_v_left));
  register "j" (fun () -> Player.(move (player1()) Cst.j1_v_right));
  register "t" (fun () -> Player.(jump (player1()) (Unix.gettimeofday ())));
  
  register "z" (fun () -> Player.(move (player2()) Cst.j2_v_up));
  register "s" (fun () -> Player.(move (player2()) Cst.j2_v_down));
  register "q" (fun () -> Player.(move (player2()) Cst.j2_v_left));
  register "d" (fun () -> Player.(move (player2()) Cst.j2_v_right));
  register "a" (fun () -> Player.(jump (player2()) (Unix.gettimeofday ())));
