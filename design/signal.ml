(* -------------------------------------------------------------------------- *)
(* --- Signals & Selectors                                                --- *)
(* -------------------------------------------------------------------------- *)

type 'a action = 'a -> unit
type 'a callback = 'a action -> unit

let apply demon x = List.iter (fun f -> f x) demon

class virtual ['a] handler =
object(self)
  method virtual connect : ('a -> unit) -> unit
  method on_check v f = self#connect (fun e -> f (e=v))
  method on_value v f = self#connect (fun e -> if e=v then f ())
  method on_event f = self#connect (fun _ -> f ())
end    
	  
class ['a] signal =
object(self)
  val mutable enabled = true
  val mutable lock = false
  val mutable demon = []
  inherit ['a] handler
  method fire (x:'a) =
    if enabled && not lock then 
      try lock <- true ; apply demon x ; lock <- false
      with err -> lock <- false ; raise err
  method send x () = self#fire x
  method connect f = demon <- demon @ [f]
  method set_enabled e = enabled <- e
end

class ['a] selector default =
object(self)
  val mutable current : 'a = default
  inherit ['a] signal as s
  method get = current
  method set x = current <- x ; s#fire x
  method fire x = current <- x ; s#fire x
    (** Same as [set]. *)
  method send x () = current <- x ; s#fire x
    (** Delayed [set]. *)
  method send_to receiver () : unit = receiver current
    (** The action transmit the current value to receiver.
	When the selector value changes, so is the action. *)
end
