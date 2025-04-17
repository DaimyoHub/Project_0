open Ecs
open Component_defs

type t = drawable

let init _ = ()

let white = Gfx.color 255 255 255 255

let black = Gfx.color 0 0 0 255


let quick_sort to_int seq =
  let arr = Array.of_seq seq in

  let swap a i j =
    let tmp = a.(i) in
    a.(i) <- a.(j);
    a.(j) <- tmp
  in

  let rec sort a low high =
    if low < high then begin
      let p = partition a low high in
      sort a low p;
      sort a (p + 1) high
    end

  and partition a low high =
    let pivot = a.((low + high) / 2) in
    let i = ref (low - 1) in
    let j = ref (high + 1) in
    while true do
      i := !i + 1;
      while to_int a.(!i) < to_int pivot do
        i := !i + 1
      done;
      j := !j - 1;
      while to_int a.(!j) > to_int pivot do
        j := !j - 1
      done;
      if !i >= !j then
        exit !j;
      swap a !i !j;
    done;
    !j 
  in

  sort arr 0 (Array.length arr - 1);
  Array.to_seq arr

let sort_entities_by_z entities =
  quick_sort (fun e -> 
    match e#z_position#get with
    | Some i -> int_of_float i
    | None -> 0) entities

let update _dt el =
  let Global.{window;ctx;_} = Global.get () in
  let surface = Gfx.get_surface window in
  let ww, wh = Gfx.get_context_logical_size ctx in
  Gfx.set_color ctx black;
  Gfx.fill_rect ctx surface 0 0 ww wh;

  Seq.iter (fun (e:t) ->
    if e#tag#get = Map_pixel_tag.Mappix then
      let pos = e#position#get in
      let box = e#box#get in
      let txt = e#texture#get in
      Texture.draw ctx surface pos box txt
    ) el;

  Seq.iter (fun (e:t) ->
    if e#tag#get <> Map_pixel_tag.Mappix then
      let pos = e#position#get in
      let box = e#box#get in
      let txt = e#texture#get in
      Texture.draw ctx surface pos box txt
    ) el;

  Gfx.commit ctx
