(* -------------------------------------------------------------------------- *)
(* --- Basic Control Widgets                                              --- *)
(* -------------------------------------------------------------------------- *)

open Event
open Widget

(* -------------------------------------------------------------------------- *)
(* ---  Labels                                                            --- *)
(* -------------------------------------------------------------------------- *)

type align = [ `Left | `Right | `Center ]
type style = [ `Label | `Title | `Descr ]

let xalign = function `Left -> 0.0 | `Right -> 1.0 | `Center -> 0.5

let set_font transform =
  let fr = ref None in
  fun widget ->
    let ft = match !fr with
      | Some ft -> ft
      | None -> 
	  let ft = Pango.Font.copy widget#misc#pango_context#font_description 
	  in transform ft ; fr := Some ft ; ft
    in widget#misc#modify_font ft
	 
let descr_font = set_font 
  (fun f -> Pango.Font.set_size f (Pango.Font.get_size f - 2))
  
let title_font = set_font
  (fun f -> Pango.Font.set_weight f `BOLD)

class label ?text ?(align=`Left) ?(style=`Label) () =
  let w = GMisc.label ?text ~xalign:(xalign align) () in
object
  inherit Port.widget w
  method set_text = w#set_text
  initializer match style with
    | `Label -> ()
    | `Title -> title_font w
    | `Descr -> descr_font w ; w#set_line_wrap true
end
