open System_defs
open Component_defs
open Ecs

let set_focused_map_pixel () =
  let glb = Global.get () in

  let focused_texture = Option.value
    (Hashtbl.find_opt glb.texture_handler Texture_kind.Focused_ground)
    ~default: Texture.green
  in

  glb.map <-
    Map_handler.iter_if glb.map
      (fun pix -> pix#texture#get = focused_texture) 
      (fun pix -> Map.set_map_pixel_texture glb.texture_handler pix);

  let p1, p2 = Player.(player1 (), player2 ()) in

  match Player.get_focused_map_pixel p1 glb.map with
  | Some pix -> pix#texture#set focused_texture
  | None -> ()

let update dt =
  let () = Input.handle_input () in

  set_focused_map_pixel ();
 
  let _ =
    match Global.get_game_state () with
    | Game -> begin
        Move_system.update dt;
        Collision_system.update dt;
        Draw_system.update dt;
      end
    | Menu -> Menu_system.update dt
  in

  None

let set_textures () =
  Map.set_texture (Global.get ()).map;

  let open Player in
  set_texture (player1 ()) Texture_kind.Player_1_top;
  set_texture (player2 ()) Texture_kind.Player_2_top
  
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

          List.iter (fun (i, n) ->
            let texture_kind = 
              let open Texture_kind in
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
              else (* n = "map_pixel_wall_3" *)   Wall_3
            in
            Hashtbl.add th texture_kind i
          ) images;

          let _walls = Wall.create ()
          and map = Map.map () in
          let player1, player2 = Player.create_both map
          and _exitDoor = Exit_door.create () in

          let cfg = Global.{
            window;
            ctx;
            map;
            player1; player2;
            waiting = 1;
            state = Game;
            texture_handler = th;
          }
          in Global.set cfg;

          set_textures ();

          Gfx.main_loop update (fun () -> ())
        ))
