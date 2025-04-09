open Ecs
open Component_defs
open System_defs

type tag += Mappix

let map () =
  let open Map_builder in
  let m = make_flat_map Map_builder.{ x = 31; y = 23 }
    |> up_on_range 1 5 3 5 3
    |> up_on_range 1 13 2 9 2
    |> set_level_as 0 0 Map_pixel.StartA
    |> set_level_as 30 22 Map_pixel.StartB
  in

  iteri m (fun i j x ->
    x#position#set Vector.{
      x = float_of_int ((i + 1) * Map_pixel.default_size.x);
      y = float_of_int ((j + 1) * Map_pixel.default_size.y) };
  
    x#box#set Rect.{
      width = Map_pixel.default_size.x;
      height = Map_pixel.default_size.y };

    let texture =
      match x#get_level with
      | StartA | StartB -> Texture.green
      | Up _ -> Texture.blue
      | _ -> Texture.red
    in
    x#texture#set texture;

    x#tag#set Mappix;

    Draw_system.(register (x :> t)))
