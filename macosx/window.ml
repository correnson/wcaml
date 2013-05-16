open Widget
open Event
open Port
open Portcontrol

(* -------------------------------------------------------------------------- *)
(* --- Cocoa Port                                                         --- *)
(* -------------------------------------------------------------------------- *)

module NSWindow =
struct
  type t
  external cascading : unit -> unit = "wcaml_nswindow_cascading"
  external create : NSString.t -> t = "wcaml_nswindow_create"
  external set_content : t -> NSView.t -> unit = "wcaml_nswindow_set_content"
  external set_title : t -> NSString.t -> unit = "wcaml_nswindow_set_title"
  external set_edited : t -> bool -> unit = "wcaml_nswindow_set_edited"
  external request_focus : t -> unit = "wcaml_nswindow_request_focus"
  external show : t -> unit = "wcaml_nswindow_show"
  external hide : t -> unit = "wcaml_nswindow_hide"
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

let main = ref true

class toplevel ~id ?title ?(content:widget option) ?(show=true) ?(focus=false) () =
  let request = focus in
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
  initializer Focus.bind window focus#fire

  (*--- VISIBLE ---*)
  method set_visible e =
    if e then NSWindow.show window else NSWindow.hide window
  method show () = NSWindow.show window
  method hide () = NSWindow.hide window

  (*--- Content & Closing ---*)
  method on_close = close#connect
  method set_content widget = NSWindow.set_content window (NSView.coerce widget)
  initializer Event.option self#set_content content
  initializer Close.bind window close#fire

  (*--- Initial ---*)
  initializer
    begin
      if show then
	if (!main || request) then 
	  begin
	    main := false ;
	    NSWindow.request_focus window ;
	  end
	else NSWindow.show window
    end

end
