(* -------------------------------------------------------------------------- *)
(* --- WCaml Packager                                                     --- *)
(* -------------------------------------------------------------------------- *)

let app = ref ""
let name = ref ""
let version = ref "0.1"
let domain = ref "wcaml.org"
let config = ref ""

let throw p = Format.eprintf "[WCaml] Don't known what to do with '%s'" p

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
  end

(* -------------------------------------------------------------------------- *)
(* --- Config                                                             --- *)
(* -------------------------------------------------------------------------- *)

let config_key fmt key value =
  Format.fprintf fmt "let () = Wcaml.Config.%s := %S@\n" key !value

let config_file () =
  Format.eprintf "[WCaml] %s@." !config ;
  let out = open_out !config in
  let fmt = Format.formatter_of_out_channel out in
  begin
    config_key fmt "app" app ;
    config_key fmt "name" name ;
    config_key fmt "version" version ;
    config_key fmt "domain" domain ;
    Format.pp_print_flush fmt () ;
    close_out out ;
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
	"-d" , Arg.Set_string domain , "Application Domain ('wcaml.org')" ;
	"-c" , Arg.Set_string config , "Configuration File ('myapp_config.ml')" ;
      ] throw "wpack [options]" ;
    configure () ;
    config_file () ;
  end
  
