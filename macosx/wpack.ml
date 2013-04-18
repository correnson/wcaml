(* -------------------------------------------------------------------------- *)
(* --- WCaml Packager                                                     --- *)
(* -------------------------------------------------------------------------- *)

let app = ref ""
let name = ref ""
let version = ref "0.1"
let domain = ref "wcaml.org"
let bundle = ref ""

let throw p = Format.eprintf "[WCaml] Don't known what to do with '%s'" p

let configure () =
  begin
    match !app , !name with
      | "" , "" -> app := "myapp" ; name := "MyApp"
      | "" , t -> app := String.lowercase t
      | a , "" -> name := String.capitalize a
      | _ -> ()
  end ;
  if !bundle = "" then bundle := !name ^ ".app"

(* -------------------------------------------------------------------------- *)
(* --- Info.plist                                                         --- *)
(* -------------------------------------------------------------------------- *)

let infop_key out key value = 
  Printf.fprintf out "  <key>%s</key><string>%s</string>\n" key value

let infop_file () =
  let file = Filename.concat "%s/Contents/Info.plist" !bundle in
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
  let file = Printf.sprintf "%s_config.ml" !app in
  let out = open_out file in
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

let exec_cmd cmd = 
  let st = Sys.command cmd in
  if st <> 0 then
    begin
      Format.eprintf "%s\nError: exit with status %d@." cmd st ;
      exit st ;
    end

let exec cmd = 
  let buffer = Buffer.create 80 in
  Format.kfprintf
    (fun fmt -> 
       Format.pp_print_flush fmt () ;
       exec_cmd (Buffer.contents buffer))
    (Format.formatter_of_buffer buffer)
    cmd

let app_bundle () =
  begin
    exec "mkdir -p %s/Contents/MacOS" !bundle ;
    exec "SetFile -a B %s" !bundle ;
  end

(* -------------------------------------------------------------------------- *)
(* --- Command Line                                                       --- *)
(* -------------------------------------------------------------------------- *)

let () =
  begin
    Arg.parse
      [
	"-a" , Arg.Set_string app , "Application Identifier ('myapp')" ;
	"-t" , Arg.Set_string name , "Application Title ('MyApp')" ;
	"-v" , Arg.Set_string version , "Application Version ('0.1')" ;
	"-d" , Arg.Set_string domain , "Application Domain ('wcaml.org')" ;
      ] throw "wpack [options]" ;
    configure () ;
    config_file () ;
    app_bundle () ;
    infop_file () ;
  end
  
