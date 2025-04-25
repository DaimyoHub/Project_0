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
    bullet#tag#set (Bullet bullet);
    bullet#box#set Rect.{ width = 4; height = 4 };

    bullet#velocity#set (Vector.mult 3. player#velocity#get);

    bullet#position#set (Vector.add player#position#get (Vector.mult 10. player#velocity#get));

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
      ~default: Texture.Raw.yellow
    in
    bullet#texture#set bullet_texture;
    player#reinit_shooting_counter