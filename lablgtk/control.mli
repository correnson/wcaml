(** Basic Control Widgets *)

open Event
open Widget

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
