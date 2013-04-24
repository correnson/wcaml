(** {1 Main Entry Points} *)

open Event

external wcaml_init : unit -> unit = "wcaml_init"
external wcaml_main : unit -> unit = "wcaml_main"
external wcaml_quit : unit -> unit = "wcaml_quit"

let sig_init = new signal
let sig_main = new signal
let sig_quit = new signal

let on_init = sig_init#connect
let on_main = sig_main#connect
let on_quit = sig_quit#connect

let init () = wcaml_init () ; sig_init#fire ()
let main () = wcaml_main () ; sig_main#fire ()
let quit () = sig_quit#fire () ; wcaml_quit ()
