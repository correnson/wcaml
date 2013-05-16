(* -------------------------------------------------------------------------- *)
(* --- NSView & Such                                                      --- *)
(* -------------------------------------------------------------------------- *)

open Port

type emitter

module Signal = Service
  (struct
     let name = "nscontrol_signal"
     type nsobject = emitter
     type signature = unit -> unit
     let default () = ()
   end)

module NSView =
struct
  type t
  external set_tooltip : t -> NSString.t -> unit = "wcaml_nsview_set_tooltip"
  let key : t Property.key = Property.register ()
  let coerce (w : #Property.bundle) = w#get_prop key
  class view (w : t) =
  object(self)
    inherit Property.bundle
    initializer self#set_prop key w
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
  let as_cell : t -> NSCell.t = Obj.magic

  external set_emitter : t -> emitter = "wcaml_nscontrol_set_emitter"

  let bind w f = Signal.bind (set_emitter w) f

  class widget w =
  object(self)
    inherit NSView.view (as_view w)
    method coerce = (self :> Widget.widget)
    method set_enabled = NSCell.set_enabled (as_cell w)
  end

  class control ?tooltip w =
  object(self)
    inherit widget w
    method set_tooltip s = NSView.set_tooltip (as_view w) (NSString.of_string s)
    initializer Event.option self#set_tooltip tooltip
  end

end

module NSButton =
struct
  type t
  let as_control : t -> NSControl.t = Obj.magic
  let as_view : t -> NSView.t = Obj.magic
  let as_cell : t -> NSCell.t = Obj.magic
  external create : int -> t = "wcaml_nsbutton_create"
end
