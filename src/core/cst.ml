let window_width = 800
let window_height = 600

let j_width = 24
let j_height = 24

let j1_x = 20
let j1_y = 20

let j2_x = 20
let j2_y = 60
let j1_color = Texture.Raw.blue
let j2_color = Texture.Raw.red

let j1_v_up = Vector.{ x = 0.0; y = -2.0 }
let j1_v_down = Vector.sub Vector.zero j1_v_up
let j1_v_left = Vector.{ x = -2.0; y = 0.0 }
let j1_v_right = Vector.sub Vector.zero j1_v_left

let mobTerr_v_up = Vector.{ x = 0.0; y = -1.0 }
let mobTerr_v_down = Vector.sub Vector.zero j1_v_up
let mobTerr_v_left = Vector.{ x = -1.0; y = 0.0 }
let mobTerr_v_right = Vector.sub Vector.zero j1_v_left

let j2_v_up = Vector.{ x = 0.0; y = -2.0 }
let j2_v_down = Vector.sub Vector.zero j2_v_up
let j2_v_left = Vector.{ x = -2.0; y = 0.0 }
let j2_v_right = Vector.sub Vector.zero j2_v_left

let ball_size = 24
let ball_color = Texture.Raw.red

let ball_v_offset = window_height / 2 - ball_size / 2
let ball_left_x = 128 + ball_size / 2
let ball_right_x = window_width - ball_left_x - ball_size

let wall_thickness = 24

let hwall_width = window_width
let hwall_height = wall_thickness
let hwall1_x = 0
let hwall1_y = 0
let hwall2_x = 0
let hwall2_y = window_height -  wall_thickness
let hwall_color = Texture.Raw.black

let vwall_width = wall_thickness - 1
let vwall_height = window_height - 2 * wall_thickness
let vwall1_x = 0
let vwall1_y = wall_thickness
let vwall2_x = window_width - wall_thickness
let vwall2_y = vwall1_y
let vwall_color = Texture.Raw.black

let exit_x = 400
let exit_y = 400
let exit_color = Texture.Raw.purple
let exit_width = 35
let exit_height = 35

let font_name = if Gfx.backend = "js" then "monospace" else "resources/images/monospace.ttf"
let font_color = Gfx.color 0 0 0 255

let wind_timing_swap = 10000.

let mobTerrestreHeight = 21
let mobTerrestreWidth = 21

let mobTerrestreVelocity = Vector.zero

let mob_spawn_timer = 6000.

let max_time = 180. (* length of the game in seconds *)

let max_amount_of_mobs = 5