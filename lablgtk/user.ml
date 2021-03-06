(* -------------------------------------------------------------------------- *)
(* --- User Preferences                                                   --- *)
(* -------------------------------------------------------------------------- *)

open Event

(* -------------------------------------------------------------------------- *)
(* --- Internal Database                                                  --- *)
(* -------------------------------------------------------------------------- *)
  
module IDS = Map.Make(String)
  
let idk = ref IDS.empty
let ident x = 
  try 
    let k = IDS.find x !idk in
    Format.eprintf "[WCaml] duplicate id '%s' [%d]" x k ;
    idk := IDS.add x (succ k) !idk ;
    Printf.sprintf "%s#%d" x k
  with Not_found ->
    idk := IDS.add x 1 !idk ; x
      
let prefs = ref IDS.empty

let home () = 
  let dir = 
    try Sys.getenv "HOME"
    with Not_found -> "." 
  in Printf.sprintf "%s/.%s.rc" dir !Config.app_file

let sig_load = new Event.signal
let sig_save = new Event.signal
let sig_dump = new Event.signal

let on_load = sig_load#connect
let on_save = sig_save#connect
let on_dump = sig_dump#connect

let load () =
  Userfile.parse 
    (fun p xs -> prefs := IDS.add p xs !prefs)
    (home ())

let save () =
  sig_save#fire () ;
  sig_dump#fire () ;
  Userfile.dump 
    (fun f -> IDS.iter f !prefs) 
    (home ())
    
let () = Main.on_init load
let () = Main.on_main sig_load#fire
let () = Main.on_quit save

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
    try match IDS.find id !prefs with
      | e::_ -> self#set (decode e)
      | [] -> ()
    with Not_found | Invalid_argument _ -> ()

  method private save () =
    try
      let r = encode self#get in
      prefs := IDS.add id [r] !prefs
    with Invalid_argument _ -> ()

  initializer
    begin
      self#load () ;
      on_dump self#save ;
    end

end

(* -------------------------------------------------------------------------- *)
(* --- Lists                                                              --- *)
(* -------------------------------------------------------------------------- *)

class ['a] clist 
  ~(encode:('a -> string))
  ~(decode:(string -> 'a)) 
  ~(id:string)
  ~(default:'a list)
  =
object(self)

  inherit ['a list] Event.selector default

  method private load () =
    try self#set (emap decode (IDS.find id !prefs))
    with Not_found -> ()

  method private save () =
    prefs := IDS.add id (emap encode self#get) !prefs

  initializer
    begin
      self#load () ;
      on_dump self#save ;
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
