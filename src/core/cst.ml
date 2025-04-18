(*
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
V                               V
V  1                         2  V
V  1 B                       2  V
V  1                         2  V
V  1                         2  V
V                               V
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
*)


let window_width = 800
let window_height = 600

let j_width = 24
let j_height = 24

let j1_x = 20
let j1_y = 20

let j2_x = 20
let j2_y = 60
let j1_color = Texture.blue
let j2_color = Texture.red

let j1_v_up = Vector.{ x = 0.0; y = -3.0 }
let j1_v_down = Vector.sub Vector.zero j1_v_up
let j1_v_left = Vector.{ x = -3.0; y = 0.0 }
let j1_v_right = Vector.sub Vector.zero j1_v_left

let j2_v_up = Vector.{ x = 0.0; y = -3.0 }
let j2_v_down = Vector.sub Vector.zero j2_v_up
let j2_v_left = Vector.{ x = -3.0; y = 0.0 }
let j2_v_right = Vector.sub Vector.zero j2_v_left

let ball_size = 24
let ball_color = Texture.red

let ball_v_offset = window_height / 2 - ball_size / 2
let ball_left_x = 128 + ball_size / 2
let ball_right_x = window_width - ball_left_x - ball_size

let wall_thickness = 2

let hwall_width = window_width
let hwall_height = wall_thickness
let hwall1_x = 0
let hwall1_y = 0
let hwall2_x = 0
let hwall2_y = window_height -  wall_thickness
let hwall_color = Texture.green

let vwall_width = wall_thickness
let vwall_height = window_height - 2 * wall_thickness
let vwall1_x = 0
let vwall1_y = wall_thickness
let vwall2_x = window_width - wall_thickness
let vwall2_y = vwall1_y
let vwall_color = Texture.yellow

let exit_x = 400
let exit_y = 400
let exit_color = Texture.purple
let exit_width = 35
let exit_height = 35

let font_name = if Gfx.backend = "js" then "monospace" else "resources/images/monospace.ttf"
let font_color = Gfx.color 0 0 0 255
