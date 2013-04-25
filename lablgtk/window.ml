open Widget
open Event

class toplevel ~id ?(title="") ?content () =
  let win = GWindow.window
    ~kind:`TOPLEVEL
    ~resizable:true
    ~decorated:true
    ~deletable:true
    ~modal:false
    ~show:true
    () in
  let close = new Event.signal in
  let focus = new Event.signal in
  let size = User.int_list ~id ~default:[] in
object(self)
  inherit Property.bundle

  (*--- FRAME ---*)
  initializer
    begin
      Event.option self#set_content content ;
    end
    
  (*--- CONTENT & CLOSING ---*)
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
    end

  (*--- VISIBLE ---*)
  method set_visible e = if e then win#show () else win#misc#hide ()
  method show = win#show
  method hide = win#misc#hide
      
  (*--- DECORATION ---*)
  val mutable saved = true
  val mutable title = title
  method private decorate = win#set_title (if saved then title else "* "^title)
  method set_title t = title <- t ; self#decorate
  method set_saved s = saved <- s ; self#decorate
  method on_close = close#connect
  method set_content (w:widget) = win#add (w#get_prop Port.widget)
end
