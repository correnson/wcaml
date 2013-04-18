(* -------------------------------------------------------------------------- *)
(* --- User Preferences                                                   --- *)
(* -------------------------------------------------------------------------- *)

open Signal
type 'a preference = id:string -> default:'a -> 'a selector
  
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
  in Filename.concat dir !Port.appname

let load () =
  Userfile.parse 
    (fun p xs -> prefs := IDS.add p xs !prefs)
    (home ())

let save () =
  Userfile.dump
    (fun f -> IDS.iter f !prefs)
    (home ())

