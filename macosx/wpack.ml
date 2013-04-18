(* -------------------------------------------------------------------------- *)
(* --- WCaml Packager                                                     --- *)
(* -------------------------------------------------------------------------- *)

let app = ref ""
let name = ref ""
let version = ref "0.1"
let domain = ref "wcaml.org"
let bundle = ref ""
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
    if !bundle = "" then bundle := !name ^ ".app" ;
    if !config = "" then config := !app ^ "_config.ml" ;
  end

(* -------------------------------------------------------------------------- *)
(* --- Info.plist                                                         --- *)
(* -------------------------------------------------------------------------- *)

let infop_key out key value = 
  Printf.fprintf out "  <key>%s</key><string>%s</string>\n" key value

let infop_file () =
  let file = Printf.sprintf "%s/Contents/Info.plist" !bundle in
  Format.eprintf "[WCaml] %s@." file ;
  let out = open_out file in
  begin
    output_string out "<plist version=\"1.0\">\n<dict>\n" ;
    infop_key out "CFBundleDevelopmentRegion" "English" ;
    infop_key out "CFBundleInfoDictionaryVersion" "6.0" ;
    infop_key out "CFBundlePackageType" "APPL" ;
    infop_key out "CFBundleSignature" "????" ;
    infop_key out "CFBundleName" !name ;
    infop_key out "CFBundleVersion" !version ;
    infop_key out "CFBundleIdentifier" (Printf.sprintf "%s.%s" !app !domain) ;
    infop_key out "CFBundleShortVersionString" !version ;
    infop_key out "CFBundleExecutable" !app ;
    infop_key out "CFBundleIconFile" "" ;
    output_string out "</dict>\n</plist>\n" ;
    close_out out ;
  end

(* -------------------------------------------------------------------------- *)
(* --- Config                                                             --- *)
(* -------------------------------------------------------------------------- *)

let config_key fmt key value =
  Format.fprintf fmt "let () = Config.%s := %S@\n" key !value

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
(* --- Application Bundle                                                 --- *)
(* -------------------------------------------------------------------------- *)

let exec cmd = 
  let st = Sys.command cmd in
  if st <> 0 then
    begin
      Format.eprintf "%s\nError: exit with status %d@." cmd st ;
      exit st ;
    end

let app_bundle () =
  begin
    Format.printf "[WCaml] %s/Contents/MacOS@." !bundle ;
    exec (Printf.sprintf "mkdir -p %s/Contents/MacOS" !bundle) ;
    exec (Printf.sprintf "SetFile -a B %s" !bundle) ;
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
	"-b" , Arg.Set_string bundle , "Bundle File ('MyApp.app')" ;
	"-c" , Arg.Set_string config , "Configuration File ('myapp_config.ml')" ;
      ] throw "wpack [options]" ;
    configure () ;
    config_file () ;
    app_bundle () ;
    infop_file () ;
  end
  
