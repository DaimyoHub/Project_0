open System_defs
open Component_defs
open Ecs

let update dt =
  let () = Player.stop_players () in
  let () = Input.handle_input () in
 
  let _ =
    match Global.get_game_state () with
    | Game -> begin
        Draw_system.update dt;
        Collision_system.update dt
      end
    | Menu -> Menu_system.update dt
  in

  None

let run () =
  let window_spec = 
    Format.sprintf "game_canvas:%dx%d:"
      Cst.window_width Cst.window_height
  in
  let window = Gfx.create  window_spec in
  let ctx = Gfx.get_context window in
  let _walls = Wall.walls () in
  let player1, player2 = Player.players () in
  let global = Global.{ window; ctx; player1; player2; waiting = 1; state = Menu } in
  Input.register "e" (fun () -> Global.set_game_state Game_state.Menu);
  Input.register "a" (fun () -> Global.set_game_state Game_state.Game);
  Global.set global;
  Gfx.main_loop update (fun () -> ())
