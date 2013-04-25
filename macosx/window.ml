open Widget
open Event
open Port

(* -------------------------------------------------------------------------- *)
(* --- Cocoa Port                                                         --- *)
(* -------------------------------------------------------------------------- *)

module NSWindow =
struct
  type t
  external cascading : unit -> unit = "wcaml_nswindow_cascading"
  external create : NSString.t -> t = "wcaml_nswindow_create"
  external set_title : t -> NSString.t -> unit = "wcaml_nswindow_set_title"
  external set_edited : t -> bool -> unit = "wcaml_nswindow_set_edited"
  external request_focus : t -> unit = "wcaml_nswindow_request_focus"
  external show : t -> unit = "wcaml_nswindow_show"
  external hide : t -> unit = "wcaml_nswindow_hide"
  external back : t -> unit = "wcaml_nswindow_back"
  let () = Main.on_init cascading
end

(* -------------------------------------------------------------------------- *)
(* --- Callbacks                                                          --- *)
(* -------------------------------------------------------------------------- *)

module Focus = Service
  (struct
     let name = "nswindow_focus"
     type nsobject = NSWindow.t
     type signature = bool -> unit
     let default _ = ()
   end)

module Close = Service
  (struct
     let name = "nswindow_close"
     type nsobject = NSWindow.t
     type signature = unit -> unit
     let default () = ()
   end)

(* -------------------------------------------------------------------------- *)
(* --- Window Packing                                                     --- *)
(* -------------------------------------------------------------------------- *)

class toplevel ~id ?title ?(content:widget option) () =
  let window = NSWindow.create (NSString.of_string id) in
  let close : unit signal = new Event.signal in
  let focus : bool signal = new Event.signal in
object(self)

  (*--- Widget ---*)
  inherit Property.bundle

  (*--- FRAME ---*)
  method set_title t = NSWindow.set_title window (NSString.of_string t)
  method set_saved s = NSWindow.set_edited window (not s)
  initializer Event.option self#set_title title

  (*--- FOCUS ---*)
  method focus = focus
  method on_focus = focus#connect
  method request_focus () = NSWindow.request_focus window
  initializer Focus.register window focus#fire

  (*--- VISIBLE ---*)
  method set_visible e =
    if e then NSWindow.show window else NSWindow.hide window
  method show () = NSWindow.show window
  method hide () = NSWindow.hide window

  (*--- Content & Closing ---*)
  method on_close = close#connect
  method set_content : widget -> unit = fun _ -> ()
  initializer Event.option self#set_content content
  initializer Close.register window close#fire

end
