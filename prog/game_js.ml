let () =
  let debug = Gfx.open_formatter "console" in
  let _ = Gfx.set_debug_formatter debug in
  Gfx.debug "bite";
  Game.run ()