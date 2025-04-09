
open Ecs

module Collision_system = System.Make(Collision)

module Draw_system = System.Make(Draw)

module Menu_system = System.Make(Menu) 

module Move_system = System.Make(Move)