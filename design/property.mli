
(** {1 Properties Management} *)

type 'a key
val register : unit -> 'a key

class bundle :
object
  method id : int
  method get_prop : 'a. 'a key -> 'a
  method set_prop : 'a. 'a key -> 'a -> unit
  method remove_prop : 'a. 'a key -> unit
  method release : unit -> unit
  method on_release : (unit -> unit) -> unit
end
