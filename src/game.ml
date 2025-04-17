open System_defs
open Component_defs
open Ecs

let update dt =
  let () = Input.handle_input () in
 
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
  
let run () =
  let window_spec =
    Format.sprintf "game_canvas:%dx%d:" Cst.window_width Cst.window_height
  in
  let window = Gfx.create  window_spec in
  let ctx = Gfx.get_context window in

  (*let tile_set_r = Gfx.load_file "resources/files/tile_set.txt" in*)
  Gfx.main_loop
    (fun _ -> (*Gfx.get_resource_opt tile_set_r*)
      Some "map_pixel_ground.png\nmap_pixel_wall_1.png\nmap_pixel_wall_2.png\nmap_pixel_wall_3.png\n")
    (fun txt -> 
      let images_and_pure_names = txt 
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
              if      n = "map_pixel_ground" then Ground
              else if n = "map_pixel_wall_1" then Wall_1
              else if n = "map_pixel_wall_2" then Wall_2
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

          let glb = Global.get () in
          Map.set_texture glb.map;

          Gfx.main_loop update (fun () -> ())
        ))
