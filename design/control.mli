(** Basic Control Widgets *)

open Event
open Widget

(** {2 Labels} *)

type align = [ `Left | `Right | `Center ]
type style = [ `Label | `Title | `Descr ]
    (** Use [`Title] for a bold label, and [`Descr] for long-text description. *)

(** Non-editable text 
    @param text default is [""]
    @param align default is [`Left]
    @param style default is [`Label]
*)
class label : ?text:string -> ?align:align -> ?style:style -> unit ->
object
  inherit Widget.widget
  method set_text : string -> unit
end

(** {2 Buttons} *)

class button : ?label:string -> ?tooltip:string -> ?callback:unit action -> unit ->
object
  inherit Widget.control
  inherit [unit] Event.signal
  method set_label : string -> unit
end
