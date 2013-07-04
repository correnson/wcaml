(* -------------------------------------------------------------------------- *)
(* --- WCaml Packager                                                     --- *)
(* -------------------------------------------------------------------------- *)

let app = ref ""
let name = ref ""
let version = ref "0.1"
let domain = ref "wcaml.org"
let config = ref ""
let resources = ref ""
let files = ref []

let add_file f = files := f :: !files

let configure () =
  begin
    begin
      match !app , !name with
	| "" , "" -> app := "myapp" ; name := "MyApp"
	| "" , t -> app := String.lowercase t
	| a , "" -> name := String.capitalize a
	| _ -> ()
    end ;
    if !config = "" then config := !app ^ "_config.ml" ;
    if !resources = "" then resources := "/usr/local/share/" ^ !app ;
  end

(* -------------------------------------------------------------------------- *)

let rec reverse url p = 
  try
    let k = String.index_from url p '.' in
    if p < k then
      let w = String.sub url p (k-p) in
      let r = reverse url (succ k) in
      r ^ "." ^ w
    else
      reverse url (succ k)
  with Not_found -> 
    String.sub url p (String.length url - p)

(* -------------------------------------------------------------------------- *)
(* --- Config                                                             --- *)
(* -------------------------------------------------------------------------- *)

let config_key fmt key value =
  Format.fprintf fmt "let () = Wcaml.Config.%s := %S@\n" key value

let make_config_file () =
  Format.eprintf "[WCaml] %s@." !config ;
  let out = open_out !config in
  let fmt = Format.formatter_of_out_channel out in
  let url = !app ^ "." ^ !domain in
  let file = reverse !domain 0 ^ "." ^ !app in
  begin
    config_key fmt "app" !app ;
    config_key fmt "name" !name ;
    config_key fmt "version" !version ;
    config_key fmt "app_url" url ;
    config_key fmt "app_file" file ;
    config_key fmt "wcaml_resources" !resources ;
    Format.pp_print_flush fmt () ;
    close_out out ;
  end

(* -------------------------------------------------------------------------- *)
(* --- Resources                                                          --- *)
(* -------------------------------------------------------------------------- *)

let icons = [
  "status_red.png" ; 
  "status_green.png" ; 
  "status_orange.png" ; 
  "status_none.png" ;
]

let command cmd = 
  let e = Sys.command cmd in
  if e <> 0 then
    ( Format.eprintf "Error[%d]: %S@." e cmd ; exit e )

let make_resources () =
  begin
    Format.eprintf "[WCaml] Resources '%s'@." !resources ;
    command (Printf.sprintf "mkdir -p %s" !resources) ;
    List.iter
      (fun img -> command
	 (Printf.sprintf "cp $(ocamlfind query wcaml)/%s %s/%s"
	    img !resources img
	 )) icons ;
    List.iter
      (fun src -> 
	 let tgt = Filename.basename src in
	 command (Printf.sprintf "cp %s %s/%s" src !resources tgt)
      ) !files ;
  end

(* -------------------------------------------------------------------------- *)
(* --- Command Line                                                       --- *)
(* -------------------------------------------------------------------------- *)

let () =
  begin
    Arg.parse
      [
	"-a" , Arg.Set_string name , "Application Name ('MyApp')" ;
	"-e" , Arg.Set_string app , "Application Executable ('myapp')" ;
	"-v" , Arg.Set_string version , "Application Version ('0.1')" ;
	"-u" , Arg.Set_string domain , "Application URL-Domain ('wcaml.org')" ;
	"-c" , Arg.Set_string config , "Configuration File ('myapp_config.ml')" ;
	"-d" , Arg.Set_string resources , "Resources Directory ('/usr/local/myapp')" ; 
      ] add_file "wpack [options] files..." ;
    configure () ;
    make_config_file () ;
    make_resources () ;
  end
  
