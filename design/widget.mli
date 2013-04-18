(** {1 Common Types and Constants} *)

open Event

class type widget = 
object
  inherit Property.bundle
  method coerce : widget (** Returns self *)
  method set_enabled : bool action
end

class type focus =
object
  method focus : bool signal
  method on_focus : bool callback
  method request_focus : unit action
end

class type visible =
object
  method visible : bool signal
  method on_visible : bool callback
  method set_visible : bool action
  method show : unit action
  method hide : unit action
end
