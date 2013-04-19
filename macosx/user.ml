(* -------------------------------------------------------------------------- *)
(* --- User Preferences                                                   --- *)
(* -------------------------------------------------------------------------- *)

open Port
open Event

external get_user_nsstring : NSString.t -> NSString.t 
  = "wcaml_get_user_nsstring"

external set_user_nsstring : NSString.t -> NSString.t -> unit 
  = "wcaml_set_user_object"

external get_user_nsarray  : NSString.t -> NSString.t NSArray.t
  = "wcaml_get_user_nsarray"

external set_user_nsarray  : NSString.t -> NSString.t NSArray.t -> unit
  = "wcaml_set_user_object"

(* -------------------------------------------------------------------------- *)
(* --- Wrapper                                                            --- *)
(* -------------------------------------------------------------------------- *)

let rec emap f = function
  | [] -> []
  | e::es -> 
      try let r = f e in r :: emap f es
      with Invalid_argument _ -> emap f es

(* -------------------------------------------------------------------------- *)
(* --- Cells                                                              --- *)
(* -------------------------------------------------------------------------- *)

class ['a] cell 
  ~(encode:('a -> string))
  ~(decode:(string -> 'a))
  ~(id:string)
  ~(default:'a) =
object(self)

  inherit ['a] Event.selector default

  method private load () =
    let obj = get_user_nsstring (NSString.of_string id) in
    if obj != NSString.nil then
      try self#set (decode (NSString.to_string obj))
      with Invalid_argument _ -> ()

  method private save () =
    try 
      let v = NSString.of_string (encode self#get) in
      let k = NSString.of_string id in
      set_user_nsstring k v
    with Invalid_argument _ -> ()
      
  initializer
    begin
      self#load () ;
      self#on_event self#save ;
    end

end

(* -------------------------------------------------------------------------- *)
(* --- Lists                                                              --- *)
(* -------------------------------------------------------------------------- *)

let (<<) f g x = f (g x)

class ['a] clist 
  ~(encode:('a -> string))
  ~(decode:(string -> 'a)) 
  ~(id:string)
  ~(default:'a list)
  =
object(self)

  inherit ['a list] Event.selector default

  method private load () =
    let obj = get_user_nsarray (NSString.of_string id) in
    let ids = NSArray.to_list obj in
    self#set (emap (decode << NSString.to_string) ids)
      
  method private save () =
    let ids = emap (NSString.of_string << encode) self#get in
    let obj = NSArray.of_list ids in
    let key = NSString.of_string id in
    set_user_nsarray key obj

  initializer
    begin
      Main.on_main#connect self#load ;
      self#on_event self#save ;
    end

end

(* -------------------------------------------------------------------------- *)
(* --- API                                                                --- *)
(* -------------------------------------------------------------------------- *)

type 'a preference = id:string -> default:'a -> 'a selector

let id x = x

let int = new cell ~encode:string_of_int ~decode:int_of_string
let int_list = new clist ~encode:string_of_int ~decode:int_of_string

let string = new cell ~encode:id ~decode:id
let string_list = new clist ~encode:id ~decode:id

let float = new cell ~encode:string_of_float ~decode:float_of_string
let float_list = new clist ~encode:string_of_float ~decode:float_of_string

let create = new cell
let create_list = new clist
