open Component_defs
open System_defs

type tag += ExitDoor

let exitDoor (x, y, txt, width, height) =
  let e = new wall () in
  e#texture#set txt;
  e#position#set Vector.{x = float x; y = float y};
  e#tag#set ExitDoor;
  e#box#set Rect.{width; height};
  Draw_system.(register (e :> t));
  Collision_system.(register (e :> t));
  e

let create_exit_door () =
  exitDoor  Cst.(exit_x, exit_y, exit_color, exit_width, exit_height)