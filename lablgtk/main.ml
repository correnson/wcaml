
let init ~appid = Port.appname := appid ; ignore (GMain.init ())
let run = GMain.main
let quit = GMain.quit

