open Widget
open Event

(** Toplevel window *)

class toplevel : id:string -> ?title:string -> ?content:widget -> unit ->
object
  inherit Property.bundle
  inherit Widget.focus
  inherit Widget.visible
  method on_close : unit callback
  method set_title : string -> unit
  method set_saved : bool -> unit
  method set_content : widget -> unit 
    (** Fails if content has been already set. *)
end
