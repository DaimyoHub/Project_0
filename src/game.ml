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
  let window = Gfx.create  window_spec
  and ctx = Gfx.get_context window
  and _walls = Wall.walls ()
  and player1, player2 = Player.players ()
  and _exitDoor = ExitDoor.create_exit_door ()
  and map = Map.map () in
  let global = Global.{ window; ctx; map; player1; player2; waiting = 1; state = Game } in

  Global.set global;
  Gfx.main_loop ~limit:true update (fun () -> ())
