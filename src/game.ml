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
        Gfx.debug "\n\n"
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

  let tile_set_r = Gfx.load_file "resources/files/tile_set.txt" in
  Gfx.main_loop
    (fun _ -> Gfx.get_resource_opt tile_set_r)
    (fun txt -> 
       let images_r =
         txt
         |> String.split_on_char '\n'
         |> List.filter (fun s -> s <> "")
         |> List.map (fun s -> Gfx.load_image ctx ("resources/images/" ^ s))
       in
       Gfx.main_loop (fun _ ->
           if List.for_all Gfx.resource_ready images_r then
             Some (
               List.map (fun surface -> Texture.Image surface)
                (List.map Gfx.get_resource images_r))
           else None
         )
         (fun images ->
            let th = Hashtbl.create 10 in
            List.iter (fun im -> Hashtbl.add th Texture_kind.Ground im) images;

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
