open Component_defs
open System_defs

(**
   Portal.set_texture portal

   Sets the convenient texture to the given [portal].
 *)
let set_texture portal =
  let glb = Global.get () in
  let open Texture in
  let portal_texture = get Portal Raw.green in
  portal#texture#set portal_texture

(**
   Portal.create_or_move_portal1 (i, j) map_pixel

   Handles the creation of portals. If player1 has already put a portal on the
   ground, it moves it the the convenient pixel. Else, it creates it and 
   registers it to the draw/collide system.

   See Portal.create_or_move_portal2 (i, j) map_pixel
 *)
let create_or_move_portal1 (i, j) map_pixel =
  let glb = Global.get () in

  let set_portal portal =
      portal#position#set map_pixel#position#get;
      portal#box#set map_pixel#box#get;
      portal#tag#set (Tag.Portal (One, (i, j), portal));
      set_texture portal;

      glb.portal1 <- Some ((i, j), portal)
  in

  match glb.portal1 with
  | None -> begin
      let portal = new portal () in set_portal portal;
      Draw_system.register (portal :> Draw_system.t);
      Collide_system.register (portal :> Collide_system.t)
    end
  | Some ((_, _), portal) -> set_portal portal

(**
   Portal.create_or_move_portal2 (i, j) map_pixel

   Same as Portal.create_or_move_portal1 but for player2.
 *)
let create_or_move_portal2 (i, j) map_pixel =
  let glb = Global.get () in

  let set_portal portal =
      portal#position#set map_pixel#position#get;
      portal#box#set map_pixel#box#get;
      portal#tag#set (Tag.Portal (Two, (i, j), portal));
      set_texture portal;

      glb.portal2 <- Some ((i, j), portal)
  in

  match glb.portal2 with
  | None -> begin
      let portal = new portal () in set_portal portal;
      Draw_system.register (portal :> Draw_system.t);
      Collide_system.register (portal :> Collide_system.t)
    end
  | Some ((_, _), portal) -> set_portal portal
