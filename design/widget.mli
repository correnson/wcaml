(** {1 Common Types and Constants} *)

class type widget = 
object
  inherit Property.bundle
  method set_enabled : bool -> unit
end
