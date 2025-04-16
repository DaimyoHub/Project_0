open Ecs
open Component_defs
open System_defs

type tag += Player of player

let create (name, x, y, txt, width, height) =
  let e = new player name in
  e#texture#set txt;
  e#tag#set (Player e) ;
  e#position#set Vector.{x = float x; y = float y};
  e#box#set Rect.{width; height};
  e#velocity#set Vector.zero;
  e#resolve#set (fun _ t ->
    match t#tag#get with
    | Wall.HWall w -> (
        (if w#position#get.y <> 0. then
          e#position#set (Vector.sub e#position#get Cst.j1_v_down)
        else
          e#position#set (Vector.sub e#position#get Cst.j1_v_up));
          e#velocity#set Vector.zero)
    | Wall.VWall (_, w) -> (
        (if w#position#get.x <> 0. then
          e#position#set (Vector.sub e#position#get Cst.j1_v_right)
        else
          e#position#set (Vector.sub e#position#get Cst.j1_v_left));
          e#velocity#set Vector.zero)
    | Exit_door.ExitDoor -> (
          Global.set_game_state Menu
    )
    | Player p -> 
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
    | _ -> ());
  Draw_system.(register (e :> t));
  Collision_system.(register (e :> t));
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
  create Cst.("player1", int_of_float p1.x, int_of_float p1.y, j1_color, j_width, j_height),
  create Cst.("player2", int_of_float p2.x, int_of_float p2.y, j2_color, j_width, j_height)

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

let get_map_pixel_under player =
  let Vector.{ x; y } = player#position#get in
  
  let i = int_of_float (
    Float.round (x /. (float_of_int Map_pixel.default_size.x) +. 0.5))
  and j = int_of_float (
    Float.round (y /. (float_of_int Map_pixel.default_size.y) +. 0.5))
  in

  let glb = Global.get () in
  Map_handler.get_pixel glb.map i j

let move player v =
  player#velocity#set v
  
let jump player timeMilli =
  player#z_position#set (Some timeMilli)
