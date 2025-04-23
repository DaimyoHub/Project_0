type t =
    Image of Gfx.surface
  | Color of Gfx.color

module Raw = struct
  let black = Color (Gfx.color 0 0 0 255)
  let white = Color (Gfx.color 255 255 255 255)
  let red = Color (Gfx.color 255 0 0 255)
  let green = Color (Gfx.color 0 255 0 255)
  let blue = Color (Gfx.color 0 0 255 255)
  let purple = Color (Gfx.color 255 0 255 255)
  let yellow = Color (Gfx.color 255 255 0 255)
  let transparent = Color (Gfx.color 0 0 0 0)
end

let draw ctx dst pos box src =
  let x = int_of_float pos.Vector.x in
  let y = int_of_float pos.Vector.y in
  let Rect.{width;height} = box in
  match src with
    Image img -> Gfx.blit_scale ctx dst img x y width height
  | Color c ->
    Gfx.set_color ctx c;
    Gfx.fill_rect ctx dst x y width height

type kind =
  | Ground
  | Wall_1
  | Wall_2
  | Wall_3

  | Focused_ground

  | Player_1_right
  | Player_1_left
  | Player_1_bottom
  | Player_1_top

  | Player_2_right
  | Player_2_left
  | Player_2_bottom
  | Player_2_top

  | Player_1_right_jump_0
  | Player_1_right_jump_1
  | Player_2_right_jump_0
  | Player_2_right_jump_1
  | Player_1_left_jump_0
  | Player_1_left_jump_1
  | Player_2_left_jump_0
  | Player_2_left_jump_1
  | Player_1_bottom_jump_0
  | Player_1_bottom_jump_1
  | Player_2_bottom_jump_0
  | Player_2_bottom_jump_1
  | Player_1_top_jump_0
  | Player_1_top_jump_1
  | Player_2_top_jump_0
  | Player_2_top_jump_1

  | Portal
