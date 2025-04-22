open Component_defs
open System_defs
open Portal_tag

let set_texture portal =
  let glb = Global.get () in
  let portal_texture = Option.value
    (Hashtbl.find_opt glb.texture_handler Texture_kind.Portal)
    ~default: Texture.green
  in
  portal#texture#set portal_texture

let create_or_move_portal1 (i, j) map_pixel =
  let glb = Global.get () in

  let set_portal portal =
      portal#position#set map_pixel#position#get;
      portal#box#set map_pixel#box#get;
      portal#tag#set (Portal (One, (i, j), portal));
      set_texture portal;

      glb.portal1 <- Some ((i, j), portal)
  in

  match glb.portal1 with
  | None -> begin
      let portal = new portal () in set_portal portal;
      Draw_system.register (portal :> Draw_system.t);
      Collision_system.register (portal :> Collision_system.t)
    end
  | Some ((_, _), portal) -> set_portal portal

let create_or_move_portal2 (i, j) map_pixel =
  let glb = Global.get () in

  let set_portal portal =
      portal#position#set map_pixel#position#get;
      portal#box#set map_pixel#box#get;
      portal#tag#set (Portal (Two, (i, j), portal));
      set_texture portal;

      glb.portal2 <- Some ((i, j), portal)
  in

  match glb.portal2 with
  | None -> begin
      let portal = new portal () in set_portal portal;
      Draw_system.register (portal :> Draw_system.t);
      Collision_system.register (portal :> Collision_system.t)
    end
  | Some ((_, _), portal) -> set_portal portal
