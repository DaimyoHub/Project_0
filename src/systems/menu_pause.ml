open Ecs
open Component_defs

type t = drawable

let init _ = ()

let update _dt el =
  let Global.{ window; ctx; _ } = Global.get () in
  let surface = Gfx.get_surface window in

  Gfx.set_color ctx (Gfx.color 64 0 81 130);
  Gfx.fill_rect ctx surface 0 0 Cst.window_width Cst.window_height;

  let font = Gfx.load_font "ComicSansMS" "" 30 in

  let player1 : player option ref = ref None in 
  let player2 : player option ref = ref None in 
  Seq.iter (fun e ->
    match e#tag#get with
    | Tag.Player (_, p) -> if p#name = "player1" then player1 := Some p else player2 := Some p
    | _ -> ()
  ) el;

  let draw_player_stats player x y color =
    Gfx.set_color ctx color;
    let is_first_player = player#name = "player1" in
    let lines = [
      player#name;
      "";
      "";
      "HP: " ^ (if not player#is_dead then (string_of_int player#getPv ^ "/" ^ string_of_int player#getMaxPv) else "Dead");
      "";
      "Movement: " ^ (if is_first_player then "z q s d" else "i j k l");
      "Jump: " ^ (if is_first_player then "a" else "u");
      "Create a Portal: " ^ (if is_first_player then "w" else "n");
      "Shoot: " ^ (if is_first_player then "e" else "o");
    ] in
    List.iteri (fun i line ->
      let text_surface = Gfx.render_text ctx line font in
      Gfx.blit ctx surface text_surface x (y + i * 36)
    ) lines
  in

  begin match !player1 with
  | Some p -> draw_player_stats p 120 36 (Gfx.color 255 100 100 255)
  | None -> ()
  end;

  begin match !player2 with
  | Some p -> draw_player_stats p (Cst.window_width - 320) 36 (Gfx.color 135 206 235 255)
  | None -> ()
  end;

  Gfx.set_color ctx (Gfx.color 255 255 255 255);
  let text_surface = Gfx.render_text ctx ("M ->  Open the Menu") font in
  Gfx.blit ctx surface text_surface 270 (Cst.window_height-130);

  Gfx.set_color ctx (Gfx.color 255 255 255 255);
  let text_surface = Gfx.render_text ctx ("P  ->  Continue") font in
  Gfx.blit ctx surface text_surface 270 (Cst.window_height-100);

  Gfx.set_color ctx (Gfx.color 255 255 255 255);
  let text_surface = Gfx.render_text ctx ("R  ->  Restart") font in
  Gfx.blit ctx surface text_surface 270 (Cst.window_height-70);

  Gfx.commit ctx
