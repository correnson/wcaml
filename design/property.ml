(* -------------------------------------------------------------------------- *)
(* --- Properties Management                                              --- *)
(* -------------------------------------------------------------------------- *)

type 'a key = int

let kp = ref 0
let register () = incr kp ; !kp

module H :
sig
  type t
  val create : unit -> t
  val get_prop : t -> ?default:'a -> ?exn:exn -> 'a key -> 'a
  val set_prop : t -> 'a key -> 'a -> unit
  val remove_prop : t -> 'a key -> unit
  val get_list : t -> 'a list key -> 'a list
  val add_list : t -> 'a list key -> 'a -> unit
  val append_list : t -> 'a list key -> 'a -> unit
end =
struct
  type t = (int,Obj.t) Hashtbl.t 
  let create () : t = Hashtbl.create 31

  let get_prop bundle ?default ?(exn=Not_found) k =
    try Obj.obj (Hashtbl.find bundle k)
    with Not_found ->
      match default with
	| None -> raise exn
	| Some e -> e

  let set_prop bundle k v = Hashtbl.replace bundle k (Obj.repr v)
  let remove_prop bundle k = Hashtbl.remove bundle k
  let get_list bundle k = get_prop bundle ~default:[] k
  let add_list bundle k e = set_prop bundle k (e :: get_list bundle k)
  let append_list bundle k e = set_prop bundle k (get_list bundle k @ [e])

end

class bundle =
object(self)
  val bundle = H.create ()
  method id = Oo.id self
  method get_prop : 'a. (?default:'a -> ?exn:exn -> 'a key -> 'a)
    = fun ?default ?exn k -> H.get_prop bundle ?default ?exn k
  method set_prop : 'a. ('a key -> 'a -> unit) = H.set_prop bundle
  method remove_prop : 'a. ('a key -> unit) = H.remove_prop bundle
  method get_list : 'a. ( 'a list key -> 'a list ) = H.get_list bundle
  method add_list : 'a.( 'a list key -> 'a -> unit ) = H.add_list bundle
  method append_list : 'a.( 'a list key -> 'a -> unit ) = H.append_list bundle
end

