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
    Seq.partition (fun e -> e#tag#get = Map_pixel_tag.Mappix) el
  in
  
  let draw e =
    let pos = e#position#get and box = e#box#get and txt = e#texture#get in
    Texture.draw ctx surface pos box txt
  in

  Seq.iter draw map_pixels;
  Seq.iter draw other_entities;

  Gfx.commit ctx
