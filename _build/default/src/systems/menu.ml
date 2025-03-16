open Ecs
open Component_defs

type t = drawable

let init _ = ()

let update _dt el =
  let Global.{ window; ctx; _ } = Global.get () in
  let surface = Gfx.get_surface window in
  let ww, wh = Gfx.get_context_logical_size ctx in

  Gfx.set_color ctx (Gfx.color 0 0 0 255);
  Gfx.fill_rect ctx surface 0 0 ww wh;

  Gfx.commit ctx
