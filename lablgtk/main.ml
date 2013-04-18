
open Event

let on_init = new Event.signal
let on_main = new Event.signal
let on_quit = new Event.signal

let init () = ignore (GMain.init ()) ; on_init#fire ()
let main () = on_main#fire () ; GMain.main ()
let quit () = on_quit#fire () ; GMain.quit ()

