open Size
open Map_pixel
open Component_defs

type data = (Component_defs.map_pixel Array.t) Array.t

type map = {
  size: size;
  data: data;
}

let int_of_level level =
  let rec compute_level acc = function
    | Top | StartA | StartB -> acc
    | Up lvl -> compute_level (acc + 1) lvl
  in
  compute_level 0 level

(* Default map size *)
let default_size = { x = 10; y = 10 }

(*
 * make_flat_map size
 *
 * Construit une map de la taille size donnée.
 *)
let make_flat_map size =
  {
    size = size;
    data = Array.init size.x (fun _ -> Array.init size.y (fun _ -> new map_pixel))
  }

(*
 * is_position_in_bounds map x y
 *
 * Vérifie que la position donnée apparait sur la map.
 *)
let is_position_in_bounds map x y =
     0 <= x && x <= map.size.x
  && 0 <= y && y <= map.size.y

(*
 * up_on_range map height x x_length y y_length
 *
 * Surelève un rectangle donné de la map de height niveaux.
 *
 * TODO: Mémoïser les level qui ont viennent d'être calculés pour éviter de
 * les recalculer à chaque fois
 *)
let up_on_range height x x_length y y_length map =
  let end_x = x + x_length - 1 and end_y = y + y_length - 1 in
  assert (is_position_in_bounds map x y);
  assert (is_position_in_bounds map end_x end_y);

  let rec up_level_by_height level height =
    if height <> 0 then
      up_level_by_height (Up level) (height - 1)
    else level
  in
  for i = x to x + x_length - 1 do
    for j = y to y + y_length - 1 do
      map.data.(i).(j)#set_level (up_level_by_height map.data.(i).(j)#get_level height)
    done
  done;
  map

(*
 * set_level_as map x y kind
 *
 * Convertit le point donné de la map en un niveau du type kind.
 *)
let set_level_as x y kind map =
  assert (is_position_in_bounds map x y);

  let rec set_level acc = function
    | Up lvl -> set_level (Up acc) lvl
    | _ -> acc
  in
  map.data.(x).(y)#set_level (set_level kind map.data.(x).(y)#get_level);
  map

let iter_if map pred f =
  for i = 0 to map.size.x - 1 do
    for j = 0 to map.size.y - 1 do
      if pred map.data.(i).(j) then
        f map.data.(i).(j)
    done
  done;
  map

let iter map = iter_if map (fun _ -> true)

let iteri_if map pred f =
  for i = 0 to map.size.x - 1 do
    for j = 0 to map.size.y - 1 do
      if pred i j map.data.(i).(j) then
        f i j map.data.(i).(j)
    done
  done;
  map

let iteri map = iteri_if map (fun _ _ _ -> true)

let is_pixel_of_kind map i j kind =
  assert (is_position_in_bounds map i j);

  let rec fold = function
    | Up x -> fold x
    | x -> x
  in
  (fold map.data.(i).(j)#get_level) = kind

let get_pixel map i j =
  assert (is_position_in_bounds map i j);

  map.data.(i).(j)

(*
 * Exemple d'utilisation :
 * 
 * make_flat_map default_size
 *   |> up_on_range 1 100 50 100 50
 *   |> up_on_range 1 100 25 100 25
 *   |> set_level_as 100 100 StartA
 *
 * On a une map de taille 500x500 et à partir du point (100, 100), sur 25
 * points, la map est surelevée de deux niveaux et de 1 niveau sur 50 points.
 * De plus, le joueur A apparait à la position (100, 100).
 *)
