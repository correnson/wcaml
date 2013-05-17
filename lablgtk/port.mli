(* -------------------------------------------------------------------------- *)
(* --- LablGTK Library                                                    --- *)
(* -------------------------------------------------------------------------- *)

type layout = Fixed | Field | Boxed

val hexpand : layout -> bool
val vexpand : layout -> bool

class pane : #GObj.widget -> Widget.pane
class widget : layout -> #GObj.widget -> Widget.widget
class control : ?tooltip:string -> layout -> #GObj.widget -> Widget.control

val descr_font : #GObj.widget -> unit
val title_font : #GObj.widget -> unit

val get_widget : #Property.bundle -> GObj.widget
val get_layout : #Property.bundle -> layout
