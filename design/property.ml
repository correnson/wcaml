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

  method private access : 'a. 'a key -> 'a =
    fun (k : 'a key) -> Obj.obj (Hashtbl.find bundle k)

  method get_prop 
    : 'a. (?default:'a -> ?exn:exn -> 'a key -> 'a)
    = fun ?default ?(exn=Not_found) k ->
      try self#access k
      with Not_found ->
	match default with
	  | None -> raise exn
	  | Some e -> e

  method set_prop 
    : 'a. 'a key -> 'a -> unit
    = fun k v -> Hashtbl.replace bundle k (Obj.repr v)
  method remove_prop 
    : 'a. 'a key -> unit
    = fun k -> Hashtbl.remove bundle k
  method get_list 
    : 'a. 'a list key -> 'a list
    = fun k -> self#get_prop ~default:[] k
  method append_list 
    : 'a. 'a list key -> 'a -> unit
    = fun k e -> self#set_prop k (self#get_list k @ [e])
  method add_list 
    : 'a. 'a list key -> 'a -> unit
    = fun k e -> self#set_prop k (e :: self#get_list k)
end

