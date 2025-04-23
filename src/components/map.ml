open Ecs
open Component_defs
open System_defs
open Map_pixel

let map () =
  let open Map_handler in
  let m = make_flat_map { x = 31; y = 23 }
    |> up_on_range 2 5 3 5 3
    |> up_on_range 1 13 2 9 2
    |> up_on_range 1 18 6 14 4
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
    match Hashtbl.find_opt texture_handler texture_kind with
    | Some t -> t
    | None -> Texture.Raw.green
  in
  map_pixel#texture#set texture

let set_texture map =
  let _ =
    let th = (Global.get ()).texture_handler in
    Map_handler.iteri map (fun i j x -> set_map_pixel_texture th x)
  in ()
