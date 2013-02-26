(* -------------------------------------------------------------------------- *)
(* --- LablGTK Library                                                    --- *)
(* -------------------------------------------------------------------------- *)

val option : ('a -> unit) -> 'a option -> unit
val widget : GObj.widget Property.key

class widget : #GObj.widget -> Widget.widget
