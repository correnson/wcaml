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

class ['a] cell id =
object
  val mutable content : 'a option = None
  method set x = match content with
    | None -> content <- Some x
    | Some _ -> failwith (Printf.sprintf "Cell '%s' already set" id)
  method get = match content with
    | None -> failwith (Printf.sprintf "Cell '%s' is empty" id)
    | Some x -> x
  method release = content <- None
end

