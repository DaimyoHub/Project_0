open Ecs
open Component_defs

type t = drawable

let init _ = ()

let update _dt el =
  let Global.{window;ctx;_} = Global.get () in
  let surface = Gfx.get_surface window in
  let ww, wh = Gfx.get_context_logical_size ctx in

  Gfx.set_color ctx (Gfx.color 0 0 0 255);
  Gfx.fill_rect ctx surface 0 0 ww wh;

  let map_pixels, other_entities =
    Seq.partition (fun e ->
      match e#tag#get with | Tag.Mappix _ -> true | _ -> false) el
  in
  
  let draw e =
    let pos = e#position#get and box = e#box#get and txt = e#texture#get in
    Texture.draw ctx surface pos box txt;
  
    (match (e:>tagged)#tag#get with
    | Tag.Player (_, player) -> (
      if (player#name = "player1") then
        let font = Gfx.load_font "ComicSansMS" "" 32 in
        Gfx.set_color ctx (Gfx.color 255 100 100 255);
        let text_surface = Gfx.render_text ctx ("P1 : "^ (string_of_int player#getPv)^"/20") font in
        Gfx.blit ctx surface text_surface 100 30
      else (
        let font = Gfx.load_font "ComicSansMS" "" 32 in
        Gfx.set_color ctx (Gfx.color 135 206 235 255);
        let text_surface = Gfx.render_text ctx ("P2 : "^ (string_of_int player#getPv)^"/20") font in
        Gfx.blit ctx surface text_surface 250 30
      )
    )
    | _ -> ())
  in

  Seq.iter draw map_pixels;
  Seq.iter draw other_entities;

  let font = Gfx.load_font "ComicSansMS" "" 28 in
  Gfx.set_color ctx (Gfx.color 200 160 255 255);
  let text_surface = Gfx.render_text ctx ((string_of_int (!Global.kill_counter)^" kills")) font in
  Gfx.blit ctx surface text_surface (Cst.window_width-120) 32;


  Gfx.commit ctx
