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
  let () = Main.on_init cascading
end

(* -------------------------------------------------------------------------- *)
(* --- Window Packing                                                     --- *)
(* -------------------------------------------------------------------------- *)

class toplevel ~id ?title ?(content:widget option) () =
  let window = NSWindow.create (NSString.of_string id) in
  let _close : bool signal = new Event.signal in
  let focus : bool signal = new Event.signal in
object(self)

  (*--- Widget ---*)
  inherit Property.bundle
  method coerce = (self :> Widget.widget)
  method set_enabled : bool -> unit = fun _ -> ()

  (*--- FRAME ---*)
  method set_title t = NSWindow.set_title window (NSString.of_string t)
  method set_saved s = NSWindow.set_edited window (not s)
  initializer Event.option self#set_title title

  (*--- FOCUS ---*)    
  method focus = focus
  method on_focus = focus#connect
  method request_focus () = ()

  (*--- VISIBLE ---*)
  method visible = focus
  method on_visible = focus#connect
  method set_visible (_:bool) = ()
  method show () = ()
  method hide () = ()

  (*--- Content & Closing ---*)
  method on_close : unit callback = fun _ -> ()
  method set_content : widget -> unit = fun _ -> ()
  initializer Event.option self#set_content content

end
