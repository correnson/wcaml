open Widget
open Signal

class main : id:string -> ?title:string -> ?content:widget -> unit ->
object
  inherit widget
  inherit focus
  inherit visible
  method set_title : string -> unit
  method set_saved : bool -> unit
  method set_content : widget -> unit (** Fails if content has been already set. *)
end
