(* -------------------------------------------------------------------------- *)
(* --- LablGTK Port Library                                               --- *)
(* -------------------------------------------------------------------------- *)

open Signal

let option f = function None -> () | Some x -> f x

let widget : GObj.widget Property.key = Property.register ()

class widget (w : #GObj.widget) =
object(self)
  inherit Property.bundle
  method coerce = (self :> Widget.widget)
  method set_enabled = w#misc#set_sensitive
  initializer 
    begin
      self#set_prop widget w#coerce ;
      ignore (w#misc#connect#unrealize ~callback:self#release) ;
    end
end

