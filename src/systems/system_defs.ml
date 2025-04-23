open Ecs

module Collide_system = System.Make (Collide)
module Draw_system    = System.Make    (Draw)
module Menu_system    = System.Make    (Menu) 
module Move_system    = System.Make    (Move)
module Wind_system    = System.Make    (Wind)
