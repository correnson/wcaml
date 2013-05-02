open Widget
open Event

(** Application Windows *)

(** Toplevel window.
    @param id Identifier of the window (unique)
    @param title Displayed title (default [""])
    @param content Window content (default empty)
    @param show Initial visibility (default [true])
    @param focus Request focus for the window (default [false], 
                 except for the first one).
*)
class toplevel : 
  id:string -> 
  ?title:string ->      
  ?content:widget ->    
  ?show:bool ->         
  ?focus:bool -> unit -> 
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
