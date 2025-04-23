open System_defs
open Component_defs
open Ecs

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
      else (* n = "map_pixel_wall_3" then *)      Wall_3
    in
    Hashtbl.add texture_handler texture_kind i
  ) images

let prepare_config window ctx texture_handler =
  let _walls = Wall.create () in
  let map = Map.map () in
  let player1, player2 = Player.create_both map in
  let particles = Wind_particle.create () in

  Global.(set {
    window;
    ctx;
    map;
    player1; player2;
    waiting = 1;
    state = Game;
    texture_handler;
    portal1 = None;
    portal2 = None;
    particles;
  })

let handle_game_state dt =
  match Global.get_game_state () with
  | Game -> begin
      Move_system.update dt;
      Collide_system.update dt;
      Draw_system.update dt;
      Wind_system.update dt;
    end
  | Menu -> Menu_system.update dt

let update dt =
  let () = Input.handle_input () in

  Player.set_focused_map_pixel ();
  Player.handle_jump_animation ();
  Wind_particle.respawn_particles_at_left ();
  handle_game_state dt;

  None

let set_textures particles =
  let _ = Map.set_texture (Global.get ()).map in

  let open Player in
  set_texture (player1 ()) Texture.Player_1_right;
  set_texture (player2 ()) Texture.Player_2_left;

  Wind_particle.set_texture (Global.get ()).particles
  
let run () =
  let window_spec =
    Format.sprintf "game_canvas:%dx%d:" Cst.window_width Cst.window_height
  in
  let window = Gfx.create  window_spec in
  let ctx = Gfx.get_context window in

  let tile_set_r = Gfx.load_file "resources/files/tile_set.txt" in
  Gfx.main_loop
    (fun _ -> Gfx.get_resource_opt tile_set_r)
    (fun tile_set -> 
      let images_and_pure_names = tile_set
        |> String.split_on_char '\n'
        |> List.filter (fun s -> s <> "")
        |> List.map (fun s ->
            let pure_name =
              match String.split_on_char '.' s with
              | s :: _ -> s
              | [] -> ""
            in
            Gfx.load_image ctx ("resources/images/" ^ s), pure_name)
      in

      Gfx.main_loop
        (fun _ ->
          if List.for_all
            (fun (s, _) -> Gfx.resource_ready s) images_and_pure_names then
              Some (
                List.map (fun (s, n) -> Texture.Image s, n)
                  (List.map
                    (fun (s, n) -> Gfx.get_resource s, n) images_and_pure_names))
          else None)
        (fun images ->
          let th = Hashtbl.create 10 in
          prepare_texture_handler th images;
          prepare_config window ctx th;
          set_textures ();
          Gfx.main_loop update (fun () -> ())
        ))
