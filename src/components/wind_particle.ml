open Component_defs
open System_defs

let set_texture particles =
  let particle_texture = Option.value
    (Hashtbl.find_opt (Global.get ()).texture_handler Texture.Wind_particle)
    ~default: Texture.Raw.white
  in
  List.iter (fun p -> p#texture#set particle_texture) particles

let random_int_between (a, b) =
  let low = int_of_float (ceil (min a b)) in
  let high = int_of_float (floor (max a b)) in
  if high < low then
    failwith "No integers in the given float interval"
  else
    low + Random.int (high - low + 1)

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
