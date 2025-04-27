open Ecs
open Component_defs
open System_defs
open Tag

let all_mobs : (int, mobTerrestre) Hashtbl.t = Hashtbl.create 6
let mob_id_counter = ref 1

let reset () =
  mob_id_counter := 1;
  Hashtbl.reset all_mobs

let create x y _ =
  let open Tag in 
  let e = new mobTerrestre () in 

  (* la force d'un mob dépend du combien-ième il est à spawn:
   tous les 5 spawns, ils sont renforcés*)

  let id = !mob_id_counter in
  mob_id_counter := id + 1;
  let ratio_amelioration = !mob_id_counter / 5 in
  Hashtbl.add all_mobs id e;

  e#tag#set (MobTerrestre e);
  e#position#set Vector.{ x = float x; y = float y };
  let height = Cst.mobTerrestreHeight in 
  let width = Cst.mobTerrestreWidth in 
  e#box#set Rect.{width;height};
  let velocity = Cst.mobTerrestreVelocity in 
  e#velocity#set (Vector.mult (float_of_int ratio_amelioration) velocity);
  e#resolve#set (fun _ t ->
    match t#tag#get with 
    | HWall w -> (
        (if w#position#get.y <> 0. then
          e#position#set (Vector.sub e#position#get Cst.mobTerr_v_down)
        else
          e#position#set (Vector.sub e#position#get Cst.mobTerr_v_up)
        );
        e#velocity#set Vector.zero)
    | VWall (_, w) -> (
        (if w#position#get.x <> 0. then
          e#position#set (Vector.sub e#position#get Cst.mobTerr_v_right)
        else
          e#position#set (Vector.sub e#position#get Cst.mobTerr_v_left)
        );
        e#velocity#set Vector.zero)
    | Mappix pix -> (
        let z_pos = Option.value ~default: 0. pix#z_position#get in
        if z_pos > 0. then 
        (
          let vel = e#velocity#get in
          let newVect = (Vector.{x=(-1.*.vel.x); y=(-1.*.vel.y)}) in 
          e#position#set (Vector.add e#position#get newVect)
        ) 
      )
    | Bullet b -> (
        if (b#is_sent_by_player) then e#losePv (b#getDmg)
      )
    | Player (_, p) -> (
      let amount = e#handleDmgGetWhenMobOnPlayer in
      p#losePv amount;
    )
    | _ -> ()
  );

  e#setPv (4+3*ratio_amelioration);
  e#set_dmg (5+(3*ratio_amelioration));
  e#set_atk_speed (3.-.(0.2*.(float_of_int ratio_amelioration)));

  Draw_system.(register (e :> t));
  Collide_system.(register (e :> t));
  Move_system.(register (e :> t));
  e

let last_creation = ref 0.
let handle_mob_terrestre_creation dt =
  if (Cst.max_amount_of_mobs > (Hashtbl.length all_mobs)) && (dt -. !last_creation) > Cst.mob_spawn_timer then (
    last_creation := dt;

    let edge = Random.int 4 in
    let x, y =
      match edge with
      | 0 -> (* top *)
          (Random.int (Cst.window_width - 120) + 60, 30)
      | 1 -> (* bottom *)
          (Random.int (Cst.window_width - 120) + 60, Cst.window_height - 30)
      | 2 -> (* left *)
          (30, Random.int (Cst.window_height - 48) + 24)
      | _ -> (* right *)
          (Cst.window_width - 30, Random.int (Cst.window_height - 48) + 24)
    in

    let _ = create x y dt in ()
  )

let set_texture mob texture =
  let texture_handler = (Global.get ()).texture_handler in
  let texture = Option.value
    (Hashtbl.find_opt texture_handler texture)
    ~default: Texture.Raw.green
  in
  mob#texture#set texture
  
(* velocity / shooting / deaths *)
let update_mobs_turn () =
  let to_remove = ref [] in
  Hashtbl.iter (fun id (mob : Component_defs.mobTerrestre) ->
    if mob#getPv <= 0 then (
      (* Handles deaths *)
      to_remove := id :: !to_remove
    ) else (
      (* Update velocity : chaque mob se dirige vers le joueur le plus proche *)
      let glob = Global.get () in
      let open Vector in      
      
      let player1 = glob.player1 in 
      let player2 = glob.player2 in

      if (player1#is_dead) then (
        let player2_pos = player2#position#get in 
        let mob_pos = mob#position#get in 
        let new_vect = sub player2_pos mob_pos in
        let norma_vect = normalize new_vect in
        let new_velocity = mult 1.0 norma_vect in
        mob#velocity#set new_velocity
      
        ) else if (player2#is_dead) then (
        let player1_pos = player1#position#get in 
        let mob_pos = mob#position#get in 
        let new_vect = sub player1_pos mob_pos in
        let norma_vect = normalize new_vect in
        let new_velocity = mult 1.0 norma_vect in
        mob#velocity#set new_velocity

      ) else (
        let player1_pos = player1#position#get in 
        let player2_pos = player2#position#get in 
        let mob_pos = mob#position#get in 

        let dist1 = norm (sub player1_pos mob_pos) in
        let dist2 = norm (sub player2_pos mob_pos) in

        let nearest_player_pos = if dist1 <= dist2 then player1_pos else player2_pos in 
        
        let new_vect = sub nearest_player_pos mob_pos in
        let norma_vect = normalize new_vect in
        let new_velocity = mult 1.0 norma_vect in

        mob#velocity#set new_velocity;
      );

      if (mob#is_the_mob_shooting) then (
        Bullet.mob_create mob mob#getDmgPerBullet
      );

      let x = mob#velocity#get.x in 
      let y = mob#velocity#get.y in

      if abs_float x > abs_float y then (
        if x > 0. then
          set_texture mob Mob_right
        else
          set_texture mob Mob_left
      ) else (
        if y > 0. then
          set_texture mob Mob_bottom
        else
          set_texture mob Mob_top
      )
    )
  ) all_mobs;

  List.iter (fun id ->
    Global.new_augment_to_select := true;
    Global.kill_counter := !Global.kill_counter + 1;
    let mob = Hashtbl.find all_mobs id in
    Draw_system.unregister (mob :> drawable);
    Collide_system.unregister (mob :> collidable);
    Move_system.unregister (mob :> movable);
    Hashtbl.remove all_mobs id;
  ) !to_remove