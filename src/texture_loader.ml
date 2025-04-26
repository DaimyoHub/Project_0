(**
   Texture_loader.parse_tile_set ctx tile_set

   Parses the tile set.
 *)
let parse_tile_set ctx tile_set =
  tile_set
    |> String.split_on_char '\n'
    |> List.filter (fun s -> s <> "")
    |> List.map (fun s ->
        let pure_name =
          match String.split_on_char '.' s with
          | s :: _ -> s
          | [] -> ""
        in
        Gfx.load_image ctx ("resources/images/" ^ s), pure_name)

(**
   Texture_loader.get_resources images_and_names

   Extracts resources from [images_and_names].
 *)
let get_resources images_and_names =
  if List.for_all (fun (s, _) -> Gfx.resource_ready s) images_and_names then
    Some (
      List.map (fun (s, n) -> Texture.Image s, n)
        (List.map
          (fun (s, n) -> Gfx.get_resource s, n) images_and_names))
  else None

(**
   Texture_loader.prepare_texture_handler texture_handler images

   Allocates the [texture_handler] with [images].
 *)
let prepare_texture_handler texture_handler images =
  List.iter (fun (i, n) ->
    let texture_kind = 
      let open Texture in
      if      n = "map_pixel_ground"         then Ground
      else if n = "map_pixel_wall_1"         then Wall_1
      else if n = "map_pixel_wall_2"         then Wall_2
      else if n = "player_1_right"           then Player_1_right
      else if n = "player_2_right"           then Player_2_right
      else if n = "player_1_left"            then Player_1_left
      else if n = "player_2_left"            then Player_2_left
      else if n = "player_1_bottom"          then Player_1_bottom
      else if n = "player_2_bottom"          then Player_2_bottom
      else if n = "player_1_top"             then Player_1_top
      else if n = "player_2_top"             then Player_2_top
      else if n = "focused_map_pixel_ground" then Focused_ground
      else if n = "player_1_right_jump_0"    then Player_1_right_jump_0
      else if n = "player_1_right_jump_1"    then Player_1_right_jump_1
      else if n = "player_2_right_jump_0"    then Player_2_right_jump_0
      else if n = "player_2_right_jump_1"    then Player_2_right_jump_1
      else if n = "player_1_left_jump_0"     then Player_1_left_jump_0
      else if n = "player_1_left_jump_1"     then Player_1_left_jump_1
      else if n = "player_2_left_jump_0"     then Player_2_left_jump_0
      else if n = "player_2_left_jump_1"     then Player_2_left_jump_1
      else if n = "player_1_bottom_jump_0"   then Player_1_bottom_jump_0
      else if n = "player_1_bottom_jump_1"   then Player_1_bottom_jump_1
      else if n = "player_2_bottom_jump_0"   then Player_2_bottom_jump_0
      else if n = "player_2_bottom_jump_1"   then Player_2_bottom_jump_1
      else if n = "player_1_top_jump_0"      then Player_1_top_jump_0
      else if n = "player_1_top_jump_1"      then Player_1_top_jump_1
      else if n = "player_2_top_jump_0"      then Player_2_top_jump_0
      else if n = "player_2_top_jump_1"      then Player_2_top_jump_1
      else if n = "wind_particle"            then Wind_particle
      else if n = "portal"                   then Portal
      else if n = "mob_bottom"               then Mob_bottom
      else if n = "mob_top"                  then Mob_top
      else if n = "mob_right"                then Mob_right
      else if n = "mob_left"                 then Mob_left
      else (* n = "map_pixel_wall_3" then *)      Wall_3
    in
    Hashtbl.add texture_handler texture_kind i
  ) images