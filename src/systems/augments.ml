open Ecs
open Component_defs

type t = drawable

let string_of_augment_type augm =
  match augm with 
  | Global.HP -> "extra Health"
  | Global.REGEN -> "Health Regen"
  | Global.SHIELD -> "a bonus Shield"
  | Global.ATKSPEED -> "Better Attack Speed"
  | Global.BULLETSPEED -> "Faster Bullets"
  | Global.MS -> "more Move Speed"
  | Global.DMG -> "more Damage"
  | Global.ARMOR -> "more Armor"
  | Global.BULLETSIZE -> "Bigger Bullets"
  | Global.REZ1 -> "the Resurrection of P1"
  | Global.REZ2 -> "the Resurrection of P2"

let color_of_augment_type augm = 
  match augm with 
  | Global.HP -> Gfx.color 34 193 34 255
  | Global.REGEN -> Gfx.color 159 238 144 255
  | Global.SHIELD -> Gfx.color 196 138 22 255
  | Global.ATKSPEED -> Gfx.color 97 41 5 255
  | Global.BULLETSPEED -> Gfx.color 159 216 22 255
  | Global.MS -> Gfx.color 30 144 255 255
  | Global.DMG -> Gfx.color 255 69 0 255
  | Global.ARMOR -> Gfx.color 169 169 169 255
  | Global.BULLETSIZE -> Gfx.color 255 215 0 255
  | Global.REZ1 | Global.REZ2 -> Gfx.color 200 200 29 255

let add_augment player augm =
  match augm with   
  | Global.HP -> (
      player#increaseMaxHp
  )
  | Global.REGEN -> (
      player#setPv (min (10 + player#getPv) player#getMaxPv)
  )
  | Global.SHIELD -> (
      player#get_a_shield
  )
  | Global.ATKSPEED -> (
      player#increase_max_atk_speed
  )
  | Global.BULLETSPEED -> (
      player#increase_bullet_speed
  )
  | Global.MS -> (
      player#increase_ms
  )
  | Global.DMG -> (
      player#increase_dmg_per_bullet
  )
  | Global.ARMOR -> (
      player#increase_armor
  )
  | Global.BULLETSIZE -> (
      player#increase_bullet_size
  )
  | Global.REZ1 -> (
      if (player#name = "player1") then 
        player#resurrect
  )
  | Global.REZ2 -> (
    if (player#name = "player2") then 
      player#resurrect
  )

let random_augment () =
  let augment_types = [Global.HP; Global.REGEN; Global.SHIELD; Global.ATKSPEED; Global.MS; Global.DMG; Global.ARMOR; Global.BULLETSIZE; Global.BULLETSPEED] in
  let res = Random.int (List.length augment_types) in
  List.nth augment_types res

let random_augment_pair () =
  let first = random_augment () in
  let second = 
    let rec get_different_augment () =
      let second = random_augment () in
      if second = first then get_different_augment ()
      else second
    in
    get_different_augment ()
  in
  (first, second)

let init _ = ()

let update _dt el =
  (* check if augment has been chosen *)
  match !(Global.chosen_option) with 
  | None -> 
    begin
      let Global.{ window; ctx; _ } = Global.get () in
      let surface = Gfx.get_surface window in
          
      Gfx.set_color ctx (Gfx.color 224 224 224 255);
      Gfx.fill_rect ctx surface 0 290 Cst.window_width 110;
    
      let (augm1, augm2) = match (!(Global.current_augments)) with None -> (Global.HP, Global.HP) | Some p -> p in

      let font = Gfx.load_font "ComicSansMS" "" 25 in
      Gfx.set_color ctx (color_of_augment_type augm1);
      let text_surface = Gfx.render_text ctx ("Press \"v\" for "^(string_of_augment_type augm1)) font in
      Gfx.blit ctx surface text_surface 30 300;

      let font = Gfx.load_font "ComicSansMS" "" 25 in
      Gfx.set_color ctx (color_of_augment_type augm2);
      let text_surface = Gfx.render_text ctx ("Press \"b\" for "^(string_of_augment_type augm2)) font in
      Gfx.blit ctx surface text_surface 30 350;    

      Gfx.commit ctx
    end
  | Some has_selected_first_option -> 
    begin

      let (augm1, augm2) = match (!(Global.current_augments)) with None -> (Global.HP, Global.HP) | Some p -> p in

      let () =
        Seq.iter (fun e ->
          match e#tag#get with 
          | Tag.Player (_,p) -> (
            (* add the augment to the player *)
            add_augment p (if has_selected_first_option then augm1 else augm2)
          ) 
          | _ -> ()) el
      in

      Global.chosen_option := None;
      Global.current_augments := None;
      let pause_time = Unix.gettimeofday () -. !Global.start_pause_time in 
      Global.game_time_start := !Global.game_time_start +. pause_time;
      Global.set_game_state Game;
    end