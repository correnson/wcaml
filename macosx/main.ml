(** {1 Main Entry Points} *)

open Event

external wcaml_init : unit -> unit = "wcaml_init"
external wcaml_main : unit -> unit = "wcaml_main"
external wcaml_quit : unit -> unit = "wcaml_quit"

let on_init = new signal
let on_main = new signal
let on_quit = new signal

let init () = wcaml_init () ; on_init#fire ()
let main () = on_main#fire () ; wcaml_main ()
let quit () = on_quit#fire () ; wcaml_quit ()
