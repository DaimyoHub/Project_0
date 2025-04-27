open System_defs

let key_table = Hashtbl.create 16
let has_key s = Hashtbl.mem key_table s
let set_key s= Hashtbl.replace key_table s ()
let unset_key s = Hashtbl.remove key_table s

let action_table = Hashtbl.create 16
let register key action = Hashtbl.replace action_table key action
let unregister key = Hashtbl.remove action_table key

let register_player first_player =
  let open Player in
  let open Texture in

  if first_player then 
  (
    register "z" (fun () ->
      let p = player1 () in
      move p (Vector.mult p#get_ms Cst.j1_v_up);
      set_texture p Player_1_top);
  
    register "s" (fun () ->
      let p = player1 () in
      move p (Vector.mult p#get_ms Cst.j1_v_down);
      set_texture p Player_1_bottom);
  
    register "d" (fun () ->
      let p = player1 () in
      move p (Vector.mult p#get_ms Cst.j1_v_right);
      set_texture p Player_1_right);
  
    register "q" (fun () ->
      let p = player1 () in
      move p (Vector.mult p#get_ms Cst.j1_v_left);
      set_texture p Player_1_left);
  
    register "w" (fun () ->
      let open Player in
      let glb = Global.get () in
      match get_focused_map_pixel (player1 ()) glb.map with
      | Some ((i, j), map_pixel) -> 
          Portal.create_or_move_portal1 (i, j) map_pixel
      | None -> ());
  
    register "a" (fun () ->
      let p1 = Player.player1 () in
      Player.(jump p1 (Unix.gettimeofday ()));
      p1#incr_jumping_anim_counter);

    register "e" (fun () ->
      let p1 = Player.player1 () in
      if p1#can_shoot then begin
        Bullet.create p1 p1#getDmgPerBullet;
        p1#incr_shooting_counter
      end);

    register "_" (fun () ->
      let p1 = Player.player1 () in
      if not p1#is_melee_triggered && not p1#is_jumping then begin
        p1#incr_melee_counter
      end);
  )
  else 
  (
    register "j" (fun () ->
      let p = player2 () in
      set_texture p Player_2_left;
      move p (Vector.mult p#get_ms Cst.j1_v_left));
  
    register "l" (fun () ->
      let p = player2 () in
      set_texture p Player_2_right;
      move p (Vector.mult p#get_ms Cst.j1_v_right));
  
    register "i" (fun () ->
      let p = player2 () in
      set_texture p Player_2_top;
      move p (Vector.mult p#get_ms Cst.j1_v_up));
  
    register "k" (fun () ->
      let p = player2 () in
      set_texture p Player_2_bottom;
      move p (Vector.mult p#get_ms Cst.j1_v_down));
  
    register "n" (fun () ->
      let open Player in
      let glb = Global.get () in
      match get_focused_map_pixel (player2 ()) glb.map with
      | Some ((i, j), map_pixel) -> 
          Portal.create_or_move_portal2 (i, j) map_pixel
      | None -> ());
  
    register "o" (fun () ->
      let p2 = Player.player2 () in
      if p2#can_shoot then begin
        Bullet.create p2 p2#getDmgPerBullet;
        p2#incr_shooting_counter
      end);
  
    register "u" (fun () ->
      let p2 = Player.player2 () in
      Player.(jump p2 (Unix.gettimeofday ()));
      p2#incr_jumping_anim_counter;
      Player.set_texture p2 (Player.compute_jump_texture p2 0));  
  )
;;

let handle_input () =
  let () =
    match Gfx.poll_event () with
    | KeyDown s -> set_key s
    | KeyUp s -> unset_key s
    | Quit -> exit 0
    | _ -> ()
  in
  Hashtbl.iter (fun key action -> if has_key key then action ()) action_table

let () = 
  register_player true;
  register_player false;
  register "m" (fun () ->
    Global.start_menu_pause_time := Some (Unix.gettimeofday ());
    Global.set_game_state State.Menu_pause);
  register "p" (fun () ->
    match !Global.start_menu_pause_time with 
    | None -> ()
    | Some start_time -> (
    let pause_time = Unix.gettimeofday () -. start_time in 
    Global.game_time_start := !Global.game_time_start +. pause_time;
    Global.start_menu_pause_time := None;
    Global.set_game_state State.Game)
  );
