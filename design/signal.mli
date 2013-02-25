
(** {1 Signals and Handlers} *)
	  
type 'a callback = ('a -> unit) -> unit

class virtual ['a] handler :
object
  method virtual connect : ('a -> unit) -> unit
  method on_event : unit callback
  method on_check : 'a -> bool callback
  method on_value : 'a -> unit callback
end    

class ['a] signal :
object
  inherit ['a] handler
  method connect : 'a callback
  method set_enabled : bool -> unit
  method fire : 'a -> unit
end

class ['a] selector : 'a ->
object
  inherit ['a] signal
  method set : 'a -> unit
  method get : 'a
  method send : 'b. ('a -> 'b) -> unit -> 'b
end
