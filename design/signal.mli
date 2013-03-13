
(** {1 Signals and Handlers} *)

type 'a action = 'a -> unit
type 'a callback = 'a action -> unit

(** {1 Iterators} *)

val apply  : 'a action list -> 'a action
val option : 'a action -> 'a option action
val list   : 'a action -> 'a list action
val array  : 'a action -> 'a array action

class virtual ['a] handler :
object
  method virtual connect : 'a callback
  method on_event : unit callback
  method on_check : 'a -> bool callback
  method on_value : 'a -> unit callback
end    

class ['a] signal :
object
  inherit ['a] handler
  method connect : 'a callback
  method set_enabled : bool action
  method fire : 'a action
  method send : 'a -> unit action
end

class ['a] selector : 'a ->
object
  inherit ['a] signal
  method set : 'a action
  method get : 'a
  method send_to : 'a action -> unit action
end
