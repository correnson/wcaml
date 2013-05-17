(** Common Types and Constants *)

open Event

(** On-screen graphical user interface element *)
class type widget = 
object
  inherit Property.bundle
  method coerce : widget (** Returns self *)
  method set_enabled : bool action
end

(** Focus capabilities *)
class type focus =
object
  method focus : bool signal
  method on_focus : bool callback
  method request_focus : unit action
end

(** Visible capabilities *)
class type visible =
object
  method set_visible : bool action
  method show : unit action
  method hide : unit action
end

(** Widget with tooltip *)
class type control =
object
  inherit widget
  method set_tooltip : string -> unit
end

(** Some window's part that embed controls or sub-panes *)
class type pane =
object
  inherit widget
  inherit focus
end
