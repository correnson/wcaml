
(** Properties Management *)

type 'a key
val register : unit -> 'a key

class bundle :
object
  method id : int
  method get_prop : 'a. 
    ?default: 'a -> ?exn:exn -> 'a key -> 'a
    (** Default exception if [Not_found]. *)
  method set_prop : 'a. 'a key -> 'a -> unit
  method get_list : 'a. 'a list key -> 'a list (** Defaults to empty list *)
  method add_list : 'a. 'a list key -> 'a -> unit
  method append_list : 'a. 'a list key -> 'a -> unit
  method remove_prop : 'a. 'a key -> unit
end
