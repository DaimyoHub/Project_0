open System_defs
open Component_defs
open Ecs

(**
   Game.prepare_config window ctx texture_handler

   Constructs the configuration of the game.
 *)
let prepare_config window ctx texture_handler =
  let _walls = Wall.create () in
  let map = Map.create () in
  let player1, player2 = Player.create_both map in
  let particles = Wind_particle.create () in

  Global.(set {
    window;
    ctx;
    map;
    player1; player2;
    waiting = 1;
    state = Game;
    texture_handler;
    portal1 = None;
    portal2 = None;
    particles;
  })

(**
   Game.update dt

   It is the function that is called at each iteration of the game loop. It 
   updates every systems and particular aspects of some entities.
 *)
let update dt =
  let () = Input.handle_input () in

  Player.set_focused_map_pixel ();
  Player.handle_jump_animation ();
  Player.handle_shooting ();
  MobTerrestre.update_mobs_turn ();
  MobTerrestre.handle_mob_terrestre_creation dt;

  let (p1_death, p2_death) = Player.handle_death () in 
  if p1_death then 
  (
    Input.unregister "z";
    Input.unregister "q";
    Input.unregister "d";
    Input.unregister "s";
    Input.unregister "e";
    Input.unregister "a";
    Input.unregister "w"
  );
  if p2_death then 
  (
    Input.unregister "j";
    Input.unregister "l";
    Input.unregister "k";
    Input.unregister "i";
    Input.unregister "n";
    Input.unregister "o";
    Input.unregister "u"
  ); 

  let reversed = (mod_float dt Cst.wind_timing_swap)>=(Cst.wind_timing_swap/.2.) in
  (if (reversed) then
    Wind_particle.respawn_particles_at_left ()
  else
    Wind_particle.respawn_particles_at_right ()
  );

  let _ = 
    match Global.get_game_state () with
    | Game -> begin
        Move_system.update dt;
        Collide_system.update dt;
        Draw_system.update dt;
        Wind_system.update dt;
      end
    | Menu -> Menu_system.update dt
  in

  None

(**
   Game.set_textures particles

   Sets the textures to all the entities in the good order.
 *)
let set_textures particles =
  let _ = Map.set_texture (Global.get ()).map in

  let open Player in
  set_texture (player1 ()) Texture.Player_1_right;
  set_texture (player2 ()) Texture.Player_2_left;

  Wind_particle.set_texture (Global.get ()).particles

(**
   Game.run ()

   Runs the game.
 *)
let run () =
  let window_spec =
    Format.sprintf "game_canvas:%dx%d:" Cst.window_width Cst.window_height
  in
  let window = Gfx.create  window_spec in
  let ctx = Gfx.get_context window in

  let tile_set_r = Gfx.load_file "/resources/files/tile_set.txt" in
  Gfx.main_loop
    (fun _ -> Gfx.get_resource_opt tile_set_r)
    (fun tile_set -> 
      let images_and_names = Texture_loader.parse_tile_set ctx tile_set in
      Gfx.main_loop
        (fun _ -> Texture_loader.get_resources images_and_names)
        (fun images ->
          let th = Hashtbl.create 10 in
          Texture_loader.prepare_texture_handler th images;
          prepare_config window ctx th;
          set_textures ();
          Gfx.main_loop update (fun () -> ())
        ))
