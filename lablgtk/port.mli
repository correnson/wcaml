(* -------------------------------------------------------------------------- *)
(* --- LablGTK Library                                                    --- *)
(* -------------------------------------------------------------------------- *)

val appname : string ref
val widget : GObj.widget Property.key

class widget : #GObj.widget -> Widget.widget
