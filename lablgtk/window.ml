open Widget
open Event

let visible = ref []
let focused = ref None
let running = ref false

let () = Main.on_main 
  begin fun () ->
    List.iter (fun w -> w#show ()) !visible ;
    Event.option (fun w -> w#present ()) !focused ;
    visible := [] ;
    focused := None ;
    running := true ;
  end

class toplevel ~id ?(title="") ?content ?(show=true) ?(focus=false) () =
  let win = GWindow.window
    ~kind:`TOPLEVEL
    ~resizable:true
    ~decorated:true
    ~deletable:true
    ~modal:false
    ~show:false () in
  let request = focus in
  let close = new Event.signal in
  let focus = new Event.signal in
  let size = User.int_list ~id ~default:[] in
object(self)
  inherit Property.bundle

  (*--- CONTENT & CLOSING ---*)
  method on_close = close#connect
  method set_content (w:pane) = win#add (Port.get_widget w)
  initializer
    begin
      Event.option self#set_content content ;
      let callback _ev = close#fire () ; true in
      ignore (win#event#connect#delete ~callback) ;
    end

  (*--- RESIZE ---*)
  method private resize r = size#set [ r.Gtk.width ; r.Gtk.height ]
  method private initsize = match size#get with
    | [width;height] -> win#resize ~width ~height
    | _ -> ()
  initializer
    begin
      ignore (win#misc#connect#size_allocate self#resize) ;
      self#initsize ;
    end

  (*--- VISIBLE ---*)
  method set_visible e = if e then win#show () else win#misc#hide ()
  method show = win#misc#show
  method hide = win#misc#hide

  (*--- FOCUS ---*)
  method focus = focus
  method on_focus = focus#connect
  method request_focus = win#misc#grab_focus
  initializer
    begin
      let connect = win#event#connect in
      let callback e _ev = focus#fire e ; false in
      ignore (connect#focus_in ~callback:(callback true));
      ignore (connect#focus_out ~callback:(callback false));
      if show then
	if !running then
	  win#present ()
	else
	  if request || !focused = None 
	  then focused := Some win 
	  else visible := !visible @ [win]
    end
      
  (*--- DECORATION ---*)
  val mutable w_saved = true
  val mutable w_title = title
  method private decorate = 
    win#set_title (if w_saved then w_title else "* "^w_title)
  method set_title t = w_title <- t ; self#decorate
  method set_saved s = w_saved <- s ; self#decorate
  initializer win#set_title title
end
