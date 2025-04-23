open Ecs
open Component_defs

type t = passive_movable

let init _ = ()

type wind_vector =
  | Left_to_right
  | Right_to_left
  | Top_to_bottom
  | Bottom_to_top

let compute_wind_vector _dt wind_dir =
  let open Vector in
  match wind_dir with
  | Left_to_right -> { x = 1.;    y = 0. }
  | Right_to_left -> { x = -. 1.; y = 0. }
  | Top_to_bottom -> { x = 0.;    y = 1. }
  | Bottom_to_top -> { x = 0.; y = -. 1. }

let compute_wind_area _dt =
  (250., 350.), (0., 800.)

let is_in_wind_area ((y_top, y_bot), (x_lef, x_rig)) p =
  let Vector.{ x; y } = p#position#get in
  x_lef <= x && x <= x_rig && y_top <= y && y <= y_bot 

let update dt entities =
  let wind_area = compute_wind_area dt in
  let wind_vect = compute_wind_vector dt Left_to_right in

  Seq.iter
    (fun (p : t) ->
      if is_in_wind_area wind_area p then
        let mapped_wind_vect =
          match p#tag#get with
          | Tag.Player _ ->
              if p#z_position#get <> None then Vector.mult 2. wind_vect
              else wind_vect
          | _ -> Vector.mult 2. wind_vect
        in
        p#position#set @@ Vector.add p#position#get mapped_wind_vect)
    entities
