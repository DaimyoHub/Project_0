open Ecs
open Component_defs
open System_defs
open Map_pixel

(**
   Map.create ()
  
   Creates a specific map, sets all of its pixels as entities and register them
   in the draw system and in the collide system for pixels lying in the air.
  
   See modules Map_handler and Map_pixel for more informations.
 *)
let create () =
  let open Map_handler in
  let m = make_flat_map { x = 31; y = 23 }
    |> up_on_range 2 5 3 5 3
    |> up_on_range 1 13 2 9 2
    |> set_level_as 0 0 Map_pixel.StartA
    |> set_level_as 30 22 Map_pixel.StartB
  in

  iteri m (fun i j x ->
    x#position#set Vector.{
      x = float_of_int ((i + 1) * Map_pixel.default_size.x);
      y = float_of_int ((j + 1) * Map_pixel.default_size.y) };

    let int_z_pos = Map_handler.int_of_level x#get_level in
    x#z_position#set (Some (float_of_int int_z_pos));
  
    x#box#set Rect.{
      width = Map_pixel.default_size.x;
      height = Map_pixel.default_size.y };

    x#tag#set (Tag.Mappix (x :> z_position));

    Draw_system.(register (x :> t));
    if int_z_pos > 0 then Collide_system.(register (x :> t)))

(**
   Map.set_map_pixel_texture texture_handler map_pixel
  
   Sets the good texture to the given pixel. The texture handler must be loaded
   before calling this function.
 *)
let set_map_pixel_texture texture_handler map_pixel =
  let texture = 
    let open Texture in
    let lvl = Map_handler.int_of_level map_pixel#get_level in
    let texture_kind =
      if      lvl = 0 then Ground
      else if lvl = 1 then Wall_1
      else if lvl = 2 then Wall_2
      else (* lvl = 3 *)   Wall_3
    in
    Option.value
      (Hashtbl.find_opt (Global.get ()).texture_handler texture_kind)
      ~default: Raw.green
  in
  map_pixel#texture#set texture

(**
   Map.set_texture map
  
   Sets the texture of each pixels of the map.
 *)
let set_texture map =
  let th = (Global.get ()).texture_handler in
  Map_handler.iteri map (fun i j x -> set_map_pixel_texture th x)
