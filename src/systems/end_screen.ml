open Ecs
open Component_defs

type t = drawable

let init _ = ()

let update _dt el =
  if (!Global.players_are_dead) then (
    let Global.{ window; ctx; _ } = Global.get () in
    let surface = Gfx.get_surface window in
    let font = Gfx.load_font "ComicSansMS" "" 32 in
  
    Gfx.set_color ctx (Gfx.color 215 0 0 255);
    Gfx.fill_rect ctx surface 0 290 Cst.window_width 70;

    Gfx.set_color ctx (Gfx.color 255 255 255 255);
    let text_surface = Gfx.render_text ctx ("RIP, You died before the end of the " ^ string_of_int Cst.max_time ^ " seconds...") font in
    Gfx.blit ctx surface text_surface 30 300;
  
    Gfx.commit ctx
  )
  

  else (
    let Global.{ window; ctx; _ } = Global.get () in
    let surface = Gfx.get_surface window in
    let font = Gfx.load_font "ComicSansMS" "" 32 in
  
    Gfx.set_color ctx (Gfx.color 0 215 0 255);
    Gfx.fill_rect ctx surface 0 290 Cst.window_width 70;

    Gfx.set_color ctx (Gfx.color 255 255 255 255);
    let text_surface = Gfx.render_text ctx ("Congratulations ! You survived the "^(string_of_int Cst.max_time)^" seconds !!") font in
    Gfx.blit ctx surface text_surface 30 300;
  
    Gfx.commit ctx
  )