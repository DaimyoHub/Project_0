open Component_defs
open Size
open System_defs

let default_size = { x = 4; y = 4 }

let create player =
  let bullet = new bullet () in

  bullet#box#set Rect.{
    width = default_size.x;
    height = default_size.y };

  bullet#velocity#set (Vector.mult 3. player#velocity#get);

  bullet#position#set (Vector.add player#position#get player#velocity#get);

  bullet#resolve#set (fun _ t ->
    Draw_system.unregister    (bullet :> Draw_system.t);
    Move_system.unregister    (bullet :> Move_system.t);
    Collide_system.unregister (bullet :> Collide_system.t));

  let bullet_texture = Option.value
    (Hashtbl.find_opt (Global.get ()).texture_handler Texture.Bullet)
    ~default: Texture.Raw.yellow
  in
  bullet#texture#set bullet_texture;

  Draw_system.register    (bullet :> Draw_system.t);
  Move_system.register    (bullet :> Move_system.t);
  Collide_system.register (bullet :> Collide_system.t)
