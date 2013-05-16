(** Cocoa Views *)

open Port

module NSView :
sig
  type t
  val key : t Property.key
  val coerce : #Property.bundle -> t
  external set_tooltip : t -> NSString.t -> unit = "wcaml_nsview_set_tooltip"
  class view : t -> Property.bundle
end

module NSCell :
sig
  type t
  external set_enabled : t -> bool -> unit = "wcaml_nscell_set_enabled"
  external set_title : t -> NSString.t -> unit = "wcaml_nscell_set_title"
end

module NSControl :
sig
  type t
  val as_view : t -> NSView.t
  val as_cell : t -> NSCell.t
  val bind : t -> unit Event.callback
  class widget : t -> Widget.widget
  class control : ?tooltip:string -> t -> Widget.control
end

module NSButton :
sig
  type t
  val as_control : t -> NSControl.t
  val as_view : t -> NSView.t
  val as_cell : t -> NSCell.t
  external create : unit -> t = "wcaml_nsbutton_create"
end
