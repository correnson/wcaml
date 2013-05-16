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

(* -------------------------------------------------------------------------- *)
(* ---  Button                                                            --- *)
(* -------------------------------------------------------------------------- *)

class button ?label ?tooltip ?callback () =
  let w = GButton.button ?label () in
object
  inherit Port.control ?tooltip w as control
  inherit! [unit] Event.signal as signal
  method! set_enabled e = control#set_enabled e ; signal#set_enabled e
  method set_label = w#set_label
  initializer 
    begin
      w#misc#set_can_focus false ;
      w#set_focus_on_click false ;
      Event.option signal#connect callback ;
      ignore (w#connect#clicked ~callback:signal#fire) ;
    end
end

(* -------------------------------------------------------------------------- *)
(* ---  Check Box                                                         --- *)
(* -------------------------------------------------------------------------- *)

class checkbox ?label ?tooltip ?(value=false) () =
  let w = GButton.check_button ?label () in
object(self)
  inherit Port.control ?tooltip w as control
  inherit! [bool] Event.selector value as state
  method! set_enabled e = control#set_enabled e ; state#set_enabled e
  method! set e = w#set_active e ; state#set e
  method private updated () = state#set w#active
  method set_label = w#set_label
  initializer
    begin
      w#misc#set_can_focus false ;
      w#set_focus_on_click false ;
      w#set_active value ;
      ignore (w#connect#toggled ~callback:self#updated) ;
    end
end
