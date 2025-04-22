open Ecs
class position () =
  let r = Component.init Vector.zero in
  object
    method position = r
  end

class z_position () =
  let r = Component.init (None : float option) in
  object
    method z_position = r
  end

class velocity () =
  let r = Component.init Vector.{x=5.; y=5.} in 
  object 
    method velocity = r 
  end

class box () =
  let r = Component.init Rect.{width = 0; height = 0} in
  object
    method box = r
  end

class texture () =
  let r = Component.init (Texture.Color (Gfx.color 0 0 0 255)) in
  object
    method texture = r
  end

type tag = ..
type tag += No_tag

class tagged () =
  let r = Component.init No_tag in
  object
    method tag = r
  end

class resolver () =
  let r = Component.init (fun (_ : Vector.t) (_ : tagged) -> ()) in
  object
    method resolve = r
  end

(** Interfaces : ici on liste simplement les types des classes dont on hérite
    si deux classes définissent les mêmes méthodes, celles de la classe écrite
    après sont utilisées (héritage multiple).
*)

class type collidable =
  object
    inherit Entity.t
    inherit position
    inherit box
    inherit tagged
    inherit resolver
  end

class type drawable =
  object
    inherit Entity.t
    inherit position
    inherit box
    inherit texture
    inherit z_position
    inherit tagged
  end

class type movable =
object
  inherit Entity.t
  inherit position 
  inherit velocity
  inherit z_position
end

(** Entités :
    Ici, dans inherit, on appelle les constructeurs pour qu'ils initialisent
    leur partie de l'objet, d'où la présence de l'argument ()
*)
class player name =
  object
    inherit Entity.t ~name ()
    inherit position ()
    inherit velocity ()
    inherit box ()
    inherit tagged ()
    inherit texture ()
    inherit resolver ()
    inherit z_position ()
  end

class map_pixel =
  object
    inherit Entity.t ()
    inherit position ()
    inherit box ()
    inherit tagged ()
    inherit texture ()
    inherit resolver ()
    inherit z_position ()

    val mutable level = Map_pixel.Top
    method get_level = level
    method set_level v = level <- v
  end

class ball () =
  object
    inherit Entity.t ()
    inherit position ()
    inherit box ()
    inherit tagged ()
    inherit texture ()
    inherit resolver ()
  end

class wall () =
  object
    inherit Entity.t ()
    inherit position ()
    inherit box ()
    inherit tagged ()
    inherit texture ()
    inherit resolver ()
    inherit z_position ()
  end

class exitDoor () =
  object
    inherit Entity.t ()
    inherit position ()
    inherit box ()
    inherit tagged ()
    inherit texture ()
    inherit resolver ()
  end

class bullet () =
  object
    inherit Entity.t ()
    inherit position ()
    inherit z_position ()
    inherit tagged ()
    inherit velocity ()
    inherit box ()
    inherit resolver ()
    inherit texture ()
  end

class portal () =
  object
    inherit Entity.t ()
    inherit position ()
    inherit z_position ()
    inherit tagged ()
    inherit box ()
    inherit resolver ()
    inherit texture ()
  end
