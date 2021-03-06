(* -------------------------------------------------------------------------- *)
(* --- NSView & Such                                                      --- *)
(* -------------------------------------------------------------------------- *)

open Port

type emitter

module Signal = NSCallback
  (struct
     let name = "wcaml_nscontrol_signal"
     type nsobject = emitter
     type signature = unit -> unit
     let default () = ()
   end)

module NSView =
struct
  type t
  type layout = int
  external create : unit -> t = "wcaml_nsview_create"
  external scroll : t -> t = "wcaml_nsview_scroll"
  external set_tooltip : t -> NSString.t -> unit = "wcaml_nsview_set_tooltip"
  external add_subview : t -> t -> unit = "wcaml_nsview_add_subview"
  external has_baseline : t -> bool = "wcaml_nsview_has_baseline"
  external set_layout : t -> int -> t -> t -> int -> unit = "wcaml_nsview_set_layout"
  external set_autolayout : t -> bool -> unit = "wcaml_nsview_set_autolayout"
  external debug : t -> unit = "wcaml_nsview_debug"

  let kHsep      = 0b0000
  let kHfill     = 0b0001
  let kVsep      = 0b0010
  let kVfill     = 0b0011
  let kLeftAlign = 0b0100
  let kBaseline  = 0b0110
  let kWidth     = 0b1000

  let kview : t Property.key = Property.register ()

  let get (w : #Property.bundle) = w#get_prop kview

  class view (view : t) =
  object(self)
    inherit Property.bundle
    initializer self#set_prop kview view
  end

  class pane (view : t) =
  object(self)
    inherit Property.bundle
    method pane = (self :> Widget.pane)
    method request_focus () = assert false (*TODO*)
    initializer self#set_prop kview view
  end

end

module NSCell =
struct
  type t
  external set_enabled : t -> bool -> unit = "wcaml_nscell_set_enabled"
  external set_title : t -> NSString.t -> unit = "wcaml_nscell_set_title"
  external set_state : t -> bool -> unit = "wcaml_nscell_set_state"
  external get_state : t -> bool = "wcaml_nscell_get_state"
end

module NSControl =
struct
  type t
  let as_view : t -> NSView.t = Obj.magic

  external set_enabled : t -> bool -> unit = "wcaml_nscontrol_set_enabled"
  external set_emitter : t -> emitter = "wcaml_nscontrol_set_emitter"
  external set_string : t -> NSString.t -> unit = "wcaml_nscontrol_set_string"
  external get_string : t -> NSString.t = "wcaml_nscontrol_get_string"

  let set_handler w f = Signal.bind (set_emitter w) f

  class widget w =
  object(self)
    inherit NSView.view (as_view w)
    method debug () = NSView.debug (as_view w)
    method widget = (self :> Widget.widget)
    method set_enabled s = set_enabled w s
  end

  class control ?tooltip w =
  object(self)
    inherit widget w
    method control = (self :> Widget.control)
    method set_tooltip s = NSView.set_tooltip (as_view w) (NSString.of_string s)
    initializer Event.option self#set_tooltip tooltip
  end

end

module NSButton =
struct
  type t
  type attr = int
  let as_control : t -> NSControl.t = Obj.magic
  let as_view : t -> NSView.t = Obj.magic
  let as_cell : t -> NSCell.t = Obj.magic
  external create : int -> t = "wcaml_nsbutton_create"
  let kPush = 0
  let kCheck = 1
  let kRadio = 2
end

module NSTextField =
struct
  type t
  type attr = [
  | `Left | `Right | `Center (* Widget.align *)
  | `Label | `Title | `Descr | `Verbatim (* Widget.style *)
  | `Static | `Editable
  ]
  let as_control : t -> NSControl.t = Obj.magic
  let as_view : t -> NSView.t = Obj.magic
  external create : unit -> t = "wcaml_nstextfield_create"
  external set_attribute : t -> int -> unit = "wcaml_nstextfield_set_attribute"
  let attr = function
    | `Left -> 1
    | `Right -> 2
    | `Center -> 3
    | `Label -> 4
    | `Title -> 5
    | `Descr -> 6
    | `Verbatim -> 7
    | `Static -> 10
    | `Editable -> 20
  let set_attribute w a = set_attribute w (attr a)
  let set_text w s = NSControl.set_string (as_control w) s
  let get_text w = NSControl.get_string (as_control w)
end

module NSImage =
struct
  type t
  external system : int -> t = "wcaml_nsimage_system"
  external image : NSString.t -> t = "wcaml_nsimage_create"
  let cache = Hashtbl.create 32
  let icon (icn:Widget.icon) = match icn with
    | `NoIcon        -> Port.nil
    | `Status_none   -> system 10
    | `Status_green  -> system 11
    | `Status_orange -> system 12
    | `Status_red    -> system 13
    | `Warning       -> system 21
    | `Execute       -> system 22
    | `Trash         -> system 23
    | `Image f -> 
	try Hashtbl.find cache f
	with Not_found -> 
	  if Sys.file_exists f then
	    let img = image (NSString.of_string f) in
	    Hashtbl.add cache f img ; img
	  else
	    failwith (Printf.sprintf "Icon file %S not found." f)
end

module NSImageView =
struct
  type t
  let as_view : t -> NSView.t = Obj.magic
  let as_control : t -> NSControl.t = Obj.magic
  external set_image : t -> NSImage.t -> unit = "wcaml_nsimage_set"
end
