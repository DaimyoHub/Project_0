open Component_defs

type idx = One | Two

type tag += Player of idx * player

type tag += Portal of idx * (int * int) * portal

type tag += Mappix of z_position

type tag += HWall of wall | VWall of int * wall
