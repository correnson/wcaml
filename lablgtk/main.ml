
open Event

let sig_init = new Event.signal
let sig_main = new Event.signal
let sig_quit = new Event.signal

let on_init = sig_init#connect
let on_main = sig_main#connect
let on_quit = sig_quit#connect

let init () = ignore (GMain.init ()) ; sig_init#fire ()
let main () = GMain.main () ; sig_main#fire ()
let quit () = sig_quit#fire () ; GMain.quit ()
