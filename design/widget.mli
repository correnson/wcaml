(** {1 Common Types and Constants} *)

open Signal

class type widget = 
object
  inherit Property.bundle
  method set_enabled : bool action
end

class type focus =
object
  method focus : bool signal
  method request_focus : unit action
end

class type visible =
object
  method visible : bool signal
  method set_visible : bool action
  method show : unit action
  method hide : unit action
end
