(** Cocoa Views *)

open Port

module NSView :
sig
  type t
  type layout
  val create : unit -> t
  val scroll : t -> t
  val set_tooltip : t -> NSString.t -> unit
  val add_subview : t -> t -> unit
  val has_baseline : t -> bool
  val set_layout : t -> layout -> t -> t -> int -> unit
  val debug : t -> unit

  val kHsep      : layout
  val kHfill     : layout
  val kVsep      : layout
  val kVfill     : layout
  val kLeftAlign : layout
  val kBaseline  : layout
  val kWidth     : layout

  val get : #Property.bundle -> t
  class view : t -> Property.bundle
  class pane : t -> Widget.pane
end

module NSCell :
sig
  type t
  val set_enabled : t -> bool -> unit
  val set_title : t -> NSString.t -> unit
  val set_state : t -> bool -> unit
  val get_state : t -> bool
end

module NSControl :
sig
  type t
  val as_view : t -> NSView.t
  val set_handler : t -> (unit -> unit) -> unit
  val set_string : t -> NSString.t -> unit
  val get_string : t -> NSString.t

  class widget : t -> Widget.widget
  class control : ?tooltip:string -> t -> Widget.control
end

module NSButton :
sig
  type t
  type attr
  val as_control : t -> NSControl.t
  val as_view : t -> NSView.t
  val as_cell : t -> NSCell.t
  val create : attr -> t
  val kPush : attr
  val kCheck : attr
  val kRadio : attr
end

module NSTextField :
sig
  type t
  val as_control : t -> NSControl.t
  val as_view : t -> NSView.t
  type attr = [
  | `Left | `Right | `Center 
  | `Label | `Title | `Descr
  | `Static | `Editable
  ]
  val create : unit -> t
  val set_attribute : t -> attr -> unit
end
