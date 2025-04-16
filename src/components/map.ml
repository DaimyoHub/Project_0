open Ecs
open Component_defs
open System_defs

type tag += Mappix

let map () =
  let open Map_handler in
  let m = make_flat_map { x = 31; y = 23 }
    |> up_on_range 1 5 3 5 3
    |> up_on_range 1 13 2 9 2
    |> set_level_as 0 0 Map_pixel.StartA
    |> set_level_as 30 22 Map_pixel.StartB
  in

  (* let surface_handler = (Global.get ()).surface_handler in *)

  iteri m (fun i j x ->
    x#position#set Vector.{
      x = float_of_int ((i + 1) * Map_pixel.default_size.x);
      y = float_of_int ((j + 1) * Map_pixel.default_size.y) };
  
    x#box#set Rect.{
      width = Map_pixel.default_size.x;
      height = Map_pixel.default_size.y };

    (*let sh = (Global.get ()).surface_handler in
    let _ground_texture = 
      match Hashtbl.find_opt sh Surface_kind.Ground with
      | Some t -> Texture.Image t
      | None -> Texture.green
    in
    x#texture#set Texture.green;*)

    x#texture#set 
      (match x#get_level with
      | Map_pixel.StartA | Map_pixel.StartB -> Texture.green
      | Map_pixel.Up _ -> Texture.red
      | Map_pixel.Top -> Texture.green);

    x#tag#set Mappix;

    Draw_system.(register (x :> t)))
