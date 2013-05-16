(* -------------------------------------------------------------------------- *)
(* --- LablGTK Port Library                                               --- *)
(* -------------------------------------------------------------------------- *)

open Event

let widget : GObj.widget Property.key = Property.register ()

class widget (w : #GObj.widget) =
object(self)
  inherit Property.bundle
  method coerce = (self :> Widget.widget)
  method set_enabled = w#misc#set_sensitive
  initializer self#set_prop widget (w :> GObj.widget)
end

class control ?tooltip (w : #GObj.widget) =
object
  inherit widget w
  method set_tooltip = w#misc#set_tooltip_text
  initializer Event.option w#misc#set_tooltip_text tooltip
end
