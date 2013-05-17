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

class checkbox : ?label:string -> ?tooltip:string -> ?value:bool -> unit ->
object
  inherit Widget.control
  inherit [bool] Event.selector
  method set_label : string -> unit
end

class ['a] radio : 
  ?label:string -> ?tooltip:string -> 
  ?group:'a selector -> ?value:'a -> unit ->
object
  inherit Widget.control
  method set_label : string -> unit
  method set_group : 'a selector -> unit
  method set_value : 'a -> unit
end
