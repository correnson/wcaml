(** Pane Widgets *)

open Event
open Widget

(** Simple form layout.
    
    The pane consists of a vertical stack of elements. Each row is
    occupied by a control with an optional label. Labels are
    right-aligned to controls.
    
    Controls in a row are left-aligned and extends when appropriate to
    the right edge of the form. It is possible to layout several
    controls in a row, horizontally or vertically.
    
    The form is typically filled in a left-to-right, downward order.
    Sections are bold labels that cross the form
    horizontally. Separations inserts extra horizontal space,
    typically for grouping controls into sub-sections.
*)
class form : unit ->
object
  inherit Widget.pane
  method add_separation : unit
  method add_section : string -> unit
  method add_control : ?label:string -> Widget.widget -> unit
  method add_hbox : ?label:string -> Widget.widget list -> unit
  method add_vbox : ?label:string -> Widget.widget list -> unit
  method add_pane : ?label:string -> Widget.pane -> unit
end

(** Horizontal left-aligned stack. *)
class hbox : Widget.widget list -> Widget.pane

(** Vertical top-aligned stack. *)
class vbox : Widget.widget list -> Widget.pane

(** An horizontal split pane tuned 
    for a (left) side pane and a (right) main content. 
    The identifier is used for storing the user's preferred size.
*)
class sidebar : id:string -> side:Widget.pane -> pane:Widget.pane -> Widget.pane

(** Horizontal split pane. 
    The identifier is used for storing the user's preferred ratio.
*)
class hsplit : id:string ->
  left:Widget.pane -> right:Widget.pane -> Widget.pane

(** Vertical split pane. 
    The identifier is used for storing the user's preferred ratio.
*)
class vsplit : id:string ->
  top:Widget.pane -> bottom:Widget.pane -> Widget.pane

