open Component_defs
open Size

let default_size = { x = 8; y = 8 }

let create velocity =
  let bullet = new bullet () in

  bullet#box#set Rect.{
    width = default_size.x;
    height = default_size.y };

  bullet#velocity#set velocity;

  bullet#resolve#set (fun _ t ->
    (* en cas de collision, faire disparaitre la balle *)
    ());

  bullet#texture#set Texture.yellow
