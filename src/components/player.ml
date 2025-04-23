open Ecs
open Component_defs
open System_defs
open Tag

let create (idx, name, x, y, width, height) =
  let open Tag in
  let e = new player name in
  e#tag#set (Player (idx, e)) ;
  e#position#set Vector.{x = float x; y = float y};
  e#box#set Rect.{width; height};
  e#velocity#set Vector.zero;
  e#resolve#set (fun _ t ->
    match t#tag#get with
    | HWall w -> (
        (if w#position#get.y <> 0. then
          e#position#set (Vector.sub e#position#get Cst.j1_v_down)
        else
          e#position#set (Vector.sub e#position#get Cst.j1_v_up)
        );
        e#velocity#set Vector.zero)
    | VWall (_, w) -> (
        (if w#position#get.x <> 0. then
          e#position#set (Vector.sub e#position#get Cst.j1_v_right)
        else
          e#position#set (Vector.sub e#position#get Cst.j1_v_left)
        );
        e#velocity#set Vector.zero)
    (*
     * Je sais pas du tout comment gérer la physique, je te laisse cette partie...
     *)
    | Mappix pix -> (
        let z_pos = Option.value ~default: 0. pix#z_position#get in
        let player_z = match e#z_position#get with | Some x -> x | None -> 0. in
        Gfx.debug "%f %f\n%!" z_pos player_z;
        if z_pos > 0. then 
        (
          if (player_z=0.) then
            let vel = e#velocity#get in
            let newVect = (Vector.{x=(-1.*.vel.x); y=(-1.*.vel.y)}) in 
            e#position#set (Vector.add e#position#get newVect)
          else
            e#z_position#set (Some (Unix.gettimeofday ()));
            e#velocity#set Vector.zero
        ) 
      )
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
    | Portal (idx, (i, j), portal) ->
        let glb = Global.get () in
          let open Vector in
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
  e

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

let player1 () = 
  let Global.{player1; _ } = Global.get () in
  player1

let player2 () =
  let Global.{player2; _ } = Global.get () in
  player2

let stop_players () = 
  let Global.{player1; player2; _ } = Global.get () in
  player1#velocity#set Vector.zero;
  player2#velocity#set Vector.zero

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

let move player v =
  player#velocity#set v

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

let set_texture player texture =
  let texture_handler = (Global.get ()).texture_handler in
  let texture =
    match Hashtbl.find_opt texture_handler texture with
    | Some t -> t
    | None -> Texture.Raw.green
  in
  player#texture#set texture
  
let jump player timeMilli =
  player#z_position#set (Some timeMilli);
  set_texture player (compute_texture player 0)

let set_focused_map_pixel () =
  let glb = Global.get () in

  let focused_texture = Option.value
    (Hashtbl.find_opt glb.texture_handler Texture.Focused_ground)
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
