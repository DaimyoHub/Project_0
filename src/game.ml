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
    Format.sprintf "game_canvas:%dx%d:"
      Cst.window_width Cst.window_height
  in
  let map = Map.map () in
  let window = Gfx.create  window_spec in
  let ctx = Gfx.get_context window
  and _walls = Wall.walls ()
  and player1, player2 = Player.players map
  and _exitDoor = ExitDoor.create_exit_door () in

  let cfg = Global.{
    window;
    ctx;
    map;
    player1; player2;
    waiting = 1;
    state = Game;
    surface_handler = Hashtbl.create 10;
  }
  in Global.set cfg;

  let tile_set_r = Gfx.load_file "resources/files/tile_set.txt" in
  Gfx.main_loop
    (fun _dt -> Gfx.get_resource_opt tile_set_r)
    (fun txt -> 
       let images_r =
         txt
         |> String.split_on_char '\n'
         |> List.filter (fun s -> s <> "")
         |> List.map (fun s -> Gfx.load_image ctx ("resources/images/" ^ s))
       in
       Gfx.main_loop (fun _dt ->
           if List.for_all Gfx.resource_ready images_r then
             Some (List.map Gfx.get_resource images_r)
           else None
         )
         (fun images ->
            let glb = Global.get () in
            List.iter (fun im -> Hashtbl.add glb.surface_handler Surface_kind.Ground im) images;
            Gfx.main_loop update (fun () -> ())
         ))
