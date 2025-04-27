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
  inherit tagged
  inherit Entity.t
  inherit position 
  inherit velocity
  inherit z_position
end

class type passive_movable =
object
  inherit tagged
  inherit Entity.t
  inherit position
  inherit z_position
  inherit box
end

(* List of entities used in the game. *)

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

    val mutable jumping_anim_counter = 0
    val mutable shooting_counter = 0
    val mutable atk_speed = 110
    val mutable pv = 20
    val mutable maxHp = 20
    val mutable dmgPerBullet = 5

    val mutable movespeed = 1.

    val mutable armor = 0
    val mutable shield = 0

    val mutable bullet_size = 2
    val mutable bullet_speed = 1.

    val mutable is_dead = false
    val mutable is_resurrected = false

    method is_p_resurrected = is_resurrected
    method resurrect = is_resurrected <- true; pv <- 1 
    method resurection_completed = (is_resurrected <- false; is_dead <- false)

    method get_bullet_speed = bullet_speed 
    method increase_bullet_speed = bullet_speed <- bullet_speed +. 1.

    method get_ms = movespeed
    method increase_ms = movespeed <- movespeed +. 1.

    method get_bullet_size = bullet_size
    method increase_bullet_size = bullet_size <- bullet_size + 1

    method get_a_shield = shield <- shield + 1
    method get_shield = shield

    method get_armor = armor
    method increase_armor = armor <- armor + 1

    method kill_player = is_dead <- true
    method is_dead = is_dead
    
    method getDmgPerBullet = dmgPerBullet
    method increase_dmg_per_bullet = dmgPerBullet <- dmgPerBullet + 3
    method getPv = pv

    method getMaxPv = maxHp
    method increaseMaxHp = maxHp <- maxHp + 5 

    method setPv amount = pv <- amount
    method losePv amount = (
      if (shield >0) then (
        shield <- shield - 1
      )
      else (
        let reducted_amount = amount - armor in
        if reducted_amount < 0 then
          pv <- pv
        else
          pv <- pv - reducted_amount
      )
    )

    method is_jumping = jumping_anim_counter <> 0
    method can_shoot = shooting_counter = 0

    method incr_jumping_anim_counter = 
      jumping_anim_counter <- jumping_anim_counter + 1

    method incr_shooting_counter = 
      shooting_counter <- shooting_counter + 1

    method get_jumping_anim_counter = jumping_anim_counter

    method get_shooting_counter = shooting_counter

    method reinit_jumping_anim_counter =
      jumping_anim_counter <- 0

    method reinit_shooting_counter =
      shooting_counter <- 0

    method get_max_atk_speed =
      atk_speed
    
    method increase_max_atk_speed =
      if atk_speed>=90 then
        atk_speed <- atk_speed - 7
      else if atk_speed>=75 then 
        atk_speed <- atk_speed - 4
      else if atk_speed>=60 then 
        atk_speed <- atk_speed - 1 
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

class mobTerrestre () =
  object
    inherit Entity.t ()
    inherit position ()
    inherit velocity ()
    inherit box ()
    inherit tagged ()
    inherit texture ()
    inherit resolver ()
    inherit z_position ()

    val mutable atk_speed = 3.
    val mutable pv = 5
    val mutable dmgPerBullet = 5
    val mutable lastDmgWhenOnPlayer = Unix.gettimeofday ()

    val mutable lastShootTiming = Unix.gettimeofday ()

    method handleDmgGetWhenMobOnPlayer = (
      let curr_time = Unix.gettimeofday () in 
      if (curr_time-.lastDmgWhenOnPlayer>3.) then (
        lastDmgWhenOnPlayer <- curr_time;
        dmgPerBullet
      ) else 0
    )

    method getPv = pv
    method setPv amount = pv <- amount
    method losePv amount = pv <- pv - amount
    method getDmgPerBullet = dmgPerBullet
    method set_atk_speed amount = atk_speed <- amount
    method set_dmg amount = dmgPerBullet <- amount

    method is_the_mob_shooting = (
      let curr_time = Unix.gettimeofday () in 
      if (curr_time-.lastShootTiming>atk_speed) then (
        lastShootTiming <- curr_time;
        true
      ) else false
    )
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

    val mutable sent_from_player = true

    val mutable dmg = 0

    method is_sent_by_player = sent_from_player
    method created_by_mob = sent_from_player <- false

    method defineDmg amount = dmg <- amount
    method getDmg = dmg
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

class particle () =
  object
    inherit Entity.t ()
    inherit position ()
    inherit z_position ()
    inherit tagged ()
    inherit texture ()
    inherit box ()
  end
