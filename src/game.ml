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

let load_images dt =
  let glb = Global.get () in
  Hashtbl.add glb.surface_handler
    (* key *) Surface_kind.Ground
    (* value *)(Gfx.get_resource
      (Gfx.load_image (Gfx.get_context glb.window) "resources/images/map_pixel_ground.png"));

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
  let global = Global.{ window; ctx; map; player1; player2; waiting = 1; state = Game; surface_handler = Hashtbl.create 10 } in

  Global.set global;

  let _ = load_images 0 in

  Gfx.main_loop ~limit:true update (fun () -> ())
