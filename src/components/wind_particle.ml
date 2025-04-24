open Component_defs
open System_defs

(**
   Wind_particle.set_texture particles

   Sets the texture of every particles contained in [particles].
 *)
let set_texture particles =
  let open Texture in
  let particle_texture = get Wind_particle Raw.white in
  List.iter (fun p -> p#texture#set particle_texture) particles

(**
   Wind_particle.random_int_between (a, b)

   Chooses a random int number between floats [a] and [b].
 *)
let random_int_between (a, b) =
  let low = int_of_float (ceil (min a b)) in
  let high = int_of_float (floor (max a b)) in
  if high < low then
    failwith "No integers in the given float interval"
  else
    low + Random.int (high - low + 1)

(**
   Wind_particle.respawn_particles_at_left ()

   When a particle hits the right side of the map, it respawns it on the left
   side (this function assumes the wind is going left to right, from the left
   to the right of the map). The new y coordinates is a random int between the
   floats defining the y area of the wind.
 *)
let respawn_particles_at_left () =
  let particles = (Global.get ()).particles in
  List.iter
    (fun p ->
      let Vector.{ x; _ } = p#position#get in
      if x >= 750. then
        let y_area, _ = Wind.compute_wind_area 0 in
        let y = float_of_int (random_int_between y_area) in
        p#position#set Vector.{ x = 24.; y })
    particles

(**
   Wind_particle.create ()

   Creates the set of particles being transported by the wind. It registers it
   to the wind/draw system.
 *)
let create () =
  Random.self_init ();
  let particles = List.init 5
    (fun _ ->
      let p = new particle () in

      let y_area, x_area = Wind.compute_wind_area 0 in
      let x = float_of_int (random_int_between x_area)
      and y = float_of_int (random_int_between y_area) in
      p#position#set Vector.{ x; y };

      p#z_position#set None;
      p#tag#set Tag.Particle;
      p#box#set Rect.{ width = 10; height = 2 };
      p)
  in

  List.iter
    (fun p ->
      Wind_system.(register (p :> t));
      Draw_system.(register (p :> t)))
    particles;

  particles
