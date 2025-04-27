open Ecs

module Collide_system = System.Make    (Collide)
module Draw_system    = System.Make    (Draw)
module Augments_system= System.Make    (Augments) 
module Move_system    = System.Make    (Move)
module Wind_system    = System.Make    (Wind)
module End_screen     = System.Make    (End_screen)
module Menu_pause     = System.Make    (Menu_pause)