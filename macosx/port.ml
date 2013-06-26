(* -------------------------------------------------------------------------- *)
(* --- Data                                                               --- *)
(* -------------------------------------------------------------------------- *)

external nil : unit -> 'a = "wcaml_nil"
let nil : 'a = nil ()

(* -------------------------------------------------------------------------- *)
(* --- NSString                                                           --- *)
(* -------------------------------------------------------------------------- *)

module NSString =
struct
  type t
  external of_string : string -> t = "wcaml_nsstring_of_value"
  external to_string : t -> string = "wcaml_value_of_nsstring"
end

(* -------------------------------------------------------------------------- *)
(* --- Array                                                              --- *)
(* -------------------------------------------------------------------------- *)

module NSArray =
struct
  type 'a t
  external init : int -> 'a t              = "wcaml_nsarray_init"
  external count : 'a t -> int             = "wcaml_nsarray_count"
  external get : 'a t -> int -> 'a         = "wcaml_nsarray_get"
  external add : 'a t -> 'a -> unit        = "wcaml_nsarray_add"
  external set : 'a t -> int -> 'a -> unit = "wcaml_nsarray_set"

  let of_list xs =
    let w = init (List.length xs) in
    List.iter (add w) xs ; w

  let to_list w =
    let r = ref [] in
    for i = count w - 1 downto 0 do
      r := get w i :: !r
    done ; !r

  let of_array xs =
    let w = init (Array.length xs) in
    Array.iter (add w) xs ; w

  let to_array w =
    Array.init (count w) (get w)

end

(* -------------------------------------------------------------------------- *)
(* --- Callbacks Machinery                                                 --- *)
(* -------------------------------------------------------------------------- *)

let sid : (string,unit) Hashtbl.t = Hashtbl.create 63

let check id =
  if Hashtbl.mem sid id then
    let msg = Printf.sprintf 
      "[wcaml.macosx.service] Duplicate service '%s'" id 
    in raise (Invalid_argument msg)
  else
    Hashtbl.add sid id ()

module type S_Callback =
sig
  type index
  type nsobject
  type signature
  val name : string
  val index : nsobject -> index
  val default : signature
end

module type NS_Callback =
sig
  type nsobject
  type signature
  val name : string
  val default : signature
end

module type ID_Callback =
sig
  type signature
  val name : string
  val default : signature
end

module type Callback =
sig
  type index
  type signature
  val default : signature
  val mem : index -> bool
  val bind : index -> signature -> unit
  val remove : index -> unit
end

module Register( S : S_Callback ) =
struct
  open S
  type index = S.index
  type signature = S.signature
  let registry : (index,signature) Hashtbl.t = Hashtbl.create 131
  let default = S.default
  let callback (lnk : S.nsobject) : S.signature =
    try Hashtbl.find registry (S.index lnk)
    with Not_found -> S.default
  let mem = Hashtbl.mem registry
  let bind = Hashtbl.replace registry
  let remove = Hashtbl.remove registry
  let () =
    begin
      check name ;
      Callback.register name callback ;
    end
end

module IDCallback( S : ID_Callback ) = Register
  (struct
     type index = string
     type nsobject = NSString.t
     let index = NSString.to_string
     include S
   end)

module NSCallback( S : NS_Callback ) = Register
  (struct
     type index = S.nsobject
     let index w = w
     include S
   end)
