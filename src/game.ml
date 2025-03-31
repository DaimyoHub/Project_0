open System_defs
open Component_defs
open Ecs

let update dt =
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
  let map = Map.map () in
  let global = Global.{ window; ctx; map; waiting = 1; state = Game } in
  Global.set global;
  Gfx.main_loop update (fun () -> ())
