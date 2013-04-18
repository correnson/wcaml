(* -------------------------------------------------------------------------- *)
(* --- LablGTK Port Library                                               --- *)
(* -------------------------------------------------------------------------- *)

open Signal

let appname = ref "wcaml"
let widget : GObj.widget Property.key = Property.register ()

class widget (w : #GObj.widget) =
object(self)
  inherit Property.bundle
  method coerce = (self :> Widget.widget)
  method set_enabled = w#misc#set_sensitive
end

