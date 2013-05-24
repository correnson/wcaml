(* -------------------------------------------------------------------------- *)
(* --- LablGTK Port Library                                               --- *)
(* -------------------------------------------------------------------------- *)

open Event

type layout = Fixed | Field | Boxed

let hexpand = function Fixed -> false | Field -> true | Boxed -> true
let vexpand = function Fixed -> false | Field -> false | Boxed -> true

let widget : GObj.widget Property.key = Property.register ()
let layout : layout Property.key = Property.register ()

class pane (w : #GObj.widget) =
object(self)
  inherit Property.bundle
  method pane = (self :> Widget.pane)
  method request_focus = w#misc#grab_focus
  initializer self#set_prop widget (w :> GObj.widget)
end

class widget (ly : layout) (w : #GObj.widget) =
object(self)
  inherit Property.bundle
  method widget = (self :> Widget.widget)
  method debug = ()
  method set_enabled = w#misc#set_sensitive
  initializer self#set_prop widget (w :> GObj.widget)
  initializer self#set_prop layout ly
end

class control ?tooltip layout (w : #GObj.widget) =
object(self)
  inherit widget layout w
  method control = (self :> Widget.control)
  method set_tooltip = w#misc#set_tooltip_text
  initializer Event.option w#misc#set_tooltip_text tooltip
end

let set_font transform : #GObj.widget -> unit =
  let fr = ref None in
  fun widget ->
    let ft = match !fr with
      | Some ft -> ft
      | None -> 
	  let ft = Pango.Font.copy widget#misc#pango_context#font_description 
	  in transform ft ; fr := Some ft ; ft
    in widget#misc#modify_font ft
	 
let descr_font w = 
  set_font (fun f -> Pango.Font.set_size f (Pango.Font.get_size f - 2)) w
  
let title_font w = 
  set_font (fun f -> Pango.Font.set_weight f `BOLD) w

let get_widget (w : #Property.bundle) = w#get_prop widget
let get_layout (w : #Property.bundle) = w#get_prop layout
