(* -------------------------------------------------------------------------- *)
(* --- User Preferences                                                   --- *)
(* -------------------------------------------------------------------------- *)

open Port
open Event

external get_user_string : NSString.t -> NSString.t 
  = "wcaml_get_user_string"

external set_user_string : NSString.t -> NSString.t -> unit 
  = "wcaml_set_user_object"

external get_user_array  : NSString.t -> NSString.t NSArray.t
  = "wcaml_get_user_array"

external set_user_array  : NSString.t -> NSString.t NSArray.t -> unit
  = "wcaml_set_user_object"
