open Ecs
open Component_defs
open System_defs
open Tag

(**
   Player.create (idx, name, x, y, width, height)

   Crée un joueur avec le caractéristiques données en paramètre. Le joueur est
   enrigistré dans tous les systèmes.
 *)
let create (idx, name, x, y, width, height) =
  let open Tag in
  let e = new player name in

  e#tag#set (Player (idx, e));

  e#position#set Vector.{ x = float x; y = float y };

  e#box#set Rect.{width; height};

  e#velocity#set Vector.zero;

  e#resolve#set (fun _ t ->
    match t#tag#get with
    | HWall w -> (
        (if w#position#get.y <> 0. then
          e#position#set (Vector.sub e#position#get Cst.j1_v_down)
        else
          e#position#set (Vector.sub e#position#get Cst.j1_v_up));
          e#velocity#set Vector.zero)
    | VWall (_, w) -> (
        (if w#position#get.x <> 0. then
          e#position#set (Vector.sub e#position#get Cst.j1_v_right)
        else
          e#position#set (Vector.sub e#position#get Cst.j1_v_left));
          e#velocity#set Vector.zero)
    | Mappix pix -> (
        let z_pos = Option.value ~default: 1. pix#z_position#get in
        if z_pos > 0. then e#velocity#set Vector.zero)
    | Player (_, p) -> 
      (
        let eposX = e#position#get.x in
        let eposY = e#position#get.y in
        if (eposX>0. && eposX<(float_of_int Cst.window_width) &&
            eposY>0. && eposX<(float_of_int Cst.window_height)) then
          (
          let x_diff = eposX-.p#position#get.x in
          let y_diff = eposY-.p#position#get.y in
          let x_coll = abs_float(x_diff) > abs_float(y_diff) in
          if (x_diff = 0.) then
            (
              if (y_diff<0.) then 
                (e#position#set (Vector.sub e#position#get Cst.j1_v_down))
              else
                (e#position#set (Vector.sub e#position#get Cst.j1_v_up))
            )
          else if ( x_diff>0. && x_coll ) then
            (
              e#position#set (Vector.sub e#position#get Cst.j1_v_left)
            )
          else if ( x_coll ) then
            (
              e#position#set (Vector.sub e#position#get Cst.j1_v_right)
            )
          else if (y_diff>0.) then
            (
              e#position#set (Vector.sub e#position#get Cst.j1_v_down)
            )
          else
            (
              e#position#set (Vector.sub e#position#get Cst.j1_v_up)
            );
          
          e#velocity#set Vector.zero;
          p#velocity#set Vector.zero
        )
      )
    (*
      Code de la téléportation d'un portail à l'autre :
        - si le portail touché est le premier portail
          - si le deuxième portail existe, téléporter le joueur là-bas
          - sinon, ne rien faire
        - si le portail touché est le second, pareil que pour le premier
     *)
    | Portal (idx, (i, j), portal) ->
        let open Vector in
        let glb = Global.get () in
        if idx = One then (
          match glb.portal2 with
          | Some (_, portal2) ->
              let new_pos = add
                portal2#position#get
                (mult 24. (normalize e#velocity#get))
              in
              e#position#set new_pos
          | None -> ())
        else (
          match glb.portal1 with
          | Some (_, portal1) ->
              let new_pos = add
                portal1#position#get
                (mult 24. (normalize e#velocity#get))
              in
              e#position#set new_pos;
          | None -> ())
    | _ -> ());

  Draw_system.(register (e :> t));
  Collide_system.(register (e :> t));
  Move_system.(register (e :> t));
  Wind_system.(register (e :> t));
  e

(**
   Player.create_both map

   Creates both players of the game and places them at the convenient place :
   player1 should be placed on the pixel StartA and player2 on StartB.
 *)
let create_both map =
  let extract_player_spawn_pos (map : Map_handler.map) a_or_b =
    let res = ref Vector.zero in

    for i = 0 to map.size.x - 1 do
      for j = 0 to map.size.y - 1 do
        if Map_handler.is_pixel_of_kind map i j a_or_b then
          res := map.data.(i).(j)#position#get;
      done;
    done;

    !res
  in
          
  let p1 = extract_player_spawn_pos map Map_pixel.StartA
  and p2 = extract_player_spawn_pos map Map_pixel.StartB
  in
  create Cst.(One, "player1", int_of_float p1.x, int_of_float p1.y, j_width, j_height),
  create Cst.(Two, "player2", int_of_float p2.x, int_of_float p2.y, j_width, j_height)

let player1 () = (Global.get ()).player1
let player2 () = (Global.get ()).player2

let stop_players () = 
  let Global.{player1; player2; _ } = Global.get () in
  player1#velocity#set Vector.zero;
  player2#velocity#set Vector.zero

let move player v = player#velocity#set v

let set_texture player texture =
  let texture_handler = (Global.get ()).texture_handler in
  let texture = Option.value
    (Hashtbl.find_opt texture_handler texture)
    ~default: Texture.Raw.green
  in
  player#texture#set texture

(**
   Player.compute_texture player jumping_phase

   Computes the convenient texture of [player] according to the [jumping_phase]
   and the direction of [player]. The player can be preparing itself to jump
   (phase 0) or can be jumping (phase 1, 2, 3). The computed texture is the
   next texture that should be given to [player].
 *)
let compute_texture player jp =
  let open Texture in
  let is_one = 
    let compute = function Player (idx, _) -> idx = One | _ -> false
    in compute player#tag#get
  in
  let v = Vector.normalize player#velocity#get in

  if v.x = 0. then
    if v.y > 0. then
      if jp = 3 then
        if is_one then Player_1_bottom else Player_2_bottom
      else if jp = 2 || jp = 0 then
        if is_one then Player_1_bottom_jump_0 else Player_2_bottom_jump_0
      else (* if jp = 1 then *)
        if is_one then Player_1_bottom_jump_1 else Player_2_bottom_jump_1
    else
      if jp = 3 then
        if is_one then Player_1_top else Player_2_top
      else if jp = 2 || jp = 0 then
        if is_one then Player_1_top_jump_0 else Player_2_top_jump_0
      else (* if jp = 1 then *)
        if is_one then Player_1_top_jump_1 else Player_2_top_jump_1
  else
    if v.x > 0. then
      if jp = 3 then
        if is_one then Player_1_right else Player_2_right
      else if jp = 2 || jp = 0 then
        if is_one then Player_1_right_jump_0 else Player_2_right_jump_0
      else (* if jp = 1 then *)
        if is_one then Player_1_right_jump_1 else Player_2_right_jump_1
    else
      if jp = 3 then
        if is_one then Player_1_left else Player_2_left
      else if jp = 2 || jp = 0 then
        if is_one then Player_1_left_jump_0 else Player_2_left_jump_0
      else (* if jp = 1 then *)
        if is_one then Player_1_left_jump_1 else Player_2_left_jump_1
  
let jump player timeMilli =
  player#z_position#set (Some timeMilli);
  set_texture player (compute_texture player 0)

(**
   Player.get_focused_map_pixel player map

   The given [player] is able to place a portal in front of him. The pixel
   where his portal should be placed is computed according to [player]'s
   position and direction. In fact, it is the second pixel right in front of
   him.
 *)
let get_focused_map_pixel player map =
  let Vector.{ x; y } = player#position#get in

  let i, j =
    let v = Vector.(mult 2. (normalize player#velocity#get)) in
    int_of_float (x /. (float_of_int Map_pixel.default_size.x) -. 0.5 +. v.x),
    int_of_float (y /. (float_of_int Map_pixel.default_size.y) -. 0.5 +. v.y)
  in

  if Map_handler.is_position_in_bounds map i j && (i, j) <> (0, 0) then
    let pix = Map_handler.get_pixel map i j in

    let player_z_pos =
      let compute = function None -> 0 | Some i -> int_of_float i in
      compute player#z_position#get
    in
    let pixel_z_pos = Map_handler.int_of_level pix#get_level in

    if player_z_pos = pixel_z_pos then Some ((i, j), pix) else None
  else None

(**
   Player.set_focused_map_pixel ()

   Sets the texture of the focused pixel computed by the dedicated function.
 *)
let set_focused_map_pixel () =
  let glb = Global.get () in

  let open Texture in
  let focused_texture = Option.value
    (Hashtbl.find_opt (Global.get ()).texture_handler Texture.Focused_ground)
    ~default: Texture.Raw.green
  in

  glb.map <-
    Map_handler.iter_if glb.map
      (fun pix -> pix#texture#get = focused_texture) 
      (fun pix -> Map.set_map_pixel_texture glb.texture_handler pix);

  let set_focused_pixel_texture player =
    match get_focused_map_pixel player glb.map with
    | Some ((i, j), pix) -> pix#texture#set focused_texture
    | None -> ()
  in

  set_focused_pixel_texture (player1 ());
  set_focused_pixel_texture (player2 ())

(**
   Player.handle_jump_animation ()

   Handles the jumping animation of both players. It decides the phases of the
   jumping animation and sets the dedicated texture thanks to compute_texture.
 *)
let handle_jump_animation () =
  let inner player =
    if player#is_jumping then
      if player#get_jumping_anim_counter < 60 then (
        (if player#get_jumping_anim_counter = 20 then
          set_texture player (compute_texture player 1)
        else if player#get_jumping_anim_counter = 40 then
          set_texture player (compute_texture player 2));

        player#incr_jumping_anim_counter)
      else (
        player#reinit_jumping_anim_counter;
        set_texture player (compute_texture player 3))
    else ()
  in

  inner (player1 ());
  inner (player2 ())

(**
   Player.handle_shooting ()

   Handles the shooting phase of both players. In order not to make the game 
   crash, it is necessary to limit the number of shootings per second.
 *)
let handle_shooting () =
  let inner player =
    if player#get_shooting_counter < 20 then player#incr_shooting_counter
    else player#reinit_shooting_counter
  in

  inner (player1 ());
  inner (player2 ())

