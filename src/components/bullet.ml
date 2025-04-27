open Component_defs
open Size
open System_defs
open Tag

(**
 * Bullet.create player
 *
 * Creates a bullet shot by [player]. The bullet is registered in the draw, move
 * and collide system. When it touches something, it is unregistered from them.
 *)
let create player dmg =
  (* if velocity is zero, don't create anything *)
  let vel = player#velocity#get in 
  if (not (Vector.is_zero vel)) then
    let bullet = new bullet () in
    (* Gfx.debug "%i \n%!" player#get_bullet_size; *)
    bullet#tag#set (Bullet bullet);
    bullet#box#set Rect.{ width = player#get_bullet_size; height = player#get_bullet_size };

    bullet#velocity#set (Vector.mult (2.+.player#get_bullet_speed) player#velocity#get);

    bullet#position#set (Vector.add player#position#get (Vector.mult 10. player#velocity#get));

    Draw_system.register    (bullet :> Draw_system.t);
    Move_system.register    (bullet :> Move_system.t);
    Collide_system.register (bullet :> Collide_system.t);

    bullet#defineDmg dmg;

    bullet#resolve#set (fun _ t ->
      match t#tag#get with
      | Portal (idx, (i, j), portal) -> (
          let open Vector in
          let glb = Global.get () in
          let target_portal_opt = 
            match idx with
            | One -> glb.portal2
            | _   -> glb.portal1
          in
          match target_portal_opt with
          | Some (_, target_portal) ->
              let new_pos = add
                target_portal#position#get
                (mult 24. (normalize bullet#velocity#get))
              in
              let posX = new_pos.x in
              let posY = new_pos.y in
              if posX > 0. && posX < (float_of_int Cst.window_width -. 24.) &&
                 posY > 0. && posY < (float_of_int Cst.window_height -. 24.) then
                bullet#position#set new_pos
          | None -> ()
        )
      | _ -> (
          Draw_system.unregister    (bullet :> Draw_system.t);
          Move_system.unregister    (bullet :> Move_system.t);
          Collide_system.unregister (bullet :> Collide_system.t)
        )
    );    

    let bullet_texture = Option.value 
      (Hashtbl.find_opt (Global.get ()).texture_handler Texture.Bullet)
      ~default: Texture.Raw.yellow
    in
    bullet#texture#set bullet_texture;
    player#reinit_shooting_counter

let mob_create mob dmg =
  let vel = mob#velocity#get in 
  if (not (Vector.is_zero vel)) then
    let bullet = new bullet () in
    bullet#tag#set (Bullet bullet);
    bullet#box#set Rect.{ width = 4; height = 4 };

    bullet#velocity#set (Vector.mult 3. mob#velocity#get);

    bullet#position#set (Vector.add mob#position#get (Vector.mult 21. mob#velocity#get));

    Draw_system.register    (bullet :> Draw_system.t);
    Move_system.register    (bullet :> Move_system.t);
    Collide_system.register (bullet :> Collide_system.t);

    bullet#defineDmg dmg;

    bullet#resolve#set (fun _ t ->
      Draw_system.unregister    (bullet :> Draw_system.t);
      Move_system.unregister    (bullet :> Move_system.t);
      Collide_system.unregister (bullet :> Collide_system.t));

    let bullet_texture = Option.value 
      (Hashtbl.find_opt (Global.get ()).texture_handler Texture.Bullet)
      ~default: Texture.Raw.purple
    in
    bullet#texture#set bullet_texture;
    bullet#created_by_mob