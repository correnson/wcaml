(** Cocoa Interface *)

(** {2 Callbacks} *)

module type ServiceId =
sig
  val name : string
  type nsobject
  type signature
  val default : signature
end

module Service( S : ServiceId ) :
sig
  val register : S.nsobject -> S.signature -> unit
  val remove : S.nsobject -> unit
end

(** {2 Data and Collections}
    All Objects are allocated in the autorelease pool. *)

module NSString :
sig
  type t
  val nil : t
  external of_string : string -> t = "wcaml_nsstring_of_value"
  external to_string : t -> string = "wcaml_value_of_nsstring"
end

module NSArray :
sig
  type 'a t
  external init : int -> 'a t              = "wcaml_nsarray_init"
  external count : 'a t -> int             = "wcaml_nsarray_count"
  external get : 'a t -> int -> 'a         = "wcaml_nsarray_get"
  external add : 'a t -> 'a -> unit        = "wcaml_nsarray_add"
  external set : 'a t -> int -> 'a -> unit = "wcaml_nsarray_set"
  val of_list : 'a list -> 'a t
  val to_list : 'a t -> 'a list
  val of_array : 'a array -> 'a t
  val to_array : 'a t -> 'a array
end

(** {2 Views} *)

module NSView :
sig
  type t
  val key : t Property.key
  val coerce : #Widget.widget -> t
end
