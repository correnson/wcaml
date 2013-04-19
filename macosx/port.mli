(** Cocoa Interface *)

(** {2 Callbacks} *)

module type ServiceId =
sig
  val name : string
  type link
  type signature
  val default : signature
end

module Service( S : ServiceId ) :
sig
  val register : S.link -> S.signature -> unit
  val remove : S.link -> unit
end

(** {2 Data and Collections} *)

(** All Objects are allocated in the autorelease pool. *)

type id (** NSObject *)

module NSString :
sig
  type t
  val id : t -> id
  external of_string : string -> t = "wcaml_nsstring_of_value"
  external to_string : t -> string = "wcaml_value_of_nsstring"
end

module NSArray :
sig
  type t
  val id : t -> id
  external create : int -> t
  external size : t -> int
  external get : t -> int -> id
  external add : t -> id -> unit
  external set : t -> int -> id -> unit
  val list : ('a -> id) -> 'a list -> t
end
