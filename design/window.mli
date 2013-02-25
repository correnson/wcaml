open Widget
open Signal

class main : ?id:string -> ?title:string -> ?content:widget -> unit ->
object
  inherit widget
  method set_title : string -> unit
  method set_saved : bool -> unit
  method focus : bool signal
  method request_focus : unit -> unit (** Makes also visible. *)
  method set_visible : bool -> unit (** Does not request focus (use [request_focus] instead). *)
  method set_content : widget -> unit (** Fails if content has been already set. *)
  method release : unit -> unit
end
