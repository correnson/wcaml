open Widget
open Event

class toplevel ~id ?(title="") ?content () =
  let win = GWindow.window
    ~kind:`TOPLEVEL
    ~resizable:true
    ~decorated:true
    ~deletable:true
    ~modal:false
    ~position:`CENTER
    () in
  let close = new Event.signal in
  let focus = new Event.signal in
object(self)
  inherit Port.widget win
  val mutable saved = true
  val mutable title = title
  initializer
    begin
      ignore id ;
      Event.option self#set_content content ;
      let callback _ev = close#fire () ; true in
      ignore (win#event#connect#delete ~callback) ;
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
  method visible = focus
  method on_visible = focus#connect
  method set_visible e = if e then win#show () else win#misc#hide ()
  method show = win#show
  method hide = win#misc#hide
      
  (*--- DECORATION ---*)
  method private decorate = win#set_title (if saved then title else "* "^title)
  method set_title t = title <- t ; self#decorate
  method set_saved s = saved <- s ; self#decorate
  method on_close = close#connect
  method set_content (w:widget) = win#add (w#get_prop Port.widget)
end
