(** Cocoa Interface *)

(** {2 Callbacks} *)

module type NS_Callback =
sig
  type nsobject
  type signature
  val name : string
  val default : signature
end

module type ID_Callback =
sig
  type signature
  val name : string
  val default : signature
end

module type Callback =
sig
  type index
  type signature
  val default : signature
  val mem : index -> bool
  val bind : index -> signature -> unit
  val remove : index -> unit
end

module IDCallback( S : ID_Callback ) :
  Callback with type signature = S.signature
	  and type index = string

module NSCallback( S : NS_Callback ) : 
  Callback with type signature = S.signature
	  and type index = S.nsobject

(** {2 Data and Collections}
    All Objects are allocated in the autorelease pool. *)

val nil : 'a (** Cocoa object [nil] *)

module NSString :
sig
  type t
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
