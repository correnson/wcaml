(** Common Types and Constants *)

open Event

(** On-screen graphical user interface element *)
class type widget = 
object
  inherit Property.bundle
  method set_enabled : bool action
  method widget : widget (** Returns self *)
  method debug : unit action
end

(** Widget with user interaction *)
class type control =
object
  inherit widget
  method control : control (** Returns self *)
  method set_tooltip : string -> unit
end

(** Some window's part that embed controls or sub-panes *)
class type pane =
object
  inherit Property.bundle
  method pane : pane (** Returns self *)
  method request_focus : unit action
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

(** Colors *)

type color = 
    [
    | `Black
    | `Grey
    | `Dark
    | `White
    | `Green
    | `Orange
    | `Red
    | `Blue
    | `Yellow
    | `Violet
    ]

(** Icons *)

type icon = 
    [
    | `Warning
    | `Error
    | `Execute
    | `Yes
    | `No
    | `None
    | `Trash
    | `Image of string
    ]
