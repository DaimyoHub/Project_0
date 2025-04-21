open Ecs
open Component_defs
open System_defs

type tag += Player of player

let create (name, x, y, width, height) =
  let e = new player name in
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
    (*
     * Je sais pas du tout comment gérer la physique, je te laisse cette partie...
     *)
    | Map_pixel_tag.Mappix pix -> (
        let z_pos = Option.value ~default: 1. pix#z_position#get in
        if z_pos > 0. then e#velocity#set Vector.zero)
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
  create Cst.("player1", int_of_float p1.x, int_of_float p1.y, j_width, j_height),
  create Cst.("player2", int_of_float p2.x, int_of_float p2.y, j_width, j_height)

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

  if Map_handler.is_position_in_bounds map i j then
    let pix = Map_handler.get_pixel map i j in

    let player_z_pos = 
      match player#z_position#get with
      | None -> 0
      | Some i -> int_of_float i
    in
    let pixel_z_pos = Map_handler.int_of_level pix#get_level in

    if player_z_pos = pixel_z_pos then Some pix else None
  else None

let move player v =
  player#velocity#set v
  
let jump player timeMilli =
  player#z_position#set (Some timeMilli)

let set_texture player texture =
  let texture_handler = (Global.get ()).texture_handler in
  let texture =
    match Hashtbl.find_opt texture_handler texture with
    | Some t -> t
    | None -> Texture.green
  in
  player#texture#set texture
