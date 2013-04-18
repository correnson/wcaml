(* -------------------------------------------------------------------------- *)
(* --- Parser for User Preferences                                        --- *)
(* -------------------------------------------------------------------------- *)

val parse : (string -> string list -> unit) -> string -> unit
val dump : ((string -> string list -> unit) -> unit) -> string -> unit
