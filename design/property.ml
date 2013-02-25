(* -------------------------------------------------------------------------- *)
(* --- Properties Management                                              --- *)
(* -------------------------------------------------------------------------- *)

type 'a key = int

let kp = ref 0

let register () = incr kp ; !kp

class bundle =
object(self)
  val bundle : (int,Obj.t) Hashtbl.t = Hashtbl.create 31
  method id = Oo.id self
  method get_prop : 'a. 'a key -> 'a 
    = fun (k : 'a key) -> Obj.obj (Hashtbl.find bundle k)
  method set_prop : 'a. 'a key -> 'a -> unit
    = fun (k : 'a key) v -> Hashtbl.replace bundle k (Obj.repr v)
  method remove_prop : 'a. 'a key -> unit
    = fun (k : 'a key) -> Hashtbl.remove bundle k
end
