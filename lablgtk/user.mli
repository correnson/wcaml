(** User Preferences *)

open Signal

type 'a preference = id:string -> default:'a -> 'a selector

(** {2 Basics} *)

val int   : int preference 
val float : float preference
val string : string preference

(** {2 Lists} *)

val int_list : int list preference
val float_list : float list preference
val string_list : string list preference

(** {2 Arrays} *)

val int_array : int array preference
val float_array : float array preference
val string_array : string array preference

(** {2 Generic} *)

val create : 
  encode:('a -> string) ->
  decode:(string -> 'a) ->
  'a preference

val create_list : 
  encode:('a -> string) ->
  decode:(string -> 'a) ->
  'a list preference

val create_array : 
  encode:('a -> string) ->
  decode:(string -> 'a) ->
  'a array preference
