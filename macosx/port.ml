(* -------------------------------------------------------------------------- *)
(* --- Services Machinery                                                 --- *)
(* -------------------------------------------------------------------------- *)

let sid : (string,unit) Hashtbl.t = Hashtbl.create 63

let check id =
  if Hashtbl.mem sid id then
    let msg = Printf.sprintf 
      "[wcaml.macosx.service] Duplicate service '%s'" id 
    in raise (Invalid_argument msg)
  else
    Hashtbl.add sid id ()

module type ServiceId =
sig
  val name : string
  type link
  type signature
  val default : signature
end

module Service(S : ServiceId) =
struct
  
  let registry : (S.link,S.signature) Hashtbl.t = Hashtbl.create 131
    
  let callback lnk =
    try Hashtbl.find registry lnk
    with Not_found -> S.default
  
  let register = Hashtbl.replace registry
  let remove = Hashtbl.remove registry
      
  let () =
    begin
      check S.name ;
      Callback.register ("wcaml:" ^ S.name) callback
    end

end

(* -------------------------------------------------------------------------- *)
(* --- Data                                                               --- *)
(* -------------------------------------------------------------------------- *)

type id = Obj.t

module NSString =
struct
  type t
  let id = Obj.repr
  external of_string : string -> t = "wcaml_nsstring_of_value"
  external to_string : t -> string = "wcaml_value_of_nsstring"
end

(* -------------------------------------------------------------------------- *)
(* --- Array                                                              --- *)
(* -------------------------------------------------------------------------- *)

module NSArray =
struct
  type t
  let id = Obj.repr
end
