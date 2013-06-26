(* -------------------------------------------------------------------------- *)
(* --- Basic Control Widgets                                              --- *)
(* -------------------------------------------------------------------------- *)

open Event
open Widget

(* -------------------------------------------------------------------------- *)
(* ---  Labels                                                            --- *)
(* -------------------------------------------------------------------------- *)

let xalign = function `Left -> 0.0 | `Right -> 1.0 | `Center -> 0.5

class label ?text ?(align=`Left) ?(style=`Label) () =
  let w = GMisc.label ?text ~xalign:(xalign align) () in
object
  inherit Port.widget Port.Field w
  method set_text = w#set_text
  initializer match style with
    | `Label -> ()
    | `Title -> Port.title_font w
    | `Descr -> Port.descr_font w ; w#set_line_wrap true
    | `Verbatim -> Port.verb_font w
end

(* -------------------------------------------------------------------------- *)
(* ---  Button                                                            --- *)
(* -------------------------------------------------------------------------- *)

class button ?label ?tooltip ?callback () =
  let w = GButton.button ?label () in
object
  inherit Port.control ?tooltip Port.Fixed w as control
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
  inherit Port.control ?tooltip Port.Field w as control
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

(* -------------------------------------------------------------------------- *)
(* ---  Radios                                                            --- *)
(* -------------------------------------------------------------------------- *)

let groups : (int,Gtk.radio_button Gtk.group) Hashtbl.t = Hashtbl.create 63
let set_group (r : GButton.radio_button) (s : _ selector) update : unit =
  let id = Oo.id s in
  s#on_event update ;
  begin
    try r#set_group (Hashtbl.find groups id)
    with Not_found -> Hashtbl.add groups id r#group
  end ; update ()

class ['a] radio ?label ?tooltip ?group ?value () =
  let w = GButton.radio_button ?label () in
object(self)
  val mutable option : 'a option = value
  val mutable select : 'a selector option = None
  inherit Port.control ?tooltip Port.Field w as control
  method set_label = w#set_label
  method set_group g = select <- Some g ; set_group w g self#update
  method set_value v = option <- Some v ; self#update ()
  method private update () =
    match select , option with
      | Some g , Some v when v = g#get -> w#set_active true
      | _ -> w#set_active false
  method private clicked () =
    match select , option with
      | Some g , Some v -> g#set v
      | _ -> ()
  initializer
    begin
      w#misc#set_can_focus false ;
      w#set_focus_on_click false ;
      Event.option self#set_group group ;
      ignore (w#connect#toggled ~callback:self#clicked) ;
    end
end
