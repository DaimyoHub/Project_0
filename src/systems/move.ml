open Ecs
open Component_defs

type t = movable

let init _ = ()

let update _ el = 
  Seq.iter (fun (e : t) ->
    (*Gfx.debug "%s\n" e#name;
    Gfx.debug "x:%f | y:%f | z:%s \n" e#position#get.x e#position#get.y (match e#z_position#get with None -> "0" | _ -> "1");*)
    e#position#set
      @@ Vector.add e#position#get e#velocity#get;
    match e#z_position#get with 
    | None -> ()
    | Some f -> 
      let currentTime = Unix.gettimeofday () in   
      if (1.<currentTime-.f) then 
        e#z_position#set None
  ) el
