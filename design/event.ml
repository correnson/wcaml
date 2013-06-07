(* -------------------------------------------------------------------------- *)
(* --- Signals & Selectors                                                --- *)
(* -------------------------------------------------------------------------- *)

type 'a action = 'a -> unit
type 'a callback = 'a action -> unit

let apply demon x = List.iter (fun f -> f x) demon
let option f = function None -> () | Some x -> f x
let array = Array.iter
let list = List.iter

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
  method remove f = demon <- List.filter (fun g -> g != f) demon
  method fire (x:'a) : unit =
    if enabled && not lock then 
      try lock <- true ; apply demon x ; lock <- false
      with err -> lock <- false ; raise err
  method emit x () = self#fire x
  method connect f = demon <- demon @ [f]
  method set_enabled e = enabled <- e
  method transmit_to : 'b. ((<fire : 'a action ; ..> as 'b) -> unit) =
    fun receiver -> self#connect receiver#fire
end

class ['a] selector default =
object(self)
  val mutable current : 'a = default
  inherit ['a] signal as s
  method get = current
  method set x = self#fire x
  method! fire x = current <- x ; s#fire x
  method send_to receiver () : unit = receiver current
  method mirror_to : 'b. ((<fire : 'a action ; ..> as 'b) -> unit) =
    fun receiver -> self#connect receiver#fire ; receiver#fire current
end

class ['a] state ?(equal=(=)) default =
object
  inherit ['a] selector default as super
  method! fire x =
    if not (equal x current) then super#fire x
end

let mirror_signals (a : 'a #signal) (b : 'a #signal) =
  begin
    a#transmit_to b ; 
    b#transmit_to a ;
  end

let mirror_values ~(master : 'a #selector) ~(client : 'a #selector) =
  begin
    client#transmit_to master ;
    master#mirror_to client ;
  end
