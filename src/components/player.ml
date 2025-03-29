open Ecs
open Component_defs
open System_defs

type tag += Player of player

let player (name, x, y, txt, width, height) =
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
    | ExitDoor.ExitDoor -> (
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

let players () =  
  player  Cst.("player1", j1_x, j1_y, j1_color, j_width, j_height),
  player  Cst.("player2", j2_x, j2_y, j2_color, j_width, j_height)

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

let move_player player v =
  player#velocity#set v
  
let jump_player player timeMilli =
  player#z_position#set (Some timeMilli)